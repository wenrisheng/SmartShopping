//
//  WSProductDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProductDetailViewController.h"

@interface WSProductDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;

@end

@implementation WSProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"商品详情";
    NSArray *titleArray = nil;
    NSArray *imageArray = nil;
    if (_hasScan) {
        titleArray = @[@"收藏", @"扫描", @"分享"];
        imageArray = @[@"colleation-011", @"scanning", @"share"];
    } else {
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

@end
