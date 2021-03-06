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

+ (void)showGainBeanNumWithBeanNum:(NSString *)beanNumber inView:(UIView *)view callback:(void (^)(void))callback;

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
 *  用户是否在店内(此接口只用来签到，判断是否在店内，是否可以签到)
 *
 *  @param ibeacon
 *  @param callback
 */
+ (void)isInStoreWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback;

/**
 *  判断用户是否在店内，是否可以扫描
 *
 *  @param ibeacon
 *  @param synchronBeanNumWithUser
 *  @param user
 *  @param beanNumber
 *  @param callback
 */
+ (void)isInShopAndIsScanWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback;

/**
 *  同步用户精明豆
 *
 *  @param beanNumber 精明豆增量
 *  @param callback   回调
 */
+ (void)synchronBeanNumWithUser:(WSUser *)user offsetBeanNumber:(NSString *)beanNumber callBack:(void (^)())callback;

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

+ (WSUser *)convertDicToUser:(NSDictionary *)dic;

/**
 *  归档
 *
 *  @param obj
 */
+ (void)archiverUser:(id)obj key:(NSString *)key;

/**
 *  解归档
 *
 *  @param key
 *
 *  @return
 */
+ (id)unarchiverUserWithKey:(NSString *)key;

+ (WSUser *)getCurUser;

+ (NSString *)getCurUserId;

@end
