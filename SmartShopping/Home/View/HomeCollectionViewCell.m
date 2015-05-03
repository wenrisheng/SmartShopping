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
    [_conView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.706 green:0.710 blue:0.714 alpha:1.000] cornerRadius:5];
    
    [self.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
   // [_distanceBut setEnlargeEdgeWithTop:13 right:0 bottom:0 left:10];
    [_leftBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
    [_rightBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
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
