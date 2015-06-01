//
//  WSSearchProductViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/31.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchProductViewController.h"
#import "WSSearchCommonViewController.h"
#import "WSDoubleTableView.h"
#import "WSClearHistoryCell.h"
#import "WSTableToastView.h"
#import "WSTabSlideManagerView.h"
#import "WSFilterBrandViewController.h"
#import "WSSearchHistoryView.h"
#import "WSSearchNoDataCollectionViewCell.h"
#import "WSPromotionCouponInStoreCollectionViewCell.h"
#import "WSHomeViewController.h"

#define SEARCH_PRODUCT_HISTORY_KEY        @"SEARCH_PRODUCT_HISTORY_KEY"    // 商品搜索历史纪录
#define HISTORY_COUNT                     10

@interface WSSearchProductViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    NSMutableArray *domainFDataArray; // 一级区域数据
    NSMutableDictionary *domainSDataDic; // 二级区域数据
    int domainFIndex; // 当前选中的一级区域
    int domainSIndex; // 当前选中的二级区域
    
    NSMutableArray *storeFDataArray;// 商店一级数据
    NSMutableDictionary *storeSDic;// 商店二级数据
    int storeFIndex; // 当前选中的一级商店
    int storeSIndex; // 当前选中的二级商店
    
    NSMutableArray *pinleiFDataArray; // 品类
    NSMutableDictionary *pinleiSDic; // 二级品类
    int pinleiFIndex;
    
    int curPage;
    NSMutableArray *dataArray;
    
    BOOL hasRequest;
}

@property (strong, nonatomic) NSString *searchname;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;
@property (strong, nonatomic) NSString *districtId; //区id
@property (strong, nonatomic) NSString *townId;// 商圈id
@property (strong, nonatomic) NSString *shopTypeId; // 商店类型id
@property (strong, nonatomic) NSString *retailId; //零售商id
@property (strong, nonatomic) NSString *categoryId; //品类id
@property (strong, nonatomic) NSMutableArray *brandIds; //品牌id数组
@property (strong, nonatomic) NSString *distance;

@property (strong, nonatomic) WSDoubleTableView *doubleTableView;
@property (strong, nonatomic) WSTableToastView *toastView;
@property (strong, nonatomic) WSSearchHistoryView *historyView;
@property (weak, nonatomic) IBOutlet WSSearchManagerView *searchManagerView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)backButAction:(id)sender;
- (IBAction)topRightAction:(id)sender;
@end

