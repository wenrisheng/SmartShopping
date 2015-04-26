//
//  WSPromotionCouponInStoreCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/23.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSPROMOTION_COUPON_OUTSTORE_COLLECTIONVIEW_CELL_HEIGHT    272

@interface WSPromotionCouponOutStoreCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *loginImageView;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupBut;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *seeMoreBut;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftScanImageView;
@property (weak, nonatomic) IBOutlet UIButton *leftCollectBut;
@property (weak, nonatomic) IBOutlet UIButton *leftShareBut;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightScanImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightCollectBut;
@property (weak, nonatomic) IBOutlet UIButton *rightShareBut;
@property (weak, nonatomic) IBOutlet UIView *leftProductView;
@property (weak, nonatomic) IBOutlet UIView *rightProductView;

@end
