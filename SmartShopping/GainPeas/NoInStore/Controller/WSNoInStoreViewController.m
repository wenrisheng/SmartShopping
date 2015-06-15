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
#import "WSLocationDetailViewController.h"

@interface WSNoInStoreViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
    WSNoInStoreSectionView *sectionView;
    int curPage;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (strong, nonatomic) NSDictionary *isInShop;
@property (strong, nonatomic) NSDictionary *shop;

@end

@implementation WSNoInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"到店签到";
    dataArray = [[NSMutableArray alloc] init];
    curPage = 0;
    [_contentTableView addLegendHeaderWithRefreshingBlock:^{
        curPage = 0;
        [self requestShopSignList];
    }];
    [_contentTableView addLegendFooterWithRefreshingBlock:^{
        [self requestShopSignList];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(locationUpdate:)
                                             name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{

    NSString *city = [locationDic objectForKey:LOCATION_CITY];
    if (_city.length == 0) {
        self.city = city;
        self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
        self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
        if (dataArray.count == 0) {
            [self requestShopSignList];
        }
    }
}

- (void)requestShopSignList
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_contentTableView endHeaderAndFooterRefresh];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    [params setValue:user._id forKey:@"uid"];
    [params setValue:_city forKey:@"cityName"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [params setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeShopSignList] data:params tag:WSInterfaceTypeShopSignList sucCallBack:^(id result) {
         [_contentTableView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopSignList = [[result objectForKey:@"data"] objectForKey:@"shopSignList"];
            if (curPage == 0) {
                [dataArray removeAllObjects];
            }
            curPage ++;
            [dataArray addObjectsFromArray:shopSignList];
            [_contentTableView reloadData];
        }
        
    } failCallBack:^(id error) {
        [_contentTableView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dataArray.count == 0) {
        return 1;
    }
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
        [cell.signupBut addTarget:self action:@selector(storeNameButAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.distanceBut addTarget:self action:@selector(distanceButAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSInteger row = indexPath.row;
    cell.titleBut.tag = row;
    cell.signupBut.tag = row;
    cell.distanceBut.tag = row;
    if (dataArray.count == 0) {
        cell.hidden = YES;
    } else {
        cell.hidden = NO;
        NSDictionary *dic = [dataArray objectAtIndex:row];
        [cell setModel:dic];
    }
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
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    WSStoreDetailViewController *storeDetail = [[WSStoreDetailViewController alloc] init];
    storeDetail.shop = dic;
    [self.navigationController pushViewController:storeDetail animated:YES];
}

#pragma mark 签到按钮事件
- (void)signupButAction:(UIButton *)but
{
    //  1. GPS定位不在店内跳到 WSNoInStoreViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController
    [WSUserUtil actionAfterLogin:^{
        [[WSRunTime sharedWSRunTime] findIbeaconWithCallback:^(NSArray *beaconsArray) {
            CLBeacon *beacon = nil;
            if (beaconsArray.count > 0) {
                beacon = [beaconsArray objectAtIndex:0];
            }
            [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
                BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
                // 在店内
                if (isInStore) {
                    NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
                    NSString *isSign = [shop stringForKey:@"isSign"];
                    //  没签到
                    if ([isSign isEqualToString:@"N"]) {
                        WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
                        inStoreNoSignVC.shop = shop;
                        [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
                    } else {
                        WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                        storeDetailVC.shop = shop;
                        [self.navigationController pushViewController:storeDetailVC animated:YES];
                    }
                    // 不在店内
                } else {
                    WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
                    [self.navigationController pushViewController:noInstoreVC animated:YES];
                }
            }];
        }];
    }];
}

#pragma mark 地图距离按钮事件
- (void)distanceButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    NSString *lat = [dic stringForKey:@"lat"];
    NSString *lon = [dic stringForKey:@"lon"];
    NSString *shopName = [dic stringForKey:@"shopname"];
    NSString *address = [dic objectForKeyedSubscript:@"address"];
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    locationDetailVC.latitude = [lon doubleValue];
    locationDetailVC.longitude = [lat doubleValue];
    locationDetailVC.locTitle = shopName;
    locationDetailVC.address = address;
    [self.navigationController pushViewController:locationDetailVC animated:YES];
}


@end
