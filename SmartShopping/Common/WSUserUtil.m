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
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
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
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        return user.beanNumber;
    } else{
        int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
        return [NSString stringWithFormat:@"%d", appPeasNum];

    }
}

@end
