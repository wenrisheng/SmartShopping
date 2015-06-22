//
//  WSFilterBrandViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"
#import "WSPromotionCouponViewController.h"

@interface WSFilterBrandViewController : WSServiceViewController


@property (weak, nonatomic) WSPromotionCouponViewController *beforeVC;
@property (strong, nonatomic) NSString *categoryId;


@property (copy) void(^callBack)(NSArray *array);
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end
