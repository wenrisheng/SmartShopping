//
//  WSNoLoginView.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSNoLoginView.h"

@implementation WSNoLoginView

+ (instancetype)getView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSNoLoginView" owner:nil options:nil];
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
