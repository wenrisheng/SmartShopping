//
//  WSNoInStoreViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSNoInStoreViewController.h"
#import "WSNoInStoreSectionView.h"
#import "WSNoinStoreCell.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSStoreDetailViewController.h"

@interface WSNoInStoreViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
    WSNoInStoreSectionView *sectionView;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSNoInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"到店签到";
    dataArray = [[NSMutableArray alloc] init];
    [dataArray addObjectsFromArray:@[@"AA", @"aa", @"aa", @"aa", @"aa", @"aa"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"WSNoinStoreCell";
    WSNoinStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [WSNoinStoreCell getCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.titleBut addTarget:self action:@selector(storeNameButAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.signupBut addTarget:self action:@selector(signupButAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.distanceBut addTarget:self action:@selector(distanceButAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSInteger row = indexPath.row;
    cell.titleBut.tag = row;
    cell.signupBut.tag = row;
    cell.distanceBut.tag = row;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return WSNOINSTORESECTIONVIEW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSNOINSTORECELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!sectionView) {
        sectionView = [WSNoInStoreSectionView getView];
    }
    return sectionView;
}

#pragma mark - 商店名称按钮事件
- (void)storeNameButAction:(UIButton *)but
{
    
}

#pragma mark 签到按钮事件
- (void)signupButAction:(UIButton *)but
{
    // 1. GPS定位不在店内跳到 不在签到范围页面 WSInStoreNoSignScopeViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController
    [self toStoreDetail];
}

#pragma mark 地图距离按钮事件
- (void)distanceButAction:(UIButton *)but
{
    
}


#pragma mark － 在店内不在签到范围
- (void)toInStoreNoScope
{
    WSInStoreNoSignScopeViewController *inStoreNoSignScoprVC = [[WSInStoreNoSignScopeViewController alloc] init];
    [self.navigationController pushViewController:inStoreNoSignScoprVC animated:YES];
}

#pragma mark 在店内没签到
- (void)toInStoreNoSign
{
    WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
    [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
    
}

#pragma mark 在店内已签到
- (void)toStoreDetail
{
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
