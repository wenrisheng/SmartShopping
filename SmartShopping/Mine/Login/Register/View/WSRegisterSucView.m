//
//  WSRegisterSucView.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSRegisterSucView.h"

@implementation WSRegisterSucView

+ (instancetype)getView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSRegisterSucView" owner:nil options:nil];
    return array.firstObject;
}

@end
