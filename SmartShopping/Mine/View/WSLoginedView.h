//
//  WSLoginedView.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSLoginedView : UIView

+ (instancetype)getView;

@property (weak, nonatomic) IBOutlet UIImageView *loginedHeadImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;

@end
