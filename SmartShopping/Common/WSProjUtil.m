//
//  WSProjUtil.m
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProjUtil.h"

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
    NSString *resultStr = [NSString stringWithFormat:@"%.1fm", distanceFloat];
    return resultStr;
}

+ (void)isInStoreWithIsInStoreType:(IsInStoreType)type callback:(void (^)(id result))callback
{
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    double longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    double latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    NSDictionary *params = @{@"lon": [NSString stringWithFormat:@"%f", latitude], @"lat": [NSString stringWithFormat:@"%f", longtide]};
    switch (type) {
            // 促销优惠
        case IsInStoreTypePromotionCoupon:
        {
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeIsInshopByPromotions] data:params tag:WSInterfaceTypeIsInshopByPromotions sucCallBack:^(id result) {
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
            } showMessage:YES];
        }
            break;
            // 赚取精明豆
        case IsInStoreTypeGainPea:
        {
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSsInshopBySign] data:params tag:WSInterfaceTypeSsInshopBySign sucCallBack:^(id result) {
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
            } showMessage:YES];
        }
            break;
        default:
            break;
    }
    
}

@end
