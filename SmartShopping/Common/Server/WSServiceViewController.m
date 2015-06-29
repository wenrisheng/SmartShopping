//
//  WSProjViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSServiceViewController ()


@end

@implementation WSServiceViewController

- (void)dealloc
{
    _service.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserBeanNumber:) name:UPDATE_USER_BEANNUMER object:nil];
    [self initService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    WSUser *user = [WSProjUtil getCurUser];
    // 每天打开app
    [WSProjUtil synchronOpenAppBeanNumWithUser:user callBack:^{
        
    }];
    [WSProjUtil synchronFirstUsedBeanNumWithUser:user callBack:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 更新精明豆通知
- (void)updateUserBeanNumber:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    WSUser *user = [userInfo objectForKey:USER_KEY];
    if (user) {
        [WSRunTime sharedWSRunTime].user = user;
        NSString *userType = user.userType;
        if ([userType isEqualToString:@"1"]) {
            [WSProjUtil archiverUser:user key:USER_KEY];
        } else {
             [WSProjUtil archiverUser:user key:TOURIST_KEY];
        }
    }
}

#pragma mark - 初始化服务
- (void)initService
{
    _service = [[WSService alloc] init];
    _service.delegate = self;
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    
}

- (void)requestFail:(id)error tag:(int)tag
{
    
}

@end
