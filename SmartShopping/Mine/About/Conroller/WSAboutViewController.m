//
//  WSAboutViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSAboutViewController.h"

@interface WSAboutViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation WSAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"关于";
    [self requestUserProtocol];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestUserProtocol
{
    [SVProgressHUD showWithStatus:@"正在请求数据……"];
    NSDictionary *dic = @{@"title" : @"关于"};
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserAgreeAbout] data:dic tag:WSInterfaceTypeUserAgreeAbout sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
         NSDictionary *data = [result objectForKey:@"data"];
        NSString *memo = [[data objectForKey:@"agreeAbout"] objectForKey:@"memo"];
        _label.text = memo;
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"请求失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

@end
