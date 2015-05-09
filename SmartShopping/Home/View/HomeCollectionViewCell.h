//
//  HomeCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOMECOLLECTIONVIEWCELL_HEIGHT          250
#define HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL    212

@class HomeCollectionViewCell;
@protocol HomeCollectionViewCellDelegate <NSObject>

- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidClickDistanceBut:(HomeCollectionViewCell *)cell;

@end

@interface HomeCollectionViewCell : UICollectionViewCell

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) id<HomeCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *conView;
@property (weak, nonatomic) IBOutlet UILabel *validDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;
@property (weak, nonatomic) IBOutlet UIButton *distanceBut;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@end
