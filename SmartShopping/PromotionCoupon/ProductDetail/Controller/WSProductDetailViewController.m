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

@interface WSProductDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;
@property (strong, nonatomic) NSDictionary *goodsDetails;

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
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetGoodsDetails] data:params tag:WSInterfaceTypeGetGoodsDetails sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            self.goodsDetails = [[result objectForKey:@"data"] objectForKey:@"goodsDetails"];
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
    NSString *Isscan = [_goodsDetails stringForKey:@"isscan"];
    // 可以扫描
    if ([Isscan isEqualToString:@"1"]) {
        _hasScan = YES;
        titleArray = @[@"收藏", @"扫描", @"分享"];
        imageArray = @[@"colleation-011", @"scanning", @"share"];
    } else {
        _hasScan = NO;
        titleArray = @[@"收藏", @"分享"];
        imageArray = @[@"colleation-011", @"share"];
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
    _tabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        switch (index) {
                //收藏
            case 0:
            {
                WSUser *user = [WSRunTime sharedWSRunTime].user;
                if (user) {
                    NSDictionary *param = @{@"uid": user._id, @"goodsid": [_goodsDetails objectForKey:@"id"]};
                    [SVProgressHUD show];
                    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                        [SVProgressHUD dismiss];
                        BOOL flag = [WSInterfaceUtility validRequestResult:result];
                        if (flag) {
                            [CollectSucView showCollectSucView];
                        }
                    } failCallBack:^(id error) {
                        
                    }];
                } else {
                    [WSUserUtil actionAfterLogin:^{
                        
                    }];
                }
            }
                break;
                // 扫描或分享
            case 1:
            {
                // 扫描
                if (_hasScan) {
                    WSScanProductViewController *scanProductVC = [[WSScanProductViewController alloc] init];
                    [self.navigationController pushViewController:scanProductVC animated:YES];
                // 分享
                } else {
                    
                }
            }
                break;
                //分享
            case 2:
            {
                
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
    if (user) {
        NSString *goodsid = [_goodsDetails objectForKey:@"id"];
        NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": _shopId};
        [SVProgressHUD show];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [CollectSucView showCollectSucView];
            }
        } failCallBack:^(id error) {
            [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
        }];
    } else {
        [WSUserUtil actionAfterLogin:^{
          
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
