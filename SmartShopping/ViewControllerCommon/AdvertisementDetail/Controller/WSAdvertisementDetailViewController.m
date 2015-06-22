//
//  WSAdvertisementDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSAdvertisementDetailViewController.h"

@interface WSAdvertisementDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *naviagationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WSAdvertisementDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _naviagationBarManagerView.navigationBarButLabelView.label.text = @"广告详情";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_dic objectForKey:@"third_link"]]]];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[_dic stringForKey:@"id"] forKey:@"adsid"];
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    NSString *city = [locationDic objectForKey:LOCATION_CITY];
    city = city.length > 0 ? city : @"";
    [param setValue:city forKey:@"cityName"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [param setValue:user._id forKey:@"uid"];
    }
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeClickAdvert] data:param tag:WSInterfaceTypeClickAdvert sucCallBack:^(id result) {
        
    } failCallBack:^(id error) {
        
    } showMessage:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
}

@end
