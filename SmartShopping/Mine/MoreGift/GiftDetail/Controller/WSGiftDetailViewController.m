//
//  WSGiftDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGiftDetailViewController.h"
#import "WSGiftOrderWriterViewController.h"

@interface WSGiftDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)converButAction:(id)sender;

@end

@implementation WSGiftDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"礼品详情";
    NSURL *url =[NSURL URLWithString:_url];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
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

- (IBAction)converButAction:(id)sender
{
    WSGiftOrderWriterViewController *orderWriterVC = [[WSGiftOrderWriterViewController alloc] init];
    [self.navigationController pushViewController:orderWriterVC animated:YES];
}
@end
