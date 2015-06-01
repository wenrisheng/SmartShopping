//
//  WSScanNoInStoreCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSSCANNOINSTORECOLLECTIONVIEWCELL_HEIGHT           182
#define WSSCANNOINSTORECOLLECTIONVIEWCELL_HEIGHT_SMALL     158

@interface WSScanNoInStoreCollectionViewCell : UICollectionViewCell
@property (copy) void(^downloadImageFinish)(void);
- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *bigbut;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoBut;
@property (weak, nonatomic) IBOutlet UILabel *peaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;

@end
