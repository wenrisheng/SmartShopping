//
//  WSPromotionCouponInStoreCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/23.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponOutStoreCollectionViewCell.h"

@implementation WSPromotionCouponOutStoreCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    NSArray *array = @[_leftProductView, _rightProductView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.867 green:0.875 blue:0.878 alpha:1.000] cornerRadius:5];
    }
}

@end
