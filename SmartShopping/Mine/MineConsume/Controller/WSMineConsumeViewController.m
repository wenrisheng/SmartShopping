//
//  WSMineConsumeViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConsumeViewController.h"
#import "WSMineConsumeCell.h"
#import "WSMineConsumeDetailViewController.h"

@interface WSMineConsumeViewController ()
{
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSMineConsumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的消费卷";
    _contentTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    dataArray = [[NSMutableArray alloc] init];
    [dataArray addObjectsFromArray:@[@"", @"", @"", @""]];
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
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"WSMineConsumeCell";
    WSMineConsumeCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
    }
    UIColor *color = nil;
    NSString *status = nil;
    NSInteger row = indexPath.row;
    if (row % 2 == 0) {
        color = [UIColor colorWithRed:0.784 green:0.576 blue:0.000 alpha:1.000];
        status = @"未使用";
    } else {
        color = [UIColor colorWithRed:0.655 green:0.659 blue:0.667 alpha:1.000];
        status = @"已使用";
    }
    [cell.leftView setBorderCornerWithBorderWidth:1 borderColor:color cornerRadius:1];
    cell.consumeLabel.textColor = color;
    cell.statusLabel.textColor = color;
    cell.statusLabel.text = status;
    NSString *unit = @"¥ ";
    NSString *value = @"500";
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", unit, value]];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, unit.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(unit.length, value.length)];
    cell.consumeLabel.attributedText = tempStr;
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMINECONSUMECELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSMineConsumeDetailViewController *mineConsumeDetailVC = [[WSMineConsumeDetailViewController alloc] init];
    [self.navigationController pushViewController:mineConsumeDetailVC animated:YES];
}

@end
