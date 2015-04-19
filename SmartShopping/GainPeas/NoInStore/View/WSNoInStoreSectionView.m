//
//  WSNoInStoreSectionView.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSNoInStoreSectionView.h"

@implementation WSNoInStoreSectionView

+ (instancetype)getView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSNoInStoreSectionView" owner:nil options:nil];
    return [array firstObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
