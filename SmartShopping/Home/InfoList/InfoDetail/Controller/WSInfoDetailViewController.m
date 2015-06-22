//
//  WSInfoDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInfoDetailViewController.h"

@interface WSInfoDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WSInfoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"消息详情";
//    [self requestInfoDetail];
//    NSString *content= [_dic objectForKey:@"content"];
//    if (content.length > 0) {
//        [_webView loadHTMLString:content baseURL:[[NSBundle mainBundle] bundleURL]];
//    }
    NSString *url = [WSInterfaceUtility getURLWithType:WSInterfaceTypeFindMessageDetail];
    NSString *detailID = [_dic stringForKey:@"id"];
    NSString *allURL = [NSString stringWithFormat:@"%@?id=%@", url, detailID];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:allURL]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestInfoDetail
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[_dic objectForKey:@"id"] forKey:@"id"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeFindMessageDetail] data:param tag:WSInterfaceTypeFindMessageDetail sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            
        }
    } failCallBack:^(id error) {
        
    } showMessage:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[SVProgressHUD showErrorWithStatus:@"打开网页出错！" duration:TOAST_VIEW_TIME];
}

@end
