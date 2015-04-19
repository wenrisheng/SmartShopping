//
//  WSNoLoginView.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSNoLoginView : UIView

+ (instancetype)getView;

@property (weak, nonatomic) IBOutlet UIImageView *noLoginHeadImageView;
@property (weak, nonatomic) IBOutlet UIButton *logigImmediately;

@end
