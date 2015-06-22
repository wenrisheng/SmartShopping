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
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//#define UUID                          [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] //E2C56DB5-
#define UUID [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]
#define IBEACON_DISTANCE_VALUE        1.00   // iBeacon有效距离
#define IBEACON_SCAN_TIME             5     // 扫描iBeacon的时间

@interface WSRunTime : NSObject <CLLocationManagerDelegate>


@property (assign, nonatomic) BOOL hasIbeacon;
@property (strong, nonatomic) NSTimer *timer;
@property (copy) void (^callback)(NSArray *beaconsArray);
@property (strong, nonatomic) IBSDK *ibSDK;
@property (strong, nonatomic) WSUser *user;

@property (strong, nonatomic) NSTimer *validiBeaconTimer;
@property (nonatomic, strong) CLLocationManager* beaconManager; // iBeacon管理类
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;    // iBeacon区域
@property (strong, nonatomic) NSMutableArray *allBeaconInfoArray;
@property (nonatomic, strong) CLBeacon *validBeacon;           // 有效距离的iBeacon
@property (copy) void (^validiBeaconCallBack)(CLBeacon *beacon);     // 发现有效iBeacon回调

+ (WSRunTime *)sharedWSRunTime;

//开始定位检测
-(void)startLocation;
//停止定位检测
-(void)stopLocation;

- (void)findIbeaconWithCallback:(void (^)(NSArray *beaconsArray))callback;

- (void)findValidIbeaconWithCallBack:(void (^)(CLBeacon *beacon))iBeaconCallBack;

@end
