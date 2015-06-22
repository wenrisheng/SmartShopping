//
//  WSRunTime.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSRunTime.h"
#import "SynthesizeSingleton.h" 



@implementation WSRunTime

SYNTHESIZE_SINGLETON_FOR_CLASS(WSRunTime);

- (void)findIbeaconWithCallback:(void (^)(NSArray *beaconsArray))callback
{
    [SVProgressHUD showWithStatus:@"正在扫描iBeacon……"];
    self.hasIbeacon = NO;
    self.callback = callback;
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(chectoutIbeacon:) userInfo:nil repeats:YES];
#if !TARGET_IPHONE_SIMULATOR
    if (!_ibSDK) {
       self.ibSDK = [[IBSDK alloc] init];
    }
    [_ibSDK startLocation];
#endif
    // 延迟5秒执行：
    double delayInSeconds = IBEACON_SCAN_TIME;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //  [SVProgressHUD dismissWithError:@"亲，请确认蓝牙是否已经开启！" afterDelay:TOAST_VIEW_TIME];
        [SVProgressHUD dismiss];
        [self.timer invalidate];
        if (!self.hasIbeacon) {
            if (callback) {
                callback(nil);
            }
        }
    });
}

- (void)chectoutIbeacon:(NSTimer *)timer
{
    NSArray *ibeaconArray = _ibSDK.beaconsArray;
    if (ibeaconArray.count > 0) {
        [SVProgressHUD dismiss];
        [self.timer invalidate];
        [_ibSDK stopLocation];
        self.hasIbeacon = YES;
        if (_callback) {
            _callback(ibeaconArray);
        }
    }
}


//开始定位检测
-(void)startLocation
{
    if (!_allBeaconInfoArray) {
        self.allBeaconInfoArray = [[NSMutableArray alloc] init];
    }
    if (!_beaconManager) {
        self.beaconManager = [[CLLocationManager alloc] init];
        _beaconManager.delegate = self;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.9) {
            [_beaconManager requestAlwaysAuthorization];//设置location是一直允许
            
        }
    }
    if (_beaconRegion == nil) {
        _beaconRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:UUID
                         identifier:@"INNO"];
        [self.beaconManager startRangingBeaconsInRegion:_beaconRegion];
        
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        [_beaconManager startMonitoringForRegion:_beaconRegion];
        [_beaconManager requestStateForRegion:_beaconRegion];
    }

}

//停止定位检测
-(void)stopLocation
{
    if (_beaconRegion != nil) {
        [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
        _beaconRegion = nil;
        
    }
}

//对检测到的beacon进行近到远排序
-(NSArray *)sortBeaconsByDistance:(NSArray *)aBeaconsArray {
    NSArray *beacons;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"proximity==%d || proximity==%d",CLProximityNear, CLProximityImmediate];
    beacons = [aBeaconsArray filteredArrayUsingPredicate:predicate];
    

    //距离值再过滤
    NSPredicate *distPredicate = [NSPredicate predicateWithFormat:@"accuracy<%f", IBEACON_DISTANCE_VALUE];
    beacons = [beacons filteredArrayUsingPredicate:distPredicate];
    
    //距离值从小到大排序
    if([beacons count]>1){
        NSLog(@"多个Beacon,将进行排序");
        //返回一个按距离由近到远排序的数组
        beacons=[beacons sortedArrayUsingComparator:
                 ^NSComparisonResult(CLBeacon* obj1, CLBeacon* obj2){
                     if (obj1.accuracy >obj2.accuracy ) {
                         return NSOrderedDescending;
                     }
                     if (obj1.accuracy<obj2.accuracy) {
                         return NSOrderedAscending;
                     }
                     return  NSOrderedSame;
                 }];
    }
    return beacons;
}

#pragma mark- CLLocationManagerDelegate Estimote协议

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    if([beacons count] > 0) {
        NSLog(@"当前区域内有%d个beacon", (int)[beacons count]);
        
        if ([beacons count] > 0) {
            [self dealScanBeacon:beacons];
        }
        
        NSArray *validBeacons = [self sortBeaconsByDistance:beacons];
        if ([validBeacons count] > 0) {
            
            //这里MYLink程序可以发送哪位用户进入舱体信息给PC端。
            CLBeacon *beacon = [validBeacons objectAtIndex:0];
            
            // 有效距离iBeacon
            self.validBeacon = beacon;
            if ([beacon.minor integerValue] == 5) { //A
        
            } else if ([beacon.minor integerValue] == 6) { //B
            
            }
        }
    }
}

