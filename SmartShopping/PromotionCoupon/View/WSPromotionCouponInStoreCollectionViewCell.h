//
//  HomeCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSPromotionCouponInStoreCollectionViewCell_HEIGHT          200
#define WSPromotionCouponInStoreCollectionViewCell_HEIGHT_SMALL    160

@class WSPromotionCouponInStoreCollectionViewCell;
@protocol WSPromotionCouponInStoreCollectionViewCellDelegate <NSObject>

@optional
- (void)WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:(WSPromotionCouponInStoreCollectionViewCell *)cell;
- (void)WSPromotionCouponInStoreCollectionViewCellDidClickRightBut:(WSPromotionCouponInStoreCollectionViewCell *)cell;

@end

@interface WSPromotionCouponInStoreCollectionViewCell : UICollectionViewCell

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) id<WSPromotionCouponInStoreCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *conView;
@property (weak, nonatomic) IBOutlet UILabel *validDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@end