@implementation WSSearchProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    hasRequest = NO;
    curPage = 0;
    dataArray = [[NSMutableArray alloc] init];
    
    domainFDataArray = [[NSMutableArray alloc] init];
    domainSDataDic = [[NSMutableDictionary alloc] init];
    storeFDataArray = [[NSMutableArray alloc] init];
    storeSDic = [[NSMutableDictionary alloc] init];
    pinleiFDataArray = [[NSMutableArray alloc] init];
    pinleiSDic = [[NSMutableDictionary alloc] init];
    
    _searchManagerView.searchTypeView.typeLabel.text = @"商品";
    
    // 搜索类型事件
    _searchManagerView.searchTypeView.typeButActionCallBack = ^(WSSearchTypeView *searchView) {
        
        _tabSlideManagerView.hidden = NO;
        if (_toastView && !_toastView.hidden) {
            self.toastView.hidden = YES;
        } else {
            self.toastView.hidden = NO;
            __weak UIViewController *VC = self;
            self.toastView.callBack = ^(NSInteger index) {
                if (index == 1) {
                    WSSearchCommonViewController *commonVC = (WSSearchCommonViewController *)VC.parentViewController;
                    VC.view.hidden = YES;
                    commonVC.storeVC.view.hidden = NO;
                }
            };
        }
        _tabSlideManagerView.hidden = NO;
    };
    _searchManagerView.searchTypeView.didBeginEditingCallback  = ^(WSSearchTypeView *searchView) {
        if (_toastView && !_toastView.hidden) {
            self.toastView.hidden = YES;
        }
        NSMutableArray *historyArray = [USER_DEFAULT objectForKey:SEARCH_PRODUCT_HISTORY_KEY];
        if (historyArray.count != 0) {
            self.historyView.hidden = NO;
             self.historyView.dataArray = historyArray;
            [ self.historyView.contentTableView reloadData];
             self.historyView.hidden = NO;
             self.historyView.didSelectedCallback = ^(NSInteger index) {
                NSString *searchname = [historyArray objectAtIndex:index];
                _searchManagerView.searchTypeView.centerTextField.text = searchname;
                self.searchname = searchname;
                curPage = 0;
                [self requestSelectGoods];
            };
           self.historyView.clearCallback = ^() {
               self.historyView.dataArray = nil;
               [ self.historyView.contentTableView reloadData];
                [USER_DEFAULT removeObjectForKey:SEARCH_PRODUCT_HISTORY_KEY];
            };

        }
    };
    _searchManagerView.searchTypeView.didEndEditingCallback = ^ (WSSearchTypeView *searchView) {
        self.searchname = searchView.centerTextField.text;
        
        // 隐藏历史纪录
        if (_historyView && !_historyView.hidden) {
            _historyView.hidden = YES;
        }
    };
    
    _searchManagerView.searchTypeView.shouldReturnCallback =  ^ (WSSearchTypeView *searchView) {
        [self doSearch];
        return YES;
    };
    
    _searchManagerView.searchTypeView.searchButCallback = ^(WSSearchTypeView *searchView) {
        [self doSearch];
    };

    
    _searchManagerView.searchTypeView.leftImageview.image = [UIImage imageNamed:@"arrow-down"];
    [_searchManagerView.searchTypeView.searchBut setTitle:@"" forState:UIControlStateNormal];
    [_searchManagerView.searchTypeView.searchBut setBackgroundImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    
    NSArray *temp1 = @[@"附近", @"所有商店", @"品类"];
    _tabSlideManagerView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _tabSlideManagerView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    _tabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _tabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-up";
    NSMutableArray *tempArray = [NSMutableArray array];
    NSInteger  count = temp1.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[temp1 objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [tempArray addObject:dic];
    }
    [_tabSlideManagerView.tabSlideGapTextView setTabSlideDataArray:tempArray];
    _tabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        switch (index) {
                // 附近
            case 0:
            {
                [self clickNearTab];
            }
                break;
                // 所有商店
            case 1:
            {
                [self clickAllStore];
            }
                break;
                // 品类
            case 2:
            {
                [self clickAllType];
            }
                break;
            default:
                break;
        }
    };
    
    [_collectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSSearchNoDataCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSSearchNoDataCollectionViewCell"];

    [_collectionView addLegendHeaderWithRefreshingBlock:^{
        curPage = 0;
        [self requestSelectGoods];
    }];
    [_collectionView addLegendFooterWithRefreshingBlock:^{
        [self requestSelectGoods];
    }];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    _collectionView.collectionViewLayout = layout;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

        _toastView.hidden = YES;


        _doubleTableView.hidden = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    DLog(@"city:%@", _city);
    NSString *city = [locationDic objectForKey:LOCATION_CITY];
    self.city = city;
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    DLog(@"定位：%@", city);
}

- (void)doSearch
{
    if (_historyView && !_historyView.hidden) {
        _historyView.hidden = YES;
    }
    [_searchManagerView.searchTypeView.centerTextField resignFirstResponder];
    if (_searchname.length > 0) {
        NSMutableArray *historyArray = [USER_DEFAULT objectForKey:SEARCH_PRODUCT_HISTORY_KEY];
        NSMutableArray *curHistoryArray = [NSMutableArray array];
        [curHistoryArray addObject:_searchname];
        [curHistoryArray addObjectsFromArray:historyArray];
        NSInteger count = curHistoryArray.count;
        if (count > HISTORY_COUNT) {
            int subCount = (int)count - HISTORY_COUNT;
            for (int i = 0; i < subCount; i ++) {
                [curHistoryArray removeLastObject];
            }
        }
        [USER_DEFAULT setValue:curHistoryArray forKey:SEARCH_PRODUCT_HISTORY_KEY];
    }
    
    curPage = 0;
    [self requestSelectGoods];
}

