//
//  WSProductDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProductDetailViewController.h"
#import "CollectSucView.h"
#import "WSScanProductViewController.h"
#import "WSScanAfterViewController.h"

@interface WSProductDetailViewController () <UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;
@property (strong, nonatomic) NSMutableDictionary *goodsDetails;

@end

@implementation WSProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"商品详情";
    [self requestProductDetail];
}

- (void)requestProductDetail
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (_goodsId.length > 0) {
        [params setValue:_goodsId forKey:@"goodsId"];
    }
    if (_goodsNumber.length > 0) {
        [params setValue:_goodsNumber forKey:@"goodsNumber"];
    }
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_shopId forKey:@"shopid"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetGoodsDetails] data:params tag:WSInterfaceTypeGetGoodsDetails sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            if (!_goodsDetails) {
                self.goodsDetails = [[NSMutableDictionary alloc] init];
            }
            NSDictionary *dic = [[result objectForKey:@"data"] objectForKey:@"goodsDetails"];
            [self.goodsDetails setValuesForKeysWithDictionary:dic];
            [self initView];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}
                
- (void)initView
{
    NSArray *titleArray = nil;
    NSArray *imageArray = nil;
    NSString *Isscan = [_goodsDetails stringForKey:@"goodsScan"];
    // 可以扫描
    if ([Isscan isEqualToString:@"1"]) {
        _hasScan = YES;
        titleArray = @[@"收藏", @"扫描", @"分享"];
        imageArray = @[@"", @"scanning", @"share"];
    } else {
        _hasScan = NO;
        titleArray = @[@"收藏", @"分享"];
        imageArray = @[@"", @"share"];
    }
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger  count = titleArray.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[titleArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dic setValue:[imageArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_NORMAL];
        [dic setValue:[imageArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_SELECTED];
        [dataArray addObject:dic];
    }
   
    _tabSlideManagerView.tabSlideGapTextView.titleSelectedColor = [UIColor colorWithWhite:0.427 alpha:1.000];
    [_tabSlideManagerView.tabSlideGapTextView setTabSlideDataArray:dataArray];
    NSString *isCollect = [_goodsDetails stringForKey:@"isCollect"];
    // 已经收藏
    NSString *collectImage = nil;
    if ([isCollect isEqualToString:@"Y"]) {
      collectImage = @"collected";
    } else {
        collectImage = @"uncollect";
    }
     WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
    itemView.rightImageView.image = [UIImage imageNamed:collectImage];
    _tabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        switch (index) {
                //收藏
            case 0:
            {
                NSString *isCollect = [_goodsDetails stringForKey:@"isCollect"];
                // 已经收藏
                NSString *collectImage = nil;
                if ([isCollect isEqualToString:@"Y"]) {
                    collectImage = @"collected";
                } else {
                    collectImage = @"uncollect";
                }
                WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
                itemView.rightImageView.image = [UIImage imageNamed:collectImage];
                [self collectAction];
            }
                break;
                // 扫描或分享
            case 1:
            {
                NSString *isCollect = [_goodsDetails stringForKey:@"isCollect"];
                // 已经收藏
                NSString *collectImage = nil;
                if ([isCollect isEqualToString:@"Y"]) {
                    collectImage = @"collected";
                } else {
                    collectImage = @"uncollect";
                }
                WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
                itemView.rightImageView.image = [UIImage imageNamed:collectImage];

                // 扫描
                if (_hasScan) {
                    [WSUserUtil actionAfterLogin:^{
                        WSScanProductViewController *scanProductVC = [[WSScanProductViewController alloc] init];
                        scanProductVC.scanSucCallBack = ^(NSString *beanNumber) {
                            WSScanAfterViewController *scanAfterVC = [[WSScanAfterViewController alloc] init];
                            scanAfterVC.goodsId = [_goodsDetails stringForKey:@"id"];
                            scanAfterVC.shopid = _shopId;
                            scanAfterVC.beanNum = beanNumber;
                            [self.navigationController pushViewController:scanAfterVC animated:YES];
                        };
                        scanProductVC.shopid = _shopId;
                        scanProductVC.goodsId = [_goodsDetails stringForKey:@"id"];
                        [self.navigationController pushViewController:scanProductVC animated:YES];
                    }];
                // 分享
                } else {
                    if (_goodsDetails) {
                        NSString *title = [_goodsDetails objectForKey:@"productname"];
                        NSString *promotion= [_goodsDetails objectForKey:@"promotion"];
                        NSString *h5url = [_goodsDetails objectForKey:@"h5url"];
                        [WSShareSDKUtil shareWithTitle:title content:promotion description:promotion url:h5url imagePath:@"" thumbImagePath:@"" result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                            
                        }];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"商品查询错误！" duration:TOAST_VIEW_TIME];
                    }
                }
            }
                break;
                //分享
            case 2:
            {
                NSString *isCollect = [_goodsDetails stringForKey:@"isCollect"];
                // 已经收藏
                NSString *collectImage = nil;
                if ([isCollect isEqualToString:@"Y"]) {
                    collectImage = @"collected";
                } else {
                    collectImage = @"uncollect";
                }
                WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
                itemView.rightImageView.image = [UIImage imageNamed:collectImage];

                if (_goodsDetails) {
                    NSString *title = [_goodsDetails objectForKey:@"productname"];
                    NSString *promotion= [_goodsDetails objectForKey:@"promotion"];
                    NSString *h5url = [_goodsDetails objectForKey:@"h5url"];
                    [WSShareSDKUtil shareWithTitle:title content:promotion description:promotion url:h5url imagePath:@"" thumbImagePath:@"" result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"商品查询错误！" duration:TOAST_VIEW_TIME];
                }
            }
                break;
            default:
                break;
        }
    };
    id h5url  = [_goodsDetails objectForKey:@"h5url"];
    h5url = h5url == nil ? @"" : h5url;
    BOOL flag = [h5url isKindOfClass:[NSNull class]];
    h5url =  flag ? @"" : h5url;
    NSURL *url =[NSURL URLWithString:h5url];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
}

- (void)collectAction
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *userType = user.userType;
    if ([userType isEqualToString:@"1"]) {
        NSString *isCollect = [_goodsDetails stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [_goodsDetails stringForKey:@"id"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": _shopId};
            [SVProgressHUD show];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [_goodsDetails setValue:@"Y" forKey:@"isCollect"];
                    WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
                    itemView.rightImageView.image = [UIImage imageNamed:@"collected"];
                    [CollectSucView showCollectSucViewInView:self.view];
                    if (_CollectCallBack) {
                        _CollectCallBack(_goodsDetails);
                    }
                }
                
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            } showMessage:YES];
            // 已收藏 取消收藏
        } else {
            NSString *goodsid = [_goodsDetails stringForKey:@"id"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": _shopId};
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:param tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
                float flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [self.view makeToast:@"已取消收藏！"];
                    [_goodsDetails setValue:@"N" forKey:@"isCollect"];
                    WSTabSlideGapTextItemView *itemView = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
                    itemView.rightImageView.image = [UIImage imageNamed:@"uncollect"];
                    if (_CollectCallBack) {
                        _CollectCallBack(_goodsDetails);
                    }
                }
            } failCallBack:^(id error) {
                [SVProgressHUD showErrorWithStatus:@"操作失败！" duration:TOAST_VIEW_TIME];
            } showMessage:YES];
            
        }
    } else {
        [WSUserUtil actionAfterLogin:^{
            [self requestProductDetail];
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"打开网页出错！" duration:TOAST_VIEW_TIME];
}

@end
