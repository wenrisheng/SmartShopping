//
//  WSProjViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSBaseViewController.h"

@interface WSServiceViewController : WSBaseViewController <ServiceDelegate>

@property (strong, nonatomic) WSService *service;

// 初始化服务
- (void)initService;

@end
