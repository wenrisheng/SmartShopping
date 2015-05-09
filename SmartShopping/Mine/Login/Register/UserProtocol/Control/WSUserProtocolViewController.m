//
//  WSUserProtocolViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSUserProtocolViewController.h"

@interface WSUserProtocolViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WSUserProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"用户协议";
    
    [self requestUserProtocol];
}

- (void)requestUserProtocol
{
    [SVProgressHUD showWithStatus:@"正在请求数据……"];
    NSDictionary *dic = @{@"title" : @"用户协议"};
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserAgreeAbout] data:dic tag:WSInterfaceTypeUserAgreeAbout];
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
    
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    [SVProgressHUD dismiss];
    BOOL flag = [WSInterfaceUtility validRequestResult:result];
    if (flag) {
        NSDictionary *data = [result objectForKey:@"data"];
        NSString *htmlStr = [[data objectForKey:@"agreeAbout"] objectForKey:@"memo"];
        [self.webView loadHTMLString:htmlStr baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}

- (void)requestFail:(id)error tag:(int)tag
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"请求数据失败！" duration:TOAST_VIEW_TIME];
}

@end
