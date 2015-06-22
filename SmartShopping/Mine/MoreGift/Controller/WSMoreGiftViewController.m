//
//  WSMoreGiftViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/24.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMoreGiftViewController.h"
#import "WSMoreGiftCell.h"
#import "WSGiftDetailViewController.h"
#import "WSPromotionCouponViewController.h"
#import "WSDoubleTableView.h"
#import "WSMoreGiftSearchResultCell.h"
#import "WSGiftTypeViewController.h"

typedef NS_ENUM(NSInteger, MoreGiftViewType) {
    MoreGiftViewTypeInitView = 0,
    MoreGiftViewTypeFilterView
};

@interface WSMoreGiftViewController ()
{
    WSDoubleTableView *doubleTableView;
    int viewType;
    int peaScopeSelectIndex;
    int allCategoryIndex;
    NSMutableArray *searchResultArray;
    int curTabIndex;
}

@property (strong, nonatomic) NSMutableDictionary *searchParam;
@property (weak, nonatomic) IBOutlet UIView *tabContainerView;

@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSMutableArray *converDataArray;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peaLabel;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;

@end

@implementation WSMoreGiftViewController
@synthesize dataArray, converDataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    curTabIndex = -1;
    // Do any additional setup after loading the view from its nib.
    searchResultArray = [[NSMutableArray alloc] init];
    self.searchParam = [[NSMutableDictionary alloc] init];
    [_searchParam setValue:@"" forKey:@"beforeBean"];
    [_searchParam setValue:@"" forKey:@"afterBean"];
    [_searchParam setValue:@"" forKey:@"categoryId"];
    [_searchParam setValue:@"" forKey:@"giftTag"];
    [_searchParam setValue:@"" forKey:@"giftTagName"];
    
    viewType = MoreGiftViewTypeInitView;
    self.peasScopeArray = [[NSMutableArray alloc] init];
    self.peasAllCategoryArray = [[NSMutableArray alloc] init];
    self.converDataArray = [[NSMutableArray alloc] init];
    
    [self initView];
    
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    if (dataArray.count != 0) {
        [self converDataArrayModel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    if (dataArray.count == 0) {
        if (_city.length > 0) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setValue:_city forKey:@"cityName"];
             [self requestSearchGift:param];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 转换数据模型
- (void)converDataArrayModel
{
    if (dataArray.count != 0) {
        NSArray *categoryArray = @[@"最实用", @"最新奇", @"最热门"];
        NSInteger categoryCount = categoryArray.count;
        [converDataArray removeAllObjects];
        for (int i = 0; i < categoryCount; i++) {
            NSString *category = [categoryArray objectAtIndex:i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", category];
            NSArray *tempArray = [dataArray filteredArrayUsingPredicate:predicate];
            if (tempArray.count != 0) {
                 NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:category forKey:CATEGORY_TITLE];
                [dic setValue:tempArray forKey:CATEGORY_DATA_ARRAY];
                [converDataArray addObject:dic];
            }
        }
    }
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
        if (dataArray.count == 0) {
            switch (viewType) {
                case MoreGiftViewTypeInitView:
                {
                    NSMutableDictionary *param = [NSMutableDictionary dictionary];
                    [param setValue:_city forKey:@"cityName"];
                    [self requestSearchGift:param];
                }
                    break;
                    
                default:
                    break;
            }
        }
//    }
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"奖励兑换";
    
    // 设置用户精明豆数量
    NSString *peaNum = [WSUserUtil getUserPeasNum];
    NSString *str = @"个精明豆";
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", peaNum, str]];
    [tempStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.890 green:0.380 blue:0.090 alpha:1.000] range:NSMakeRange(0, peaNum.length)];
    [tempStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.204 green:0.208 blue:0.212 alpha:1.000] range:NSMakeRange(peaNum.length, str.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, peaNum.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(peaNum.length, str.length)];
    _peaLabel.attributedText = tempStr;
    
    // 设置tab
    NSArray *titles = @[@"豆子范围", @"全部分类"];
    _tabSlideManagerView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _tabSlideManagerView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    _tabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _tabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-up";
    NSInteger count = titles.count;
    NSMutableArray *temArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[titles objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [temArray addObject:dic];
    }

    [_tabSlideManagerView.tabSlideGapTextView setTabSlideDataArray:temArray];
    _tabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        switch (index) {
            case 0:
            {
                if (curTabIndex == index && !doubleTableView.hidden) {
                    doubleTableView.hidden = YES;
                } else {
                    if (_peasScopeArray.count == 0) {
                        [self requestPeasScope];
                    } else {
                        [self showPeaScopeSelectView];
                    }
                }
            }
                break;
            case 1:
            {
                if (curTabIndex == index && !doubleTableView.hidden) {
                    doubleTableView.hidden = YES;
                } else {
                    if (_peasAllCategoryArray.count == 0) {
                        [self requestAllCategory];
                    } else {
                        [self showAllCategorySelectView];
                    }
                }
            }
                break;
            default:
                break;
        }
        curTabIndex = index;
    };
}

