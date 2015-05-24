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
   // [dataArray addObjectsFromArray:@[@"AA", @"aa", @"aa", @"aa", @"aa", @"aa"]];
    curPage = 0;
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
    //    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    //    if (deoCodeFalg == 0) {
    DLog(@"city:%@", _city);
    NSString *city = [locationDic objectForKey:LOCATION_CITY];
    self.city = city;
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    _navigationBarManagerView.navigationBarButSearchButView.leftLabel.text = city;
    DLog(@"定位：%@", city);
    //    }
}

- (void)requestShopSignList
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    [params setValue:user._id forKey:@"uid"];
    [params setValue:_city forKey:@"cityname"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [params setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeShopSignList] data:params tag:WSInterfaceTypeShopSignList sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopSignList = [[result objectForKey:@"data"] objectForKey:@"shopSignList"];
            if (curPage == 0) {
                [dataArray removeAllObjects];
            }
            [dataArray addObjectsFromArray:shopSignList];
            [_contentTableView reloadData];
        }
        
    } failCallBack:^(id error) {

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
        [cell.signupBut addTarget:self action:@selector(signupButAction:) forControlEvents:UIControlEventTouchUpInside];
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
    storeDetail.shopid = [dic stringForKey:@"shopid"];
    [self.navigationController pushViewController:storeDetail animated:YES];
}

#pragma mark 签到按钮事件
- (void)signupButAction:(UIButton *)but
{
    // 1. GPS定位不在店内跳到 不在签到范围页面 WSInStoreNoSignScopeViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    [WSProjUtil isInStoreWithIsInStoreType:IsInStoreTypeGainPea callback:^(id result) {
        BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
        // 在店内
        if (isInStore) {
            NSDictionary *isInShop = [result objectForKey:IS_IN_SHOP_DATA];
            self.isInShop = isInShop;
            // 请求商店详情
            [self requestStoreDetail];
            
            // 不在店内
        } else {
            [self toNoInStoreVC];
        }
        
    }];

   
}

#pragma mark 地图距离按钮事件
- (void)distanceButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    NSString *lat = [dic stringForKey:@"lat"];
    NSString *lon = [dic stringForKey:@"lon"];
    NSString *shopName = [dic stringForKey:@"shopName"];
    NSString *address = [dic objectForKeyedSubscript:@"address"];
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    locationDetailVC.latitude = [lon doubleValue];
    locationDetailVC.longitude = [lat doubleValue];
    locationDetailVC.locTitle = shopName;
    locationDetailVC.address = address;
    [self.navigationController pushViewController:locationDetailVC animated:YES];
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
    inStoreNoSignVC.shopid = [_shop stringForKey:@"shopid"];
    inStoreNoSignVC.shopName = [_shop objectForKey:@"shopName"];
    [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
    
}

#pragma mark 在店内已签到
- (void)toStoreDetail
{
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    storeDetailVC.shopid = [_shop stringForKey:@"shopid"];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

#pragma mark - 请求商店详情
- (void)requestStoreDetail
{
    //请求商店详情接口获取商店名
    NSString *shopId = [_isInShop stringForKey:@"shopId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:@"shopid" forKey:shopId];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%d",  1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [params setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCheckMoreGoodsList] data:params tag:WSInterfaceTypeCheckMoreGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            
            //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
            //  3. 在店内已签到 跳到 WSStoreDetailViewController
            NSDictionary *shop = [[result objectForKey:@"data"] objectForKey:@"shop"];
            self.shop = shop;
            NSString *isSign = [shop stringForKey:@"isSign"];
            // 没有签到
            if ([isSign isEqualToString:@"1"]) {
                [self toInStoreNoSign];
                // 已经签到
            } else {
                [self toStoreDetail];
            }
        } else {
            //不在店内
            [self toNoInStoreVC];
        }
    } failCallBack:^(id error) {
        [self toNoInStoreVC];
    } showMessage:NO];
}

#pragma mark - 到店签到 不在店内
- (void)toNoInStoreVC
{
    [WSUserUtil actionAfterLogin:^{
        WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
        [self.navigationController pushViewController:noInstoreVC animated:YES];
    }];
}


@end
