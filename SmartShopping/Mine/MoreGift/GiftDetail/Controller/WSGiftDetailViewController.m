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

@property (strong, nonatomic) NSDictionary *gift;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)converButAction:(id)sender;

@end

@implementation WSGiftDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _navigationBarManagerView.navigationBarButLabelView.label.text = @"礼品详情";
    [SVProgressHUD showWithStatus:REQUESTING_TIP];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetGiftDetails] data:@{@"giftId": _giftId} tag:WSInterfaceTypeGetGiftDetails sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            self.gift = [[result objectForKey:@"data"] objectForKey:@"gift"];
            NSString *giftDetails = [_gift objectForKey:@"giftDetails"];
            NSURL *baseURL =[[NSBundle mainBundle] bundleURL];
            [_webView loadHTMLString:giftDetails baseURL:baseURL];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:REQUEST_FAIL_TIP afterDelay:TOAST_VIEW_TIME];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSString *)converHtmlWithImageURL:(NSString *)imageURL detail:(NSString *)detail
//{
//    NSString *imageDIV = [NSString stringWithFormat:@"<div><img src=\"%@\" /></div>", imageURL];
//    NSRange range = [detail rangeOfString:@"<body>"];
//    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"%@", detail];
//    if (range.location == NSNotFound) {
//        [result insertString:imageDIV atIndex:0];
//    } else {
//        [result insertString:imageDIV atIndex:range.location + range.length];
//    }
//    return result;
//}


#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"打开网页出错！" duration:TOAST_VIEW_TIME];
}

- (IBAction)converButAction:(id)sender
{
    if (_gift) {
        [WSUserUtil actionAfterLogin:^{
            // 礼品所需的精明豆
           int unitNum = [[_gift stringForKey:@"amount"] intValue];
            
            // 当前用户的精明豆
            WSUser *user = [WSRunTime sharedWSRunTime].user;
            int currentPeaNum = [user.beanNumber intValue];
            if (unitNum > currentPeaNum) {
                [SVProgressHUD showErrorWithStatus:@"亲，您当前的精明豆不够兑换哦！" duration:TOAST_VIEW_TIME];
            } else {
                WSGiftOrderWriterViewController *orderWriterVC = [[WSGiftOrderWriterViewController alloc] init];
                orderWriterVC.gift = self.gift;
                [self.navigationController pushViewController:orderWriterVC animated:YES];
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"数据加载错误！" duration:TOAST_VIEW_TIME];
    }
}

@end
