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
  //  _contentTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    dataArray = [[NSMutableArray alloc] init];
    
    [_contentTableView addLegendHeaderWithRefreshingBlock:^{
        [self requestMyGiftList];
    }];
    [self requestMyGiftList];
}

- (void)requestMyGiftList
{
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userId forKey:@"userId"];
    [param setValue:@"2" forKey:@"giftType"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeMyGiftList] data:param tag:WSInterfaceTypeMyGiftList sucCallBack:^(id result) {
        [_contentTableView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *userGiftList = [[result objectForKey:@"data"] objectForKey:@"userGiftList"];
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:userGiftList];
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
        [_contentTableView endHeaderAndFooterRefresh];
    } showMessage:YES];
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
    NSInteger row = indexPath.row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    [cell setModel:dic];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMINECONSUMECELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    WSMineConsumeDetailViewController *mineConsumeDetailVC = [[WSMineConsumeDetailViewController alloc] init];
    [self.navigationController pushViewController:mineConsumeDetailVC animated:YES];
}

@end
