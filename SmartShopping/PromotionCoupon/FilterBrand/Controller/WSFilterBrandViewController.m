//
//  WSFilterBrandViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/27.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSFilterBrandViewController.h"
#import "WSFilterBandCell.h"

#define SELECTED_FLAG     @"selected_flag"

@interface WSFilterBrandViewController () <UITableViewDataSource, UITableViewDelegate,WSNavigationBarButLabelButViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;

@property (weak, nonatomic) IBOutlet UIImageView *allSelectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *allNotSelectedImageView;
- (IBAction)allSelectedButAction:(id)sender;
- (IBAction)allNotSelectedButAction:(id)sender;

@end

@implementation WSFilterBrandViewController
@synthesize dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelButView.centerLabel.text = @"筛选品牌";
    _navigationBarManagerView.navigationBarButLabelButView.delegate = self;
    [_navigationBarManagerView.navigationBarButLabelButView.rightBut setBackgroundImage:nil forState:UIControlStateNormal];
    [_navigationBarManagerView.navigationBarButLabelButView.rightBut setTitle:@"确定" forState:UIControlStateNormal];
    self.dataArray = [[NSMutableArray alloc] init];
    [self requestGetShopCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 请求pinpai
- (void)requestGetShopCategory
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopBrand] data:@{@"categoryId": _categoryId} tag:WSInterfaceTypeGetShopBrand sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *brands = [[result objectForKey:@"data"] objectForKey:@"brands"];
            NSInteger SCount = brands.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [brands objectAtIndex:i];
                [datadic setDictionary:dic];
                [datadic setObject:@"1" forKey:SELECTED_FLAG];
                [dataArray addObject:datadic];
            }
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
    
}


#pragma mark - WSNavigationBarButLabelButViewDelegate
- (void)navigationBarRightButClick:(UIButton *)but
{
    NSPredicate *allSelectedPred = [NSPredicate predicateWithFormat:@"selected_flag == '1'"];
    NSArray *selectedArray = [dataArray filteredArrayUsingPredicate:allSelectedPred];
    if (_callBack) {
        _callBack(selectedArray);
    }
  
    [self.navigationController popViewControllerAnimated:YES];
    _beforeVC.isLoadInStoreOrOutStore = YES;
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
    static NSString *identify = @"WSFilterBandCell";
    WSFilterBandCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
    }
    NSInteger row = indexPath.row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    NSString *flag = [dic objectForKey:SELECTED_FLAG];
    if ([flag isEqualToString:@"1"]) {
        cell.leftImageView.image = [UIImage imageNamed:@"choose-01.png"];
    } else {
        cell.leftImageView.image = [UIImage imageNamed:@"choose-02.png"];
    }
    cell.rightLabel.text = [dic objectForKey:@"name"];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSFILTERBANDCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSMutableDictionary *dic = [dataArray objectAtIndex:row];
    NSString *flag = [dic objectForKey:SELECTED_FLAG];
    if ([flag isEqualToString:@"1"]) {
        [dic setValue:@"0" forKey:SELECTED_FLAG];
    } else {
       [dic setValue:@"1" forKey:SELECTED_FLAG];
    }
    [_contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    NSPredicate *allSelectedPred = [NSPredicate predicateWithFormat:@"selected_flag == '1'"];
    NSPredicate *allNotSelectedPred = [NSPredicate predicateWithFormat:@"selected_flag == '0'"];
    NSArray *selectedArray = [dataArray filteredArrayUsingPredicate:allSelectedPred];
    NSArray *notSelectedArray = [dataArray filteredArrayUsingPredicate:allNotSelectedPred];
    if (selectedArray.count == dataArray.count) {
        _allSelectedImageView.image = [UIImage imageNamed:@"choose-01.png"];
        _allNotSelectedImageView.image = [UIImage imageNamed:@"choose-02.png"];
    }
    if (notSelectedArray.count == dataArray.count) {
        _allSelectedImageView.image = [UIImage imageNamed:@"choose-02.png"];
        _allNotSelectedImageView.image = [UIImage imageNamed:@"choose-01.png"];
    }
}

- (IBAction)allSelectedButAction:(id)sender
{
    for (NSMutableDictionary *dic in dataArray) {
        [dic setValue:@"1" forKey:SELECTED_FLAG];
    }
    [_contentTableView reloadData];
    _allSelectedImageView.image = [UIImage imageNamed:@"choose-01.png"];
    _allNotSelectedImageView.image = [UIImage imageNamed:@"choose-02.png"];
}

- (IBAction)allNotSelectedButAction:(id)sender
{
    for (NSMutableDictionary *dic in dataArray) {
        [dic setValue:@"0" forKey:SELECTED_FLAG];
    }
    [_contentTableView reloadData];
    _allSelectedImageView.image = [UIImage imageNamed:@"choose-02.png"];
    _allNotSelectedImageView.image = [UIImage imageNamed:@"choose-01.png"];
}

@end
