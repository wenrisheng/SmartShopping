//
//  WSDoubleTableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DOUBLE_TABLE_TITLE                  @"double_table_title"
#define DOUBLE_TABLE_SELECTED_FLAG          @"double_table_selected_flag"    // @"0" 选中 @"1" 没选中

typedef void(^DoubleTableFCallBack)(NSInteger idnex);
typedef void(^DoubleTableSCallBack)(NSInteger idnex);

@interface WSDoubleTableView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DoubleTableFCallBack tableFCallBack;
@property (strong, nonatomic) DoubleTableSCallBack tableSCallBack;
@property (strong, nonatomic) UIColor *cellFSelectColor;
@property (strong, nonatomic) UIColor *cellFUnSelectColor;
@property (strong, nonatomic) UIColor *cellSSelectColor;
@property (strong, nonatomic) UIColor *cellSUnSelectColor;
@property (strong, nonatomic) NSArray *dataArrayF;
@property (strong, nonatomic) NSArray *dataArrayS;
@property (assign, nonatomic) BOOL isLeftToRight;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableF;
@property (weak, nonatomic) IBOutlet UITableView *tableS;
@property (weak, nonatomic) IBOutlet UIImageView *indicateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicateImageViewCenterXCon;

@end
