//
//  WSDoubleTableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DoubleTableFCallBack)(NSInteger idnex);
typedef void(^DoubleTableSCallBack)(NSInteger idnex);

@interface WSDoubleTableView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DoubleTableFCallBack tableFCallBack;
@property (strong, nonatomic) DoubleTableSCallBack tableSCallBack;
@property (strong, nonatomic) UIColor *cellFSelectColor;
@property (strong, nonatomic) UIColor *cellSSelectColor;
@property (strong, nonatomic) NSArray *dataArrayF;
@property (strong, nonatomic) NSArray *dataArrayS;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableF;
@property (weak, nonatomic) IBOutlet UITableView *tableS;

@end
