//
//  WSScanAfterViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSScanAfterViewController.h"

@interface WSScanAfterViewController () <UIWebViewDelegate>
{
    NSTimer *timer;
    int time;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationgBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation WSScanAfterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationgBarManagerView.navigationBarButLabelView.label.text = @"商品详情";
   // [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    time = 10;
     timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    [self requestProductDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestProductDetail
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (_goodsId.length > 0) {
        [params setValue:_goodsId forKey:@"goodsId"];
    }
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_shopid forKey:@"shopid"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetGoodsDetails] data:params tag:WSInterfaceTypeGetGoodsDetails sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *goodsDetails = [[result objectForKey:@"data"] objectForKey:@"goodsDetails"];
            id h5url  = [goodsDetails objectForKey:@"h5url"];
            h5url = h5url == nil ? @"" : h5url;
            BOOL flag = [h5url isKindOfClass:[NSNull class]];
            h5url =  flag ? @"" : h5url;
            NSURL *url =[NSURL URLWithString:h5url];
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            [_webView loadRequest:request];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

#pragma mark - timeAction
- (void)timeAction:(NSTimer *)t
{
    if (time >= 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%ds", time];
        time -- ;
        WSUser *user = [WSRunTime sharedWSRunTime].user;
        NSString *beanNumber = user.beanNumber;
        int allBea = [beanNumber intValue] + [_beanNum intValue];
        user.beanNumber = [NSString stringWithFormat:@"%d", allBea];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber":user.beanNumber} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
 
        } failCallBack:^(id error) {
            
        }];

    } else {
        _bottomView.hidden = YES;
        [timer invalidate];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
}

@end
