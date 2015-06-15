//
//  WSGiftTypeViewController.m
//  SmartShopping
//
//  Created by wrs on 15/6/15.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGiftTypeViewController.h"
#import "WSMoreGiftSearchResultCell.h"
#import "WSGiftDetailViewController.h"

@interface WSGiftTypeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArray;
}

@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableview;

@end

@implementation WSGiftTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArray = [[NSMutableArray alloc] init];
    _navigationManagerView.navigationBarButLabelView.label.text = [NSString stringWithFormat:@"奖励兑换-%@", _typeName];
    
    [_contentTableview addLegendHeaderWithRefreshingBlock:^{
        [self requestSearchGift];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef DEBUG
    self.city = @"广州";
#endif
    
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                        name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    [self requestSearchGift];
}

- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    self.city = [locationDic objectForKey:LOCATION_CITY];
    DLog(@"定位：%@", _city);
    if (_city.length > 0) {
        if (dataArray.count == 0) {
            [self requestSearchGift];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestSearchGift
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_contentTableview endHeaderAndFooterRefresh];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"" forKey:@"beforeBean"];
    [params setValue:@"" forKey:@"afterBean"];
    [params setValue:@"" forKey:@"categoryId"];
    [params setValue:@"" forKey:@"giftTag"];
    [params setValue:_typeName forKey:@"giftTagName"];
    [params setValue:_city forKey:@"cityName"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSearchGift] data:params tag:WSInterfaceTypeSearchGift sucCallBack:^(id result) {
        [_contentTableview endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *giftList = [[result objectForKey:@"data"] objectForKey:@"giftList"];
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:giftList];
            [_contentTableview reloadData];
        }
    }failCallBack:^(id error) {
        [_contentTableview endHeaderAndFooterRefresh];
         [SVProgressHUD dismissWithError:@"刷新失败!" afterDelay:TOAST_VIEW_TIME];
    } showMessage:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = dataArray.count;
    if (count % 2 == 0) {
        return count / 2;
    } else {
        return count / 2 + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"WSMoreGiftSearchResultCell";
    WSMoreGiftSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSInteger row = indexPath.row;
    NSInteger leftDataIndex = row * 2;
    NSInteger rightDataIndex = leftDataIndex + 1;
    cell.leftBut.tag = leftDataIndex;
    cell.rightBut.tag = rightDataIndex;
    NSDictionary *leftDic = [dataArray objectAtIndex:leftDataIndex];
    [cell setLeftModel:leftDic];
    NSInteger totalCount = dataArray.count;
    if (rightDataIndex < totalCount) {
        cell.rightView.hidden = NO;
        NSDictionary *rightDic = [dataArray objectAtIndex:rightDataIndex];
        [cell setRightModel:rightDic];
    } else {
        cell.rightView.hidden = YES;
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMOREGIFT_SEARCHRESULT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - leftButAction
- (void)leftButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *modelDic = [dataArray objectAtIndex:tag];
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    giftDetailVC.giftId = [modelDic stringForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark rightButAction
- (void)rightButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *modelDic = [dataArray objectAtIndex:tag];
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    giftDetailVC.giftId = [modelDic stringForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

@end
