//
//  WSRunTime.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSRunTime.h"
#import "SynthesizeSingleton.h" 

#define IBEACON_SCAN_TIME  10

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

@end