- (WSTableToastView *)toastView
{
    if (!_toastView) {
        self.toastView = [WSTableToastView getView];
        NSArray *titlArray = @[@"商品", @"商店"];
        self.toastView.titleArray = titlArray;
        [self.toastView.contentTableView reloadData];
    
        [self.view addSubview:self.toastView];
        self.toastView.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *relativeview = _searchManagerView.searchTypeView.leftView;
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.toastView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.toastView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.toastView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.toastView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:titlArray.count * WSCLEARHISTORYCELL_HEIGHT];
        [self.view addConstraints:@[left, right, top, height]];
    }
    return _toastView;
}

- (WSDoubleTableView *)doubleTableView
{
    if (!_doubleTableView) {
        self.doubleTableView = GET_XIB_FIRST_OBJECT(@"WSDoubleTableView");
        [self.view addSubview:self.doubleTableView];
        self.doubleTableView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.doubleTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tabSlideManagerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.doubleTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.doubleTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.doubleTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:@[top, bottom, left, right]];
    }
    return _doubleTableView;
}

- (WSSearchHistoryView *)historyView
{
    if (!_historyView) {
        self.historyView = GET_XIB_FIRST_OBJECT(@"WSSearchHistoryView");
        self.historyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.historyView];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.historyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_tabSlideManagerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.historyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.historyView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.historyView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:@[top, bottom, left, right]];
    }
    return _historyView;
}

