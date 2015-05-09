//
//  CollectSucView.m
//  SmartShopping
//
//  Created by wrs on 15/5/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "CollectSucView.h"

@implementation CollectSucView

+ (void)showCollectSucView
{
    UIWindow *windown = [UIApplication sharedApplication].keyWindow;
    CollectSucView *collectSucView = GET_XIB_FIRST_OBJECT(@"CollectSucView");
    collectSucView.translatesAutoresizingMaskIntoConstraints = NO;
    [windown addSubview:collectSucView];
    [collectSucView expandToSuperView];
    [NSTimer scheduledTimerWithTimeInterval:2 target:collectSucView selector:@selector(dismissCollsecSucView) userInfo:nil repeats:NO];
}

- (void)dismissCollsecSucView
{
    [self removeFromSuperview];
}

@end
