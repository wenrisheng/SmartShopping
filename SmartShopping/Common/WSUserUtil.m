//
//  WSUserUtil.m
//  SmartShopping
//
//  Created by wrs on 15/5/5.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSUserUtil.h"
#import "WSLoginViewController.h"

@implementation WSUserUtil

+ (void)actionAfterLogin:(void(^)(void))action
{
    WSUser *user = [WSProjUtil getCurUser];
    NSString *userType = user.userType;
    if ([userType isEqualToString:@"1"]) {
        if (action) {
            action();
        }
    } else {
        AppDelegate *appDelegate = APP_DELEGATE;
        UINavigationController *rootNav = appDelegate.nav;
        WSLoginViewController *loginVC = [[WSLoginViewController alloc] init];
        loginVC.callBack = ^() {
            if (action) {
                action();
            }
        };
        [rootNav pushViewController:loginVC animated:YES];
    }
}

+ (NSString *)getUserPeasNum
{
    WSUser *user = [WSProjUtil getCurUser];
    if (user) {
        if (user.beanNumber.length <= 0) {
            return @"0";
        }
        return user.beanNumber;
    } else{
        return @"0";
    }
}

+ (void)synchronUserPeaToServe
{
    [SVProgressHUD showWithStatus:@"正在同步精明豆……"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber":user.beanNumber} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
    } failCallBack:^(id error) {
          [SVProgressHUD dismissWithError:@"同步失败！" afterDelay:TOAST_VIEW_TIME];
    } showMessage:NO];
}

@end
