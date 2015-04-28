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
}

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
    NSArray *dataArray = nil;
    UIColor *selectedColor = nil;
    switch (tag) {
        case 0:
        {
            dataArray = _dataArrayF;
            selectedColor = _cellFSelectColor;
        }
            break;
        case 1:
        {
            dataArray = _dataArrayS;
            selectedColor = _cellSSelectColor;
        }
            break;
        default:
            break;
    }
    cell.selectedBackgroundView.backgroundColor = selectedColor;
    cell.label.text = [dataArray objectAtIndex:row];
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
            if (_tableFCallBack) {
                _tableFCallBack(row);
            }
        }
            break;
        case 1:
        {
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
