//
//  CollectSucView.h
//  SmartShopping
//
//  Created by wrs on 15/5/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FinishCallBack)(void);;

@interface CollectSucView : UIView
@property (strong, nonatomic) FinishCallBack callBack;

+ (void)showCollectSucViewInView:(UIView *)view;

+ (void)showCollectSucViewWithFinishCallBack:(FinishCallBack)callBack;

@end