#pragma mark - 点击了附近tab
- (void)clickNearTab
{
    if (domainFDataArray.count == 0) {
        if (_city.length == 0) {
         
            [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        } else {
           [self requestGetFAreaList];
        }
    } else {
        [self showNearDomainSelectView];
    }
}
#pragma mark 点击了所有商店
- (void)clickAllStore
{
    if (storeFDataArray.count == 0) {
        [self requestGetShopTypeList];
    } else {
       [self showStoreTypeSelectView];
    }
}

#pragma mark 点击了所有品类
- (void)clickAllType
{
    if (pinleiFDataArray.count == 0) {
        [self requestDetShopCategory];
    } else {
        [self showPinleiSelectView];
    }
}

#pragma mark - 请求区域筛选getAreaList
- (void)requestGetFAreaList
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败!" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAreaList] data:@{@"cityName": _city} tag:WSInterfaceTypeGetAreaList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *districts = [[result objectForKey:@"data"] objectForKey:@"districts"];
            [domainFDataArray removeAllObjects];
            [domainFDataArray addObjectsFromArray:districts];
            [self showNearDomainSelectView];
            NSInteger count = districts.count;
            if (count > 0) {
                NSDictionary *dic = [districts objectAtIndex:0];
                NSString *districtId = [dic stringForKey:@"districtId"];
                [self requestGetSAreaListWithDistrictId:districtId];
            }
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}
#pragma mark  请求二级区域筛选getAreaList
- (void)requestGetSAreaListWithDistrictId:(NSString *)districtId
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败!" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAreaList] data:@{@"cityName": _city, @"districtId": districtId} tag:WSInterfaceTypeGetAreaList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *towns = [[[result objectForKey:@"data"] objectForKey:@"district"] objectForKey:@"towns"];
            [domainSDataDic setValue:towns forKey:districtId];
            NSMutableArray *tempSArray = [NSMutableArray array];
            NSInteger SCount = towns.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [towns objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [datadic setValue:[dic objectForKey:@"1"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
            
            self.doubleTableView.dataArrayS = tempSArray;
            [self.doubleTableView.tableS reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 所有商店筛选
- (void)requestGetShopTypeList
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopTypeList] data:nil tag:WSInterfaceTypeGetShopTypeList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopTypes = [[result objectForKey:@"data"] objectForKey:@"shopTypes"];
            [storeFDataArray removeAllObjects];
            [storeFDataArray addObjectsFromArray:shopTypes];
            [self showStoreTypeSelectView];
            NSInteger count = shopTypes.count;
            if (count > 0) {
                NSDictionary *dic = [shopTypes objectAtIndex:0];
                NSString *shopTypeId = [dic objectForKey:@"shopTypeId"];
                [self requestGetShopTypeListWithShopTypeId:shopTypeId];
            }
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark  请求二级商店
- (void)requestGetShopTypeListWithShopTypeId:(NSString *)shopTypeId
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopTypeList] data:@{@"shopTypeId": shopTypeId} tag:WSInterfaceTypeGetShopTypeList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *saleRetails = [[result objectForKey:@"data"] objectForKey:@"saleRetails"];
            [storeSDic setValue:saleRetails forKey:shopTypeId];
            NSMutableArray *tempSArray = [NSMutableArray array];
            NSInteger SCount = saleRetails.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [saleRetails objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [datadic setValue:[dic objectForKey:@"1"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
            
            self.doubleTableView.dataArrayS = tempSArray;
            [self.doubleTableView.tableS reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 请求一级品类
- (void)requestDetShopCategory
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopCategory] data:@{@"level": @"1"} tag:WSInterfaceTypeGetShopCategory sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *categorys = [[result objectForKey:@"data"] objectForKey:@"categorys"];
            [pinleiFDataArray removeAllObjects];
            [pinleiFDataArray addObjectsFromArray:categorys];
            [self showPinleiSelectView];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
    
}

#pragma mark - 显示附近区域选择view
- (void)showNearDomainSelectView
{
    self.doubleTableView.dataArrayF = nil;
    self.doubleTableView.dataArrayS = nil;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];
    self.doubleTableView.indicateImageViewCenterXCon.constant = - SCREEN_WIDTH / 3;

    
    self.doubleTableView.hidden = NO;
    self.doubleTableView.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    self.doubleTableView.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.isLeftToRight = YES;
    NSMutableArray *tempFArray = [NSMutableArray array];
    NSInteger FCount = domainFDataArray.count;
    for (int i = 0; i < FCount; i++) {
        NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [domainFDataArray objectAtIndex:i];
        [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
        if (i == 0) {
            [datadic setValue:@"0" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        } else {
            [datadic setValue:@"1" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        }
        [tempFArray addObject:datadic];
    }
    
    NSMutableArray *tempSArray = [NSMutableArray array];
    if (FCount > 0) {
        NSDictionary *dic = [domainFDataArray objectAtIndex:0];
        NSString *districtId = [dic stringForKey:@"districtId"];
        NSArray *secondArray = [domainSDataDic objectForKey:districtId];
        // 第一个数据的二级区域数据是否为空
        if (secondArray.count == 0) {
            // 请求二级区域数据
            [self requestGetSAreaListWithDistrictId:districtId];
            // 添加二级区域数据源
        } else {
            NSDictionary *dic = [domainFDataArray objectAtIndex:0];
            NSArray *tempArray = [domainSDataDic objectForKey:[dic objectForKey:@"districtId"]];
            NSInteger SCount = tempArray.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [tempArray objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:@"0"forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
        }
    }
    
    self.doubleTableView.dataArrayF = tempFArray;
    self.doubleTableView.dataArrayS = tempSArray;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];

    self.doubleTableView.tableFCallBack = ^(NSInteger index) {
        domainFIndex = (int)index;
        NSDictionary *dic = [domainFDataArray objectAtIndex:index];
        NSString *districtId = [dic stringForKey:@"districtId"];
        self.districtId = districtId;
        NSArray *secondArray = [domainSDataDic objectForKey:districtId];
        // 第一个数据的二级区域数据是否为空
        // 二级区域数据为空时请求数据
        if (secondArray.count == 0) {
            [self requestGetSAreaListWithDistrictId:districtId];
            
            // 二级区域数据不为空时刷新二级表格
        } else {
            NSMutableArray *tempSArray = [NSMutableArray array];
            NSDictionary *dic = [domainFDataArray objectAtIndex:index];
            NSArray *tempArray = [domainSDataDic objectForKey:[dic stringForKey:@"districtId"]];
            NSInteger SCount = tempArray.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [tempArray objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:@"0" forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
           
            self.doubleTableView.dataArrayS = tempSArray;
            [self.doubleTableView.tableS reloadData];
        }
        
    };
    self.doubleTableView.tableSCallBack = ^(NSInteger index) {
        domainSIndex = (int)index;
        NSDictionary *dic = [domainFDataArray objectAtIndex:domainFIndex];
        NSString *districtId = [dic stringForKey:@"districtId"];
        NSArray *secondArray = [domainSDataDic objectForKey:districtId];
        NSDictionary *SDic = [secondArray objectAtIndex:index];
        NSString *title = [SDic objectForKey:@"name"];

        [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
        self.townId = [SDic stringForKey:@"townId"];
        curPage = 0;
        [self requestSelectGoods];
        
        self.doubleTableView.hidden = YES;
    };
}


#pragma mark 显示商店选择view
- (void)showStoreTypeSelectView
{
    self.doubleTableView.dataArrayF = nil;
    self.doubleTableView.dataArrayS = nil;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];
    self.doubleTableView.indicateImageViewCenterXCon.constant = 0;

    
    self.doubleTableView.hidden = NO;
    self.doubleTableView.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    self.doubleTableView.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.isLeftToRight = YES;
    NSMutableArray *tempFArray = [NSMutableArray array];
    NSInteger FCount = storeFDataArray.count;
    for (int i = 0; i < FCount; i++) {
        NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [storeFDataArray objectAtIndex:i];
        [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
        if (i == 0) {
            [datadic setValue:@"0" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        } else {
            [datadic setValue:@"1" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        }
        [tempFArray addObject:datadic];
    }
    
    NSMutableArray *tempSArray = [NSMutableArray array];
    if (FCount > 0) {
        NSDictionary *dic = [storeFDataArray objectAtIndex:0];
        NSString *shopTypeId = [dic stringForKey:@"shopTypeId"];
        NSArray *secondArray = [storeSDic objectForKey:shopTypeId];
        // 第一个商店数据的二级商店数据是否为空
        if (secondArray.count == 0) {
            // 请求二级商店数据
            [self requestGetShopTypeListWithShopTypeId:shopTypeId];
            // 添加二级商店数据源
        } else {
            NSDictionary *dic = [storeFDataArray objectAtIndex:0];
            NSArray *tempArray = [storeSDic objectForKey:[dic objectForKey:@"shopTypeId"]];
            NSInteger SCount = tempArray.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [tempArray objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
        }
    }
    
    self.doubleTableView.dataArrayF = tempFArray;
    self.doubleTableView.dataArrayS = tempSArray;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];
    self.doubleTableView.tableFCallBack = ^(NSInteger index) {
        storeFIndex = (int)index;
        NSDictionary *dic = [storeFDataArray objectAtIndex:index];
        NSString *shopTypeId = [dic objectForKey:@"shopTypeId"];
        self.shopTypeId = shopTypeId;
        
        NSArray *secondArray = [storeSDic objectForKey:shopTypeId];
        // 第一个数据的二级数据是否为空
        // 二级数据为空时请求数据
        if (secondArray.count == 0) {
            [self requestGetShopTypeListWithShopTypeId:shopTypeId];
            
            // 二级数据不为空时刷新二级表格
        } else {
            NSMutableArray *tempSArray = [NSMutableArray array];
            NSDictionary *dic = [storeFDataArray objectAtIndex:index];
            NSArray *tempArray = [storeSDic objectForKey:[dic objectForKey:@"shopTypeId"]];
            NSInteger SCount = tempArray.count;
            for (int i = 0; i < SCount; i++) {
                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                NSDictionary *dic = [tempArray objectAtIndex:i];
                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
                [tempSArray addObject:datadic];
            }
            self.doubleTableView.dataArrayS = tempSArray;
            [self.doubleTableView.tableS reloadData];
        }
    };
    self.doubleTableView.tableSCallBack = ^(NSInteger index) {
        storeSIndex = (int)index;
        NSDictionary *dic = [storeFDataArray objectAtIndex:storeFIndex];
        NSString *shopTypeId = [dic objectForKey:@"shopTypeId"];
        NSArray *secondArray = [storeSDic objectForKey:shopTypeId];
        NSDictionary *SDic = [secondArray objectAtIndex:index];
        NSString *title = [SDic objectForKey:@"name"];
        [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        self.retailId = [SDic stringForKey:@"retailId"];
        curPage = 0;
        [self requestSelectGoods];

        self.doubleTableView.hidden = YES;
    };
    
}

#pragma mark 显示品类选择view
- (void)showPinleiSelectView
{
    self.doubleTableView.dataArrayF = nil;
    self.doubleTableView.dataArrayS = nil;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];
    self.doubleTableView.indicateImageViewCenterXCon.constant = 2*SCREEN_WIDTH / 6;
    self.doubleTableView.hidden = NO;
    self.doubleTableView.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    self.doubleTableView.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    self.doubleTableView.isLeftToRight = YES;
    NSMutableArray *tempFArray = [NSMutableArray array];
    NSInteger FCount = pinleiFDataArray.count;
    for (int i = 0; i < FCount; i++) {
        NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [pinleiFDataArray objectAtIndex:i];
        [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
        if (i == 0) {
            [datadic setValue:@"0" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        } else {
            [datadic setValue:@"1" forKey:DOUBLE_TABLE_SELECTED_FLAG];
        }
        [tempFArray addObject:datadic];
    }
    
    self.doubleTableView.dataArrayF = tempFArray;
    self.doubleTableView.dataArrayS = nil;
    [self.doubleTableView.tableF reloadData];
    [self.doubleTableView.tableS reloadData];
    self.doubleTableView.tableSCallBack = nil;
    self.doubleTableView.tableFCallBack = ^(NSInteger index) {
        pinleiFIndex = (int)index;
        NSDictionary *dic = [pinleiFDataArray objectAtIndex:index];
        NSString *mainId = [dic stringForKey:@"mainId"];
        self.categoryId = mainId;
        NSString *name = [dic stringForKey:@"name"];
        [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = name;
        self.doubleTableView.hidden = YES;
    };
}


#pragma mark  商品搜索
- (void)requestSelectGoods
{
#if DEBUG
    self.city = @"广州";
#endif
    hasRequest = YES;
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_collectionView endHeaderAndFooterRefresh];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    self.districtId = self.districtId.length > 0 ? self.districtId : @"";
    self.townId = self.townId.length > 0 ? self.townId : @"";
    self.shopTypeId = self.shopTypeId.length > 0 ? self.shopTypeId : @"";
    self.retailId = self.retailId.length > 0 ? self.retailId : @"";
    self.categoryId = self.categoryId.length > 0 ? self.categoryId : @"";
    self.searchname = self.searchname.length > 0 ? self.searchname : @"";
    
    [params setValue:_city forKey:@"cityName"];
    [params setValue:_districtId forKey:@"districtId"];
    [params setValue:_townId forKey:@"townId"];
    [params setValue:_shopTypeId forKey:@"shopTypeId"];
    [params setValue:_retailId forKey:@"retailId"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    [params setValue:_searchname forKey:@"searchname"];
    [params setValue:_categoryId forKey:@"categoryId"];
    if (_brandIds.count > 0) {
        [params setValue:_brandIds forKey:@"brandIds"];
    } else {
        [params setValue:@"" forKey:@"brandIds"];
    }
    
    [params setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSelectGoods] data:params tag:WSInterfaceTypeSelectGoods sucCallBack:^(id result) {
        [_collectionView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"] ;
            if (curPage == 0) {
                [dataArray removeAllObjects];
            }
            
            // 将不可变字典转变为可变字典
            NSInteger shopCount = shopList.count;
            for (int i = 0; i < shopCount; i++) {
                NSDictionary *shop = [shopList objectAtIndex:i];
                NSArray *goodsList = [shop objectForKey:@"goodsList"];
                NSInteger goodsCount = goodsList.count;
                for (int j = 0; j < goodsCount; j++) {
                    NSDictionary *goods = [goodsList objectAtIndex:j];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setValuesForKeysWithDictionary:goods];
                    [dic setValue:[shop stringForKey:@"shopId"] forKey:@"shopId"];
                    [dataArray addObject:dic];
                }
            }
            curPage++;
            
        }
        [_collectionView reloadData];
    } failCallBack:^(id error) {
        [_collectionView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

#pragma mark - 顶部按钮事件
- (IBAction)backButAction:(id)sender {
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (IBAction)topRightAction:(id)sender {
    if (_categoryId) {
        WSFilterBrandViewController *filterBrandVC = [[WSFilterBrandViewController alloc] init];
        filterBrandVC.mainId = self.categoryId;
        filterBrandVC.callBack = ^(NSArray *array) {
            NSMutableArray *subIdArray = [NSMutableArray array];
            BOOL hasMain = NO; // 是否选了全部
            for (NSDictionary *dic in array) {
                NSString *mainId = [dic stringForKey:@"mainId"];
                if (mainId) {
                    hasMain = YES;
                    self.categoryId = mainId;
                    [_tabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = [dic objectForKey:@"name"];
                    [_brandIds removeAllObjects];
                    curPage = 0;
                    [self requestSelectGoods];
                    break;
                }
                NSString *subId = [dic stringForKey:@"subId"];
                [subIdArray addObject:subId];
            }
            if (!hasMain) {
                self.brandIds = subIdArray;
                if (_brandIds.count > 0) {
                    curPage = 0;
                    [self requestSelectGoods];
                }
            }
        };
        [self.navigationController pushViewController:filterBrandVC animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先选择品类" duration:TOAST_VIEW_TIME];
    }

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!hasRequest) {
        return 0;
    }
    if (dataArray.count == 0) {
        return 1;
    }
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     NSInteger row = indexPath.row;
    if (dataArray.count == 0) {
        WSSearchNoDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSSearchNoDataCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    WSPromotionCouponInStoreCollectionViewCell *cell = (WSPromotionCouponInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell" forIndexPath:indexPath];
    cell.refreshPage = ^ () {
        curPage = 0;
        [self requestSelectGoods];
    };
    cell.downloadImageFinish = ^() {
        CHTCollectionViewWaterfallLayout *layout =
        (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
        [layout invalidateLayout];
    };
    NSMutableDictionary *dic = [dataArray objectAtIndex:row];
    [cell setModel:dic];
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataArray.count == 0) {
        return CGSizeMake(SCREEN_WIDTH, SCREEN_HEITHT);
    }
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
    
    NSDictionary *dic = [dataArray objectAtIndex:row];
    NSString *goodsLogo = [dic objectForKey:@"goodsLogo"];
    NSString *goodsLogoURL = [WSInterfaceUtility getImageURLWithStr:goodsLogo];
    UIImage *image = nil;
    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:goodsLogoURL];
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:goodsLogoURL];
    }
    if (image) {
        float height = image.size.height * width / image.size.width;
        return CGSizeMake(width, WSPromotionCouponInStoreCollectionViewCell_HEIGHT_SMALL - WS_PROMOTIONCOUPON_INSTORE_COLLECTION_VIEW_CELL_IMAGE_HEIGHT + height);
    }

    
    if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, WSPromotionCouponInStoreCollectionViewCell_HEIGHT);
    } else {
        return CGSizeMake(width, WSPromotionCouponInStoreCollectionViewCell_HEIGHT_SMALL);
    }

}

@end
