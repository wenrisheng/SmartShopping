//
//  WSMoreGiftCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMoreGiftCell.h"

@implementation WSMoreGiftCell

- (void)awakeFromNib {
    // Initialization code
    NSArray *array = @[_leftProduct, _rightProduct];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000] cornerRadius:5];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
