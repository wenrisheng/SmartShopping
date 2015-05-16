//
//  WSLocationDetailViewController.h
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSLocationDetailViewController : WSServiceViewController

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (strong, nonatomic) NSString *locTitle;
@property (strong, nonatomic) NSString *address;

@end
