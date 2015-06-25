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
#import "WSInfoGoodDetailViewController.h"

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
    
    self.sortArray = [[NSMutableArray alloc] init];
    _navigationBarManagerView.navigationBarButLabelView.delegate = self;
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"消息列表";
    
    [_contentTableView addLegendHeaderWithRefreshingBlock:^{
        [self requestInfo];
    }];
    if (_dataArray.count != 0) {
        [_sortArray removeAllObjects];
        [self.sortArray addObjectsFromArray:_dataArray];
    } else {
         [self requestInfo];
    }
    
}

- (void)requestInfo
{
     WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *userid = user._id;
    userid = userid.length > 0 ? userid : @"";
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserMessage] data:@{@"userId": userid} tag:WSInterfaceTypeUserMessage sucCallBack:^(id result) {
        [_contentTableView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            if (!_sortArray) {
                self.sortArray = [[NSMutableArray alloc] init];
            }
            [_sortArray removeAllObjects];
            NSArray *messages = [[result objectForKey:@"data"] objectForKey:@"messages"];
            
            NSMutableArray *isids = [NSMutableArray array];
            for (NSDictionary *dic in messages) {
                NSString *isNewMessage = [dic stringForKey:@"isNewMessage"];
                if ([isNewMessage isEqualToString:@"Y"]) {
                    [isids addObject:[dic stringForKey:@"id"]];
                }
            }
            if (isids.count > 0) {
                NSMutableString *isNesMessages = [[NSMutableString alloc] init];
                for (int i = 0; i < isids.count; i++) {
                    if (i == isids.count - 1) {
                        [isNesMessages appendString:[isids objectAtIndex:i]];
                    } else {
                        [isNesMessages appendString:[NSString stringWithFormat:@"%@,", [isids objectAtIndex:i]]];
                    }
                }
                [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUpdateIsNewMessage] data:@{@"ids": isNesMessages} tag:WSInterfaceTypeUpdateIsNewMessage sucCallBack:^(id result) {
                    
                } failCallBack:^(id error) {
                    
                } showMessage:NO];
            }
            [_sortArray addObjectsFromArray:messages];
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
         [_contentTableView endHeaderAndFooterRefresh];
    } showMessage:YES];
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
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeuUpdateMessage] data:@{@"mesId": [dic stringForKey:@"id"]} tag:WSInterfaceTypeuUpdateMessage sucCallBack:^(id result) {
        
    } failCallBack:^(id error) {
        
    } showMessage:NO];
    
    NSString *type = [dic stringForKey:@"type"];
    // 更新用户消息是否已读
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeuUpdateMessage] data:@{@"mesId": [dic stringForKey:@"id"]} tag:WSInterfaceTypeuUpdateMessage sucCallBack:^(id result) {
        
    } failCallBack:^(id error) {
        
    }];
    
    // 跳到消息详情页面
    if ([type isEqualToString:@"2"]) {
        WSInfoDetailViewController *infDetailVC = [[WSInfoDetailViewController alloc] init];
        infDetailVC.dic = dic;
        [self.navigationController pushViewController:infDetailVC animated:YES];
        // 跳到商品详情页面
    } else {
        WSInfoGoodDetailViewController *infoGoodDetailVC = [[WSInfoGoodDetailViewController alloc] init];
        infoGoodDetailVC.dic = dic;
        [self.navigationController pushViewController:infoGoodDetailVC animated:YES];
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
