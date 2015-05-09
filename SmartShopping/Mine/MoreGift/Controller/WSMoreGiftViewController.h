//
//  WSMoreGiftViewController.h
//  SmartShopping
//
//  Created by wrs on 15/4/24.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

#define CATEGORY_TITLE         @"CATEGORY_TITLE"       // 分类标题
#define CATEGORY_DATA_ARRAY    @"CATEGORY_DATA_ARRAY"  // 分类数组

@interface WSMoreGiftViewController : WSServiceViewController

@property (strong, nonatomic) NSMutableArray *peasScopeArray;
@property (strong, nonatomic) NSMutableArray *peasAllCategoryArray;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
