//
//  WSProjUtil.h
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_IN_SHOP_FLAG         @"is_in_shop_flag"
#define IS_IN_SHOP_DATA         @"is_in_shop_data"

typedef NS_ENUM(NSInteger, IsInStoreType) {
    IsInStoreTypePromotionCoupon = 0,   // 促销优惠
    IsInStoreTypeGainPea               // 赚取精明都
};
@interface WSProjUtil : NSObject

+ (int)gerRandomColor;

+ (UINavigationController *)getRootNav;

/**
 *  日期转换
 *
 *  @param dateStr
 *
 *  @return
 */
+ (NSString *)converDateWithDateStr:(NSString *)dateStr;

/**
 *  距离转换
 *
 *  @param distance
 *
 *  @return
 */
+ (NSString *)converDistanceWithDistanceStr:(NSString *)distance;

/**
 *  是否在店内
 *
 *  @param ibeacon
 *  @param callback
 */
+ (void)isInStoreWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback;

/**
 *  同步用户精明豆
 *
 *  @param beanNumber 精明豆增量
 *  @param callback   回调
 */
+ (void)synchronBeanNumWithUser:(WSUser *)user beanNumber:(NSString *)beanNumber callBack:(void (^)())callback;

/**
 *  同步每天打开获取精明豆
 *
 *  @param user
 *  @param callback
 */
+ (void)synchronOpenAppBeanNumWithUser:(WSUser *)user callBack:(void (^)())callback;

/**
 *  同步首次打开app获取精明豆
 *
 *  @param user
 *  @param callback
 */
+ (void)synchronFirstUsedBeanNumWithUser:(WSUser *)user callBack:(void (^)())callback;

@end
