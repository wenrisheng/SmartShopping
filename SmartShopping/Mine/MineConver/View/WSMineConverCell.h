//
//  WSMineConverCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSMINECONVERCELL_HEIGHT    93

@interface WSMineConverCell : UITableViewCell

+ (instancetype)getCell;

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *topSaperateView;
@property (weak, nonatomic) IBOutlet UIView *bottomSaperateView;

@property (weak, nonatomic) IBOutlet UILabel *shuliangLabel;


@end
