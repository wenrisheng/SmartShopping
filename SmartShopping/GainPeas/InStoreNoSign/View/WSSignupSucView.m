//
//  WSSignupSucView.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSignupSucView.h"

@implementation WSSignupSucView

+ (instancetype)getView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSSignupSucView" owner:nil options:nil];
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
