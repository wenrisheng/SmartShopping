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
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    time = 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - timeAction
- (void)timeAction:(NSTimer *)t
{
    if (time >= 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%ds", time];
        time -- ;
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
