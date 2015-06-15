//
//  WSPromotionCouponInStoreCollectionReusableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/23.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSPROMOTIONCOUPON_INSTORE_COLLECTIONREUSABLEVIEW_HEIGHT   95

@interface WSPromotionCouponInStoreCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *loginImageView;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupBut;
@property (weak, nonatomic) IBOutlet UIImageView *signupImageView;
@property (weak, nonatomic) IBOutlet UIButton *distanceBut;

@end