#pragma mark - 请求精明豆范围
- (void)requestPeasScope
{
    [SVProgressHUD showWithStatus:@"正在加载……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeBeanScope] data:nil tag:WSInterfaceTypeBeanScope sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            id BeanList = [[result objectForKey:@"data"] objectForKey:@"BeanList"];
            NSDictionary *all = @{@"BeanScope": @{@"beanScope": @"全部", @"afterBean": @"", @"beforeBean": @""}};
            [_peasScopeArray addObject:all];
            [_peasScopeArray addObjectsFromArray:BeanList];
            [self showPeaScopeSelectView];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark 请求所有分类
- (void)requestAllCategory
{
    [SVProgressHUD showWithStatus:@"正在加载……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGiftCategory] data:nil tag:WSInterfaceTypeGiftCategory sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            id GiftCategoryList = [[result objectForKey:@"data"] objectForKey:@"GiftCategoryList"];
            NSDictionary *all = @{@"GiftCategory": @{@"giftCategoryName": @"全部", @"id": @"", @"giftType": @""}};
            [_peasAllCategoryArray addObject:all];
            [_peasAllCategoryArray addObjectsFromArray:GiftCategoryList];
            [self showAllCategorySelectView];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark 请求礼物
- (void)requestSearchGift:(NSDictionary *)param
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在刷新……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSearchGift] data:param tag:WSInterfaceTypeSearchGift sucCallBack:^(id result) {
        [_contentTableView endHeaderAndFooterRefresh];
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            switch (viewType) {
                case MoreGiftViewTypeInitView:
                {
                    self.dataArray = [[result objectForKey:@"data"] objectForKey:@"giftList"];
                    [self converDataArrayModel];
                }
                    break;
                case MoreGiftViewTypeFilterView:
                {
                    NSArray *tempArray = [[result objectForKey:@"data"] objectForKey:@"giftList"];
                    [searchResultArray removeAllObjects];
                    [searchResultArray addObjectsFromArray:tempArray];
                }
                    break;
                default:
                    break;
            }
            
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
        [_contentTableView endHeaderAndFooterRefresh];
        [SVProgressHUD dismissWithError:@"刷新失败!" afterDelay:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 显示精明豆选择view
- (void)showPeaScopeSelectView
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.tableF.hidden = NO;
    doubleTable.tableS.hidden = YES;
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = YES;
    NSMutableArray *doubleArray = [NSMutableArray array];
    NSInteger count = _peasScopeArray.count;
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = [_peasScopeArray objectAtIndex:i];
        NSDictionary *BeanScope = [dic objectForKey:@"BeanScope"];
        NSMutableDictionary *temDic = [NSMutableDictionary dictionary];
        [temDic setValue:[BeanScope stringForKey:@"beanScope"] forKey:DOUBLE_TABLE_TITLE];
        [doubleArray addObject:temDic];
    }
    doubleTable.dataArrayF = doubleArray;
    [doubleTable.tableF reloadData];

    doubleTable.tableFCallBack = ^(NSInteger index) {
        peaScopeSelectIndex = (int)index;
        NSDictionary *dic = [_peasScopeArray objectAtIndex:index];
        NSDictionary *BeanScope = [dic objectForKey:@"BeanScope"];
       WSTabSlideGapTextItemView *iteview = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0];
        iteview.label.text = [BeanScope objectForKey:@"beanScope"];
        [_searchParam setValue:[BeanScope objectForKey:@"beforeBean"] forKey:@"beforeBean"];
        [_searchParam setValue:[BeanScope objectForKey:@"afterBean"] forKey:@"afterBean"];
        [_searchParam setValue:_city forKey:@"cityName"];
        viewType = MoreGiftViewTypeFilterView;
        [self requestSearchGift:_searchParam];
        doubleTableView.hidden = YES;
    };
}

- (void)showAllCategorySelectView
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.topView.hidden = YES;
    doubleTable.tableF.hidden = YES;
    doubleTable.tableS.hidden = NO;
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = NO;
    NSMutableArray *doubleArray = [NSMutableArray array];
    NSInteger count = _peasAllCategoryArray.count;
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = [_peasAllCategoryArray objectAtIndex:i];
        NSDictionary *GiftCategory = [dic objectForKey:@"GiftCategory"];
        NSMutableDictionary *temDic = [NSMutableDictionary dictionary];
        [temDic setValue:[GiftCategory stringForKey:@"giftCategoryName"] forKey:DOUBLE_TABLE_TITLE];
        [doubleArray addObject:temDic];
    }
    doubleTable.dataArrayS = doubleArray;
    [doubleTable.tableS reloadData];
    
    doubleTable.tableSCallBack = ^(NSInteger index) {
        allCategoryIndex = (int)index;
         NSDictionary *dic = [_peasAllCategoryArray objectAtIndex:index];
        NSDictionary *GiftCategory = [dic objectForKey:@"GiftCategory"];
        WSTabSlideGapTextItemView *iteview = [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1];
        iteview.label.text = [GiftCategory objectForKey:@"giftCategoryName"];
        [_searchParam setValue:[GiftCategory objectForKey:@"id"] forKey:@"categoryId"];
        [_searchParam setValue:_city forKey:@"cityName"];
        viewType = MoreGiftViewTypeFilterView;
        [self requestSearchGift:_searchParam];
        doubleTableView.hidden = YES;
    };
}