- (void)dealScanBeacon:(NSArray *)beaconArray
{
    // 遍范围内的有效beacon
    for (CLBeacon *beacon in beaconArray) {
        // 如果ibeacon信息字典数组为空则全部加到数组去
        if (_allBeaconInfoArray.count == 0) {
            NSMutableDictionary *beaconDic = [NSMutableDictionary dictionary];
            [beaconDic setValue:beacon forKey:IBEACON_KEY];
            [beaconDic setValue:[NSNumber numberWithDouble:beacon.accuracy] forKey:IBEACON_DISTANCE];
            [_allBeaconInfoArray addObject:beaconDic];
            
            // 请求beacon的推送文本等信息
            [self requestBeaconInfo:beaconDic];
        //
        } else {
            
            // beacon是否已在ibeacon信息字典数组中，如果不在则加进去
            BOOL isInArray = NO;
            for (NSDictionary *beaconDic in _allBeaconInfoArray) {
                CLBeacon *beacon1 = [beaconDic objectForKey:IBEACON_KEY];
                BOOL flag = [self isTheSameBeacon:beacon1 :beacon];
                // 在在ibeacon信息字典数组，则更新距离
                if (flag) {
                    isInArray = YES;
                    [beaconDic setValue:[NSNumber numberWithDouble:beacon.accuracy] forKey:IBEACON_DISTANCE];
                    break;
                }
            }
            // 不在ibeacon信息字典数组
            if (!isInArray) {
                NSMutableDictionary *beaconDic = [NSMutableDictionary dictionary];
                [beaconDic setValue:beacon forKey:IBEACON_KEY];
                [beaconDic setValue:[NSNumber numberWithDouble:beacon.accuracy] forKey:IBEACON_DISTANCE];
                [_allBeaconInfoArray addObject:beaconDic];
                
                // 请求beacon的推送文本等信息
                [self requestBeaconInfo:beaconDic];
            }
           
        }
    }
}

- (void)requestBeaconInfo:(NSMutableDictionary *)beaconDic
{
    CLBeacon *beacon = [beaconDic objectForKey:IBEACON_KEY];
    NSString *UUIDString = beacon.proximityUUID.UUIDString;
    NSString *major = [beacon.major stringValue];
    NSString *minor = [beacon.minor stringValue];
    
    // 请求beacon 的推送文本等时间信息
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetOneIbeacon] data:@{@"uuid": UUIDString, @"major": major, @"minor": minor} tag:WSInterfaceTypeGetOneIbeacon sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResultNoErrorMsg:result];
        if (flag) {
            NSDictionary *beaconInfoDic = [[result objectForKey:@"data"] objectForKey:@"ibeacon"];
            [beaconDic setValue:beaconInfoDic forKey:IBEACON_INFO];
            NSString *stoptime = [beaconInfoDic stringForKey:@"beaconInfoDic"];
            
            // stoptime秒后是否还在有效距离内：
            double delayInSeconds = [stoptime doubleValue];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                double distance = [[beaconDic objectForKey:IBEACON_DISTANCE] doubleValue];
                NSString *validDistance = [beaconInfoDic stringForKey:@"distance"];
                double validDistanceDouble = [validDistance doubleValue];
                // 在有效距离内则发送本地通知
                if (distance <= validDistanceDouble) {
                    NSString *title = [beaconInfoDic objectForKey:@"beaconInfoDic"];
                    title = title.length > 0 ? title : @"精明购";
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = title;
                    notification.userInfo = @{IBEACON_INFO: beaconInfoDic};
                    notification.soundName =UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            });

        }
        
    } failCallBack:^(id error) {
        
    } showMessage:NO];
}

- (BOOL)isTheSameBeacon:(CLBeacon *)beacon1 :(CLBeacon *)beacon2
{
    NSString *UUIDString1 = beacon1.proximityUUID.UUIDString;
    NSString *marjor1 = [beacon1.major stringValue];
    NSString *minor1 = [beacon1.minor stringValue];
    
    NSString *UUIDString2 =  beacon2.proximityUUID.UUIDString;
    NSString *marjor2 = [beacon2.major stringValue];
    NSString *minor2 = [beacon2.minor stringValue];
    
    if ([UUIDString1 isEqualToString:UUIDString2] && [marjor1 isEqualToString:marjor2] && [minor1 isEqualToString:minor2]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"欢迎光临！";
    notification.soundName =UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"你已经离开，欢迎再次光临！";
    notification.soundName =UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)findValidIbeaconWithCallBack:(void (^)(CLBeacon *beacon))iBeaconCallBack
{
    // 缓存回调
    self.validiBeaconCallBack = iBeaconCallBack;
    
    // 将以前扫描的有效iBeacon清空
    self.validBeacon = nil;
    
    // 开启计时器
    self.validiBeaconTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(findValidIbeaconAction:) userInfo:nil repeats:YES];
    
    // 
    double delayInSeconds = IBEACON_SCAN_TIME;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // 停止计时器
        [self.validiBeaconTimer invalidate];
        self.validiBeaconTimer = nil;
        if (_validiBeaconCallBack) {
            _validiBeaconCallBack(_validBeacon);
        }
    });
    
}

- (void)findValidIbeaconAction:(NSTimer *)timer
{
    if (_validBeacon) {
        // 停止计时器
        [timer invalidate];
        self.validiBeaconTimer = nil;
        
        // 回调
        if (_validiBeaconCallBack) {
            _validiBeaconCallBack(_validBeacon);
            self.validiBeaconCallBack = nil;
        }
    }
}

@end
