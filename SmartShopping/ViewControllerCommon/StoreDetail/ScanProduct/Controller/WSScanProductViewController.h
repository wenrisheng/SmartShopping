//
//  WSScanProductViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSScanProductViewController : WSServiceViewController

@property (copy) void(^scanSucCallBack)(NSString *beanNumber);

@property (strong, nonatomic) NSString *shopid;
@property (strong, nonatomic) NSString *goodsId;

@end
