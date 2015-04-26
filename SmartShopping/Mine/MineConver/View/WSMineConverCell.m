//
//  WSMineConverCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConverCell.h"

@implementation WSMineConverCell

+ (instancetype)getCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSMineConverCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
