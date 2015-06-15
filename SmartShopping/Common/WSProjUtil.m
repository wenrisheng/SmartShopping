//
//  WSProjUtil.m
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProjUtil.h"
#import "IBSDK.h"

@implementation WSProjUtil

+ (int)gerRandomColor
{
    return [WSBaseUtil getRandomNumber:1 to:4];
}

+ (UINavigationController *)getRootNav
{
    AppDelegate *appDelegate = APP_DELEGATE;
    return appDelegate.nav;
}

+ (NSString *)converDateWithDateStr:(NSString *)dateStr
{
    if (!dateStr) {
        return @"有效日期未知";
    }
    NSArray *array = [dateStr componentsSeparatedByString:@"-"];
    if (array.count < 3) {
        return  @"有效日期未知";
    }
    NSString *month = [array objectAtIndex:1];
    int monthInt = [month intValue];
    NSString *day = [array objectAtIndex:2];
    int dayInt = [day intValue];
    NSString *result = [NSString stringWithFormat:@"%d月%d日前有效", monthInt, dayInt];
    return result;
}

+ (NSString *)converDistanceWithDistanceStr:(NSString *)distance
{
    float distanceFloat = [distance floatValue];
    NSString *resultStr = [NSString stringWithFormat:@"%.1fkm", distanceFloat];
    return resultStr;
}

+ (void)isInStoreWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ibeacon) {
        NSString *beaconUUID = [ibeacon.proximityUUID UUIDString];
        [param setValue:beaconUUID forKey:@"uuid"];
        [param setValue:ibeacon.major forKey:@"major"];
        [param setValue:ibeacon.minor forKey:@"minor"];
    }
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    double longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    double latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [param setValue:user.uid forKey:@"uid"];
    }
    [param setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lon"];
    [param setValue:[NSString stringWithFormat:@"%f", longtide] forKey:@"lat"];
    [param setValue:ibeacon forKey:@"ibeacon"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeIsInShopAndIsScans] data:param tag:WSInterfaceTypeIsInShopAndIsScans sucCallBack:^(id result) {
    
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *isInShopDic = [[result objectForKey:@"data"] objectForKey:@"isInShop"];
            NSString *isinshop = [isInShopDic stringForKey:@"isinshop"];
            // 在店内
            if ([isinshop isEqualToString:@"Y"]) {
                [resultDic setValue:[NSNumber numberWithBool:YES] forKey:IS_IN_SHOP_FLAG];
                //不在店内
            } else {
                [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
            }
            [resultDic setValue:isInShopDic forKey:IS_IN_SHOP_DATA];
            // 校验数据有错也表示不在店内
        } else {
            [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        }
        
        // 回调
        if (callback) {
            callback(resultDic);
        }
        
    } failCallBack:^(id error) {
        [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        if (callback) {
            callback(resultDic);
        }
        [SVProgressHUD dismiss];
    } showMessage:YES];
}


@end
