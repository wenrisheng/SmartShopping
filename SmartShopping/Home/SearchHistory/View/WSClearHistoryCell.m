//
//  WSClearHistoryCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSClearHistoryCell.h"

@implementation WSClearHistoryCell

- (void)awakeFromNib {
    // Initialization code
    [_clearHistoryBut setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.918 green:0.537 blue:0.412 alpha:1.000] cornerRadius:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
