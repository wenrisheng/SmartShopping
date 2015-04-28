//
//  WSSearchHistoryViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchHistoryViewController.h"
#import "WSClearHistoryCell.h"
#import "WSSearchHistoryCell.h"

#define SEARCH_HISTORY_KEY        @"SEARCH_HISTORY_KEY"

@interface WSSearchHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSSearchHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArray = [USER_DEFAULT objectForKey:SEARCH_HISTORY_KEY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = dataArray.count;
    if (count > 0) {
        return count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row == count - 1) {
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
    if (row == count - 1) {
        return WSCLEARHISTORYCELL_HEIGHT;
    }
    return WSSEARCHHISTORYCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row != count - 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - clearHistoryButAction
- (void)clearHistoryButAction:(UIButton *)but
{
    [USER_DEFAULT setValue:nil forKey:SEARCH_HISTORY_KEY];
    [dataArray removeAllObjects];
    [_contentTableView reloadData];
}

@end
