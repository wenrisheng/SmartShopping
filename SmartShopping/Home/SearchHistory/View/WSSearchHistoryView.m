//
//  WSSearchHistoryView.m
//  SmartShopping
//
//  Created by wrs on 15/5/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchHistoryView.h"
#import "WSClearHistoryCell.h"
#import "WSSearchHistoryCell.h"

@implementation WSSearchHistoryView
@synthesize dataArray;

- (void)awakeFromNib
{
    _contentTableView.delegate = self;
    _contentTableView.dataSource = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dataArray.count != 0) {
        return dataArray.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row == count) {
        static NSString *identify = @"WSClearHistoryCell";
        WSClearHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = GET_XIB_FIRST_OBJECT(identify);
            [cell.clearHistoryBut addTarget:self action:@selector(clearHistoryButAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    static NSString *identify = @"WSSearchHistoryCell";
    WSSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
    }
    cell.label.text = [dataArray objectAtIndex:row];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row == count) {
        return WSCLEARHISTORYCELL_HEIGHT;
    }
    return WSSEARCHHISTORYCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row != count) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_didSelectedCallback) {
            _didSelectedCallback(row);
        }
        self.hidden = YES;
    }
}

- (void)clearHistoryButAction:(UIButton *)but
{
    self.hidden = YES;
    if (_clearCallback) {
        _clearCallback();
    }
}

@end
