//
//  HomeCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell

- (void)awakeFromNib
{
    // Initialization code
    _conView.layer.cornerRadius = 5;
    _conView.layer.masksToBounds = YES;
    
    [self.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(homeCollectionViewCellDidClickLeftBut:)]) {
        [_delegate homeCollectionViewCellDidClickLeftBut:self];
    }
}

- (void)rightButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(homeCollectionViewCellDidClickRightBut:)]) {
        [_delegate homeCollectionViewCellDidClickRightBut:self];
    }
}

@end
