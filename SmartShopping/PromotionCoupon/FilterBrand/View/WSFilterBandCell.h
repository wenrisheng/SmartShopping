//
//  WSFilterBandCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WSFILTERBANDCELL_HEIGHT   44

@interface WSFilterBandCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@end
