//
//  InfoListViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/14.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInfoListViewController.h"
#import "WSInfoListCell.h"
#import "WSInfoDetailViewController.h"
#import "WSProductDetailViewController.h"

@interface WSInfoListViewController () <WSNavigationBarButLabelViewDelegate>
{
    UIAlertView *alertView;
}
@property (strong, nonatomic) NSDictionary *delectDic;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSMutableArray *sortArray;

@end

@implementation WSInfoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _navigationBarManagerView.navigationBarButLabelView.delegate = self;
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"消息列表";
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    if (_dataArray.count == 0) {
        [self requestInfo];
    }
    
    [_contentTableView addLegendHeaderWithRefreshingBlock:^{
        [self requestInfo];
    }];
    if (_dataArray.count != 0) {
        [self sortDataArray];
    } else {
         [self requestInfo];
    }
    
}

- (void)requestInfo
{
     WSUser *user = [WSRunTime sharedWSRunTime].user;
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserMessage] data:@{@"userId": user._id} tag:WSInterfaceTypeUserMessage sucCallBack:^(id result) {
        [_contentTableView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            if (!_dataArray) {
                self.dataArray = [[NSMutableArray alloc] init];
            }
            [_dataArray removeAllObjects];
            NSArray *messages = [[result objectForKey:@"data"] objectForKey:@"messages"];
            [self.dataArray addObjectsFromArray:messages];
            [self sortDataArray];
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
         [_contentTableView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

- (void)sortDataArray
{
    NSArray *array = [_dataArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dic1 = obj1;
        NSDictionary *dic2 = obj2;
        int isRead1 = [[dic1 stringForKey:@"isRead"] intValue];
        int isRead2 = [[dic2 stringForKey:@"isRead"] intValue];
        if (isRead1 <= isRead2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
    if (!_sortArray) {
        self.sortArray = [[NSMutableArray alloc] init];
    }
    [_sortArray removeAllObjects];
    [self.sortArray addObjectsFromArray:array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NavigationBarButLabelViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sortArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"InfoListCell";
    WSInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [WSInfoListCell getCelll];
        UISwipeGestureRecognizer *swipeGest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestAction:)];
        swipeGest.direction = UISwipeGestureRecognizerDirectionLeft;
        [cell addGestureRecognizer:swipeGest];
    }
    NSInteger row = indexPath.row;
    cell.tag = row;
    NSDictionary *dic = [_sortArray objectAtIndex:row];
    [cell setModel:dic];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return INFOLISTCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSDictionary *dic = [_sortArray objectAtIndex:row];
    NSString *content = [dic objectForKey:@"content"];
    // 更新用户消息是否已读
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeuUpdateMessage] data:@{@"mesId": [dic stringForKey:@"id"]} tag:WSInterfaceTypeuUpdateMessage sucCallBack:^(id result) {
        
    } failCallBack:^(id error) {
        
    }];
    
    // 跳到消息详情页面
    if ([content respondsToSelector:@selector(length)]) {
        if (content.length > 0) {
            WSInfoDetailViewController *infDetailVC = [[WSInfoDetailViewController alloc] init];
            infDetailVC.dic = dic;
            [self.navigationController pushViewController:infDetailVC animated:YES];
            // 跳到商品详情页面
        } else {
            NSString *goodsNumber = [dic stringForKey:@"goodsNumber"];
            NSString *shopId = [dic stringForKey:@"shopId"];
            shopId = shopId.length > 0 ? shopId : @"1";
            WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
            productDetailVC.goodsNumber = goodsNumber;
            productDetailVC.shopId = shopId;
            [self.navigationController pushViewController:productDetailVC animated:YES];
        }
    } else {
        NSString *goodsNumber = [dic stringForKey:@"goodsNumber"];
        NSString *shopId = [dic stringForKey:@"shopId"];
        shopId = shopId.length > 0 ? shopId : @"1";
        WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
        productDetailVC.goodsNumber = goodsNumber;
        productDetailVC.shopId = shopId;
        [self.navigationController pushViewController:productDetailVC animated:YES];
    }
    
}

- (void)swipeGestAction:(UISwipeGestureRecognizer *)swipeGest
{
    UIView *view = [swipeGest view];
    NSInteger tag = view.tag;
    self.delectDic = [_sortArray objectAtIndex:tag];
    if (!alertView) {
        alertView  = [[UIAlertView alloc] initWithTitle:@"操作" message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    }
    
    [alertView show];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==1) {
        [SVProgressHUD showWithStatus:@"正在删除……"];
        [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDelMessage] data:@{@"mesId": [_delectDic stringForKey:@"id"]} tag:WSInterfaceTypeDelMessage sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [_sortArray removeObject:_delectDic];
                self.delectDic = nil;
                [_contentTableView reloadData];
            }
        } failCallBack:^(id error) {
            [SVProgressHUD dismissWithError:@"删除失败！" afterDelay:TOAST_VIEW_TIME];
        } showMessage:NO];
        
    }
    
    
}


@end
