//
//  WSSearchHistoryView.h
//  SmartShopping
//
//  Created by wrs on 15/5/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSSearchHistoryView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (copy) void(^didSelectedCallback)(NSInteger index);
@property (copy) void(^clearCallback)();

@end
