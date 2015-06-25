//
//  WSProductDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInfoGoodDetailViewController.h"
#import "CollectSucView.h"
#import "WSScanProductViewController.h"
#import "WSScanAfterViewController.h"

@interface WSInfoGoodDetailViewController () <UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;
@property (strong, nonatomic) NSMutableDictionary *goodsDetails;

@end

@implementation WSInfoGoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"消息详情";
    [self requestProductDetail];
}

- (void)requestProductDetail
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeMessageGoodsDetails] data:@{@"goodsNumber": [_dic stringForKey:@"goodsNumber"]} tag:WSInterfaceTypeMessageGoodsDetails sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *goodsMsg = [[result objectForKey:@"data"] objectForKey:@"goodsMsg"];
            NSString *h5url = [goodsMsg objectForKey:@"h5url"];
            NSURL *url =[NSURL URLWithString:h5url];
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            [_webView loadRequest:request];
        }
    } failCallBack:^(id error) {
       
    } showMessage:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
   // [SVProgressHUD showErrorWithStatus:@"打开网页出错！" duration:TOAST_VIEW_TIME];
}

@end
