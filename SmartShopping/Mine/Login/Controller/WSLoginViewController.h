//
//  WSLoginViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/17.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoginedCallBack)();

@interface WSLoginViewController : WSServiceViewController

@property (strong, nonatomic) LoginedCallBack callBack;

@end
