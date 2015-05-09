//
//  WSLogoutCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/24.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSLogoutCell.h"

@implementation WSLogoutCell

- (void)awakeFromNib {
    [_logoutBut setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
