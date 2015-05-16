//
//  WSFilterBrandViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSFilterBrandViewController : WSServiceViewController

@property (strong, nonatomic) NSString *mainId;

@property (copy) void(^callBack)(NSArray *array);

@end
