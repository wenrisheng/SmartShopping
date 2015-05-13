//
//  WSProductDetailViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSProductDetailViewController : WSServiceViewController

@property (strong, nonatomic) NSString *goodsNumber;
@property (strong, nonatomic) NSString *shopId;

@property (strong, nonatomic) NSString *goodsId;

@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) BOOL hasScan;

@end
