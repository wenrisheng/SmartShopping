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
   // _contentTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
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
    [param setValue:@"1" forKey:@"giftType"];
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
        [_contentTableView endHeaderAndFooterRefresh];
         [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
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
    static NSString *identify = @"WSMineConverCell";
    WSMineConverCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [WSMineConverCell getCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger row = indexPath.row;
    NSInteger itemCount = dataArray.count;
    if (row == itemCount - 1) {
        cell.bottomSaperateView.hidden = NO;
    } else {
        cell.bottomSaperateView.hidden = YES;
    }
    NSDictionary *dic = [dataArray objectAtIndex:row];
    [cell setModel:dic];
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
