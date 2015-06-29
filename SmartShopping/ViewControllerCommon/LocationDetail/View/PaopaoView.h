//
//  PaopaoView.h
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaopaoView : UIView

@property (weak, nonatomic) IBOutlet WSVerticalLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WSVerticalLabel *addressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightCon;


@end
