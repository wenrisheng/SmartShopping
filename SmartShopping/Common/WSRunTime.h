//
//  WSRunTime.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSUser.h"

@interface WSRunTime : NSObject

+ (WSRunTime *)sharedWSRunTime;

@property (strong, nonatomic) WSUser *user;


@end
