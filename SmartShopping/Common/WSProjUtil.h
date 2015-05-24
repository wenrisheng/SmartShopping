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

+ (NSString *)converDateWithDateStr:(NSString *)dateStr;
+ (NSString *)converDistanceWithDistanceStr:(NSString *)distance;

+ (void)isInStoreWithIsInStoreType:(IsInStoreType)type callback:(void (^)(id result))callback;

@end
