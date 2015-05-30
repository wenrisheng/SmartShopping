//
//  WSGuideViewController.h
//  SmartShopping
//
//  Created by wrs on 15/5/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSBaseViewController.h"

@interface WSGuideViewController : WSBaseViewController

@property (copy) void(^endCallBack)(void);
@property (strong, nonatomic) NSArray *imageArray;

@end
