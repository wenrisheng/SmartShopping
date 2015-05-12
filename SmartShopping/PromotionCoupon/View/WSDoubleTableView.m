//
//  WSDoubleTableView.m
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSDoubleTableView.h"
#import "WSDoubleTableCell.h"

@implementation WSDoubleTableView

- (void)awakeFromNib
{
    _tableF.dataSource = self;
    _tableF.delegate = self;
    
    _tableS.dataSource = self;
    _tableS.delegate = self;
    
//    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestAction:)];
//    [self.bgView addGestureRecognizer:tapGest];
}

//- (void)tapGestAction:(UITapGestureRecognizer *)tapGest
//{
//    self.hidden = YES;
//}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger tag = tableView.tag;
    switch (tag) {
        case 0:
        {
            return _dataArrayF.count;
        }
            break;
        case 1:
        {
            return _dataArrayS.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"WSDoubleTableCell";
    WSDoubleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(@"WSDoubleTableCell");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger tag = tableView.tag;
    NSInteger row = indexPath.row;
    switch (tag) {
        case 0:
        {
           NSDictionary *dic = [_dataArrayF objectAtIndex:row];
            int selected_flag = [[dic objectForKey:DOUBLE_TABLE_SELECTED_FLAG] intValue];
            if (selected_flag == 0) {
                cell.backgroundColor = _cellFSelectColor;
            } else {
                cell.backgroundColor = _cellFUnSelectColor;
            }
            cell.label.text = [dic valueForKey:DOUBLE_TABLE_TITLE];
        }
            break;
        case 1:
        {
            NSDictionary *dic = [_dataArrayS objectAtIndex:row];
            int selected_flag = [[dic valueForKey:DOUBLE_TABLE_SELECTED_FLAG] intValue];
            if (selected_flag == 0) {
                cell.backgroundColor = _cellSSelectColor;
            } else {
                cell.backgroundColor = _cellSUnSelectColor;
            }
            cell.label.text = [dic objectForKey:DOUBLE_TABLE_TITLE];
        }
            break;
        default:
            break;
    }
   
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSDOUBLETABLECELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = tableView.tag;
    NSInteger row = indexPath.row;
    switch (tag) {
        case 0:
        {
            if (_isLeftToRight) {
                for (NSDictionary *dic in _dataArrayF) {
                    [dic setValue:[NSNumber numberWithInt:1] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                }
                NSMutableDictionary *dic = [_dataArrayF objectAtIndex:row];
                [dic setValue:[NSNumber numberWithInt:0] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [_tableF reloadData];

            }
            if (_tableFCallBack) {
                _tableFCallBack(row);
            }
        }
            break;
        case 1:
        {
            if (!_isLeftToRight) {
                for (NSDictionary *dic in _dataArrayS) {
                    [dic setValue:[NSNumber numberWithInt:1] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                }
                NSMutableDictionary *dic = [_dataArrayS objectAtIndex:row];
                [dic setValue:[NSNumber numberWithInt:0] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [_tableS reloadData];
            }

            if (_tableSCallBack) {
                _tableSCallBack(row);
            }
        }
            break;
        default:
            break;
    }

}

@end
