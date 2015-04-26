//
//  WSMineConverViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConverViewController.h"
#import "WSMineConverCell.h"

@interface WSMineConverViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSMineConverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的兑换";
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
    static NSString *identify = @"WSMineConverCell";
    WSMineConverCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [WSMineConverCell getCell];
    }
    NSInteger row = indexPath.row;
    NSInteger itemCount = dataArray.count;
    if (row == itemCount - 1) {
        cell.bottomSaperateView.hidden = NO;
    } else {
        cell.bottomSaperateView.hidden = YES;
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMINECONVERCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
