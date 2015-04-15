//
//  InfoListCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/14.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInfoListCell.h"

@implementation WSInfoListCell

+ (instancetype)getCelll
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSInfoListCell" owner:nil options:nil];
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
