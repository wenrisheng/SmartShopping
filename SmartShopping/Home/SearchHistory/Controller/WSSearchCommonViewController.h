//
//  WSSearchCommonViewController.h
//  SmartShopping
//
//  Created by wrs on 15/5/31.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"
#import "WSSearchProductViewController.h"
#import "WSSearchStoreViewController.h"

#define TOP_TAB_IMAGE_WIDTH     7

@interface WSSearchCommonViewController : WSServiceViewController

@property (strong, nonatomic) WSSearchProductViewController *productVC;
@property (strong, nonatomic) WSSearchStoreViewController *storeVC;

@end