- (WSDoubleTableView *)getDoubleTableView
{
    if (doubleTableView) {
        return doubleTableView;
    } else {
        doubleTableView = GET_XIB_FIRST_OBJECT(@"WSDoubleTableView");
        doubleTableView.topViewHeightCon.constant = -10;
        [doubleTableView.topView needsUpdateConstraints];
        UIView *topView = doubleTableView.topView;
        for (UIView *subview in topView.subviews) {
            [subview removeFromSuperview];
        }
       // doubleTableView.bgView.backgroundColor = [UIColor clearColor];
        doubleTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:doubleTableView];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tabSlideManagerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:@[top, bottom, left, right]];

        return doubleTableView;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (viewType) {
        case MoreGiftViewTypeInitView:
        {
             return converDataArray.count;
        }
            break;
        case MoreGiftViewTypeFilterView:
        {
            NSInteger count = searchResultArray.count;
            if (count % 2 == 0) {
                return count / 2;
            } else {
                return count / 2 + 1;
            }
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (viewType) {
        case MoreGiftViewTypeInitView:
        {
            static NSString *identify = @"WSMoreGiftCell";
            WSMoreGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = GET_XIB_FIRST_OBJECT(identify);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.moreGiftBut addTarget:self action:@selector(moreGiftButAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            NSInteger row = indexPath.row;
            cell.leftBut.tag = row;
            cell.rightBut.tag = row;
            cell.moreGiftBut.tag = row;
            NSDictionary *dic = [converDataArray objectAtIndex:row];
            [cell setModel:dic];
            return cell;
        }
            break;
        case MoreGiftViewTypeFilterView:
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
            NSDictionary *leftDic = [searchResultArray objectAtIndex:leftDataIndex];
            [cell setLeftModel:leftDic];
            NSInteger totalCount = searchResultArray.count;
            if (rightDataIndex < totalCount) {
                cell.rightView.hidden = NO;
                NSDictionary *rightDic = [searchResultArray objectAtIndex:rightDataIndex];
                [cell setRightModel:rightDic];
            } else {
                cell.rightView.hidden = YES;
            }
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (viewType) {
        case MoreGiftViewTypeInitView:
        {
            return WSMOREGIFTCELL_HEIGHT;
        }
            break;
        case MoreGiftViewTypeFilterView:
        {
            return WSMOREGIFT_SEARCHRESULT_CELL_HEIGHT;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - leftButAction
- (void)leftButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *modelDic = nil;
    switch (viewType) {
        case MoreGiftViewTypeInitView:
        {
            NSDictionary *dic = [converDataArray objectAtIndex:tag];
            NSArray *array = [dic objectForKey:CATEGORY_DATA_ARRAY];
            modelDic = [array objectAtIndex:0];
        }
            break;
        case MoreGiftViewTypeFilterView:
        {
            modelDic = [searchResultArray objectAtIndex:tag];
        }
            break;
        default:
            break;
    }

    [self toGiftDetailVC:modelDic];
}

#pragma mark rightButAction
- (void)rightButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *modelDic = nil;
    switch (viewType) {
        case MoreGiftViewTypeInitView:
        {
            NSDictionary *dic = [converDataArray objectAtIndex:tag];
            NSArray *array = [dic objectForKey:CATEGORY_DATA_ARRAY];
            modelDic = [array objectAtIndex:1];
        }
            break;
        case MoreGiftViewTypeFilterView:
        {
            modelDic = [searchResultArray objectAtIndex:tag];
        }
            break;
        default:
            break;
    }
    [self toGiftDetailVC:modelDic];
}

- (void)moreGiftButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [converDataArray objectAtIndex:tag];
    NSString *title = [dic objectForKey:CATEGORY_TITLE];
    WSGiftTypeViewController *giftTypeVC = [[WSGiftTypeViewController alloc] init];
    giftTypeVC.typeName = title;
    [self.navigationController pushViewController:giftTypeVC animated:YES];
}

- (void)toGiftDetailVC:(id)param
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    giftDetailVC.giftId = [param stringForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

@end
