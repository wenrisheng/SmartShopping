//
//  HomeCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOMECOLLECTIONVIEWCELL_HEIGHT                  230
#define HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL              211

#define HOMECOLLECTIONVIEWCELL_IMAGE_HEIGHT_SMALL       131
#define HOMECOLLECTIONVIEWCELL_IMAGE_WIDTH              130.0

@class HomeCollectionViewCell;
@protocol HomeCollectionViewCellDelegate <NSObject>

@optional
- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidClickDistanceBut:(HomeCollectionViewCell *)cell;

@end

@interface HomeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSMutableDictionary *dic;

@property (copy) void(^refreshPage)(void); // 点击收藏时没登陆时登陆后刷新页面

@property (copy) void(^downloadImageFinish)(void);

- (void)setModel:(NSDictionary *)modelDic;

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

- (IBAction)productButAction:(id)sender;
- (IBAction)distanceButAction:(id)sender;
- (IBAction)collectButAction:(id)sender;
- (IBAction)shareButAction:(id)sender;



@end
