//
//  WSRunTime.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSUser.h"
#import "IBSDK.h"

@interface WSRunTime : NSObject


@property (assign, nonatomic) BOOL hasIbeacon;
@property (strong, nonatomic) NSTimer *timer;
@property (copy) void (^callback)(NSArray *beaconsArray);
@property (strong, nonatomic) IBSDK *ibSDK;
@property (strong, nonatomic) WSUser *user;

+ (WSRunTime *)sharedWSRunTime;

- (void)findIbeaconWithCallback:(void (^)(NSArray *beaconsArray))callback;

@end
