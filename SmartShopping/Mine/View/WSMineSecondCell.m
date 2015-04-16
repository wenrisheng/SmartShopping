//
//  WSMineSecondCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/16.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineSecondCell.h"

@implementation WSMineSecondCell

+ (instancetype)getCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSMineSecondCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)awakeFromNib
{
    // Initialization code
    _conView.layer.cornerRadius = 5;
    _conView.layer.borderColor = [UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000].CGColor;
    _conView.layer.borderWidth = 1;
    _conView.layer.masksToBounds = YES;;
    
    _leftView.layer.cornerRadius = 5;
    _leftView.layer.borderColor = [UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000].CGColor;
    _leftView.layer.borderWidth = 1;
    _leftBut.layer.masksToBounds = YES;
    
    _rightView.layer.cornerRadius = 5;
    _rightView.layer.borderColor = [UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000].CGColor;
    _rightView.layer.borderWidth = 1;
    _rightView.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
