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
    int curPage;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSMineConverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    curPage = 0;
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
    [param setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [param setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeMyGiftList] data:param tag:WSInterfaceTypeMyGiftList sucCallBack:^(id result) {
         [_contentTableView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *userGiftList = [[result objectForKey:@"data"] objectForKey:@"userGiftList"];
            if (curPage == 0) {
                [dataArray removeAllObjects];
            }
            curPage ++;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
           return 0;
        }
            break;
        case 1:
        {
             return dataArray.count;
        }
        default:
            break;
    }
    return 0;
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 20;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMINECONVERCELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
            return view;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
