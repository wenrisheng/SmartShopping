//
//  WSMineCollectCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WSMINECOLLECTCOLLECTIONVIEWCELL_HEIGHT            182
#define WSMINECOLLECTCOLLECTIONVIEWCELL_HEIGHT_SMALL      160
#define WSMINE_COLLECT_COLLECTION_VIEW_CELL_IMAGE_HEIGHT  142

@interface WSMineCollectCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) NSDictionary *dic;

@property (copy) void(^downloadImageFinish)(void);

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) IBOutlet UIView *conView;

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UILabel *validateDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *distanceBut;
- (IBAction)prodcutDetailButAction:(id)sender;
- (IBAction)distanceButAction:(id)sender;


@end
