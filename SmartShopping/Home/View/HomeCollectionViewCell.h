//
//  HomeCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOMECOLLECTIONVIEWCELL_HEIGHT          212
#define HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL    180

@class HomeCollectionViewCell;
@protocol HomeCollectionViewCellDelegate <NSObject>

- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell;

@end

@interface HomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<HomeCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *conView;
@property (weak, nonatomic) IBOutlet UILabel *validDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;

@end
