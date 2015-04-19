//
//  WSMineFirstCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/16.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineFirstCell.h"

@implementation WSMineFirstCell

+ (instancetype)getCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSMineFirstCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)awakeFromNib {
    // Initialization code
    _bottomView.layer.cornerRadius = 5;
    _bottomView.layer.borderColor = [UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000].CGColor;
    _bottomView.layer.borderWidth = 1;
    _bottomView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)myPeasButAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(mineFirstCellMinePeasButAction:)]) {
        [_delegate mineFirstCellMinePeasButAction:sender];
    }
}

- (IBAction)mineConverButAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(mineFirstCellMineConverButAction:)]) {
        [_delegate mineFirstCellMineConverButAction:sender];
    }
}

- (IBAction)mineConsumeButAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(mineFirstCellMineConsumeButAction:)]) {
        [_delegate mineFirstCellMineConsumeButAction:sender];
    }
}
- (IBAction)mineCollectButAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(mineFirstCellMineCollectButAction:)]) {
        [_delegate mineFirstCellMineCollectButAction:sender];
    }
}
@end
