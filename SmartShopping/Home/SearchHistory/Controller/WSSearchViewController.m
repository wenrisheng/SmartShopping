//
//  WSSearchHistoryViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchViewController.h"
#import "WSClearHistoryCell.h"
#import "WSSearchHistoryCell.h"
#import "WSSearchHistoryView.h"
#import "WSPromotionCouponViewController.h"
#import "WSDoubleTableView.h"
#import "WSPromotionCouponInStoreCollectionViewCell.h"
#import "WSPromotionCouponOutStoreCollectionViewCell.h"
#import "WSSearchNoDataCollectionViewCell.h"
#import "WSHomeViewController.h"
#import "WSProductDetailViewController.h"
#import "WSLocationDetailViewController.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "CollectSucView.h"
#import "WSInStoreNoSignViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSFilterBrandViewController.h"

#define SEARCH_STORE_HISTORY_KEY          @"SEARCH_STORE_HISTORY_KEY"     // 商店搜索历史纪录
#define SEARCH_PRODUCT_HISTORY_KEY        @"SEARCH_PRODUCT_HISTORY_KEY"    // 商品搜索历史纪录
#define HISTORY_COUNT                     10

typedef NS_ENUM(NSInteger, SearchType) {
    SearchTypeProduct = 0,
    SearchTypeStore ,
};

@interface WSSearchViewController () <UICollectionViewDataSource, UICollectionViewDataSource, WSSearchViewDelegate, WSPromotionCouponInStoreCollectionViewCellDelegate>
{
    SearchType searchType;
    NSMutableArray *storeDataArray;
    int storeCurPage;
    int productCutPage;
    NSMutableArray *productDataArray;
    NSArray *typeArray;
    WSTableToastView *toastView;
    WSSearchHistoryView *historyView;
    
    WSDoubleTableView *doubleTableView;
    NSMutableArray *dataArrayF;
    NSMutableArray *dataArrayS;
    
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
    int pinleiSIndex;
    
    BOOL hasRequestData;
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

@property (strong, nonatomic) NSDictionary *isInShop;
@property (strong, nonatomic) NSDictionary *shop; // 在店内商店信息
@property (strong, nonatomic) NSString *shopId;
@property (strong, nonatomic) NSString *mainId;// 一级品类id

// 搜索商店 入参
@property (strong, nonatomic) NSString *store_districtId;
@property (strong, nonatomic) NSString *store_townId;
@property (strong, nonatomic) NSString *store_shopTypeId;
@property (strong, nonatomic) NSString *store_retailId;

@property (weak, nonatomic) IBOutlet UIView *tabContainerView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *storeTabView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *productTabView;
@property (weak, nonatomic) IBOutlet WSSearchManagerView *searchManagerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *pinleiBut;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)pinleiButAction:(id)sender;
- (IBAction)backButAction:(id)sender;

@end

@implementation WSSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    hasRequestData = NO;
    searchType = SearchTypeProduct;
    storeDataArray = [[NSMutableArray alloc] init];
    productDataArray = [[NSMutableArray alloc] init];
    
    domainFDataArray = [[NSMutableArray alloc] init];
    domainSDataDic = [[NSMutableDictionary alloc] init];
    storeFDataArray = [[NSMutableArray alloc] init];
    storeSDic = [[NSMutableDictionary alloc] init];
    pinleiFDataArray = [[NSMutableArray alloc] init];
    pinleiSDic = [[NSMutableDictionary alloc] init];
    storeCurPage = 0;
    productCutPage = 0;
    _tabContainerView.hidden = YES;
    [self initView];

    typeArray = @[@"商品", @"商店"];
    [self setSearchTypeTitle];
    [self changeTopTabView];
    _searchManagerView.searchTypeView.leftImageview.image = [UIImage imageNamed:@"arrow-down"];
    [_searchManagerView.searchTypeView.searchBut setTitle:@"" forState:UIControlStateNormal];
    [_searchManagerView.searchTypeView.searchBut setBackgroundImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    _searchManagerView.searchTypeView.typeButActionCallBack = ^(WSSearchTypeView *searchView) {
        if (doubleTableView) {
            doubleTableView.hidden = YES;
        }
        // 搜索类型选择
        [self getToastView];
    };
    _searchManagerView.searchTypeView.didBeginEditingCallback  = ^(WSSearchTypeView *searchView) {
        [self showHistoryView];
    };
    _searchManagerView.searchTypeView.didEndEditingCallback = ^ (WSSearchTypeView *searchView) {
        self.searchname = searchView.centerTextField.text;
        
        // 隐藏历史纪录
        if (historyView) {
            historyView.hidden = YES;
        }
    };
    
    _searchManagerView.searchTypeView.searchButCallback = ^(WSSearchTypeView *searchView) {
        _tabContainerView.hidden = NO;
        [searchView.centerTextField resignFirstResponder];
        switch (searchType) {
            case SearchTypeProduct:
            {
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
              
                productCutPage = 0;
                [self requestSelectGoods];
            }
                break;
            case SearchTypeStore:
            {
                if (_searchname.length > 0) {
                    NSMutableArray *historyArray = [USER_DEFAULT objectForKey:SEARCH_STORE_HISTORY_KEY];
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
                    [USER_DEFAULT setValue:curHistoryArray forKey:SEARCH_STORE_HISTORY_KEY];
                }
                storeCurPage = 0;
                [self requestSearchShop];
            }
                break;
            default:
                break;
        }
    };
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponOutStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSSearchNoDataCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSSearchNoDataCollectionViewCell"];
    [_collectionView addLegendHeaderWithRefreshingBlock:^{
        switch (searchType) {
            case SearchTypeProduct:
            {
                storeCurPage = 0;
                [self requestSelectGoods];
            }
                break;
            case SearchTypeStore:
            {
                productCutPage = 0;
                [self requestSearchShop];
            }
                break;
            default:
                break;
        }
    }];
    [_collectionView addLegendFooterWithRefreshingBlock:^{
        switch (searchType) {
            case SearchTypeProduct:
            {
                [self requestSelectGoods];
            }
                break;
            case SearchTypeStore:
            {
                [self requestSearchShop];
            }
                break;
            default:
                break;
        }

    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - 现实历史纪录
- (void)showHistoryView
{
    WSSearchHistoryView *hisView = [self getSearchHistoryView];
    hisView.hidden = YES;
    switch (searchType) {
        case SearchTypeProduct:
        {
            NSMutableArray *historyArray = [USER_DEFAULT objectForKey:SEARCH_PRODUCT_HISTORY_KEY];
            if (historyArray.count != 0) {WSSearchHistoryView *hisView = [self getSearchHistoryView];
                hisView.dataArray = historyArray;
                [hisView.contentTableView reloadData];
                hisView.hidden = NO;
                hisView.didSelectedCallback = ^(NSInteger index) {
                     _tabContainerView.hidden = NO;
                    NSString *searchname = [historyArray objectAtIndex:index];
                    _searchManagerView.searchTypeView.centerTextField.text = searchname;
                    self.searchname = searchname;
                    productCutPage = 0;
                    [self requestSelectGoods];
                };
                hisView.clearCallback = ^() {
                    [USER_DEFAULT removeObjectForKey:SEARCH_PRODUCT_HISTORY_KEY];
                };
            }
        }
            break;
        case SearchTypeStore:
        {
            NSMutableArray *historyArray = [USER_DEFAULT objectForKey:SEARCH_STORE_HISTORY_KEY];
            if (historyArray.count != 0) {
                hisView.dataArray = historyArray;
                [hisView.contentTableView reloadData];
                hisView.hidden = NO;
                hisView.didSelectedCallback = ^(NSInteger index) {
                     _tabContainerView.hidden = NO;
                    NSString *searchname = [historyArray objectAtIndex:index];
                    _searchManagerView.searchTypeView.centerTextField.text = searchname;
                    self.searchname = searchname;
                    storeCurPage = 0;
                    [self requestSearchShop];
                };
                hisView.clearCallback = ^() {
                    [USER_DEFAULT removeObjectForKey:SEARCH_PRODUCT_HISTORY_KEY];
                };
            }
        }
        default:
            break;
    }
    if (toastView && !toastView.hidden) {
        [self.view bringSubviewToFront:toastView];
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
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    DLog(@"定位：%@", city);
    //    }
}

- (WSSearchHistoryView *)getSearchHistoryView
{
    if (historyView) {
        return historyView;
    }
    historyView = GET_XIB_FIRST_OBJECT(@"WSSearchHistoryView");
    historyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:historyView];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:historyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:historyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:historyView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:historyView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.view addConstraints:@[top, bottom, left, right]];

    return historyView;
}

- (void)initView
{
    NSArray *temp1 = @[@"附近", @"所有商店", @"品类"];
     _productTabView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _productTabView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    _productTabView.tabSlideGapTextView.normalImage = @"arrow-down";
    _productTabView.tabSlideGapTextView.selectedImage = @"arrow-up";
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger  count = temp1.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[temp1 objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dataArray addObject:dic];
    }
    [_productTabView.tabSlideGapTextView setTabSlideDataArray:dataArray];
    _productTabView.tabSlideGapTextView.callBack = ^(int index) {
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

    NSArray *temp2 = @[@"附近", @"所有商店"];
    _storeTabView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    _storeTabView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
     _storeTabView.tabSlideGapTextView.normalImage = @"arrow-down";
    _storeTabView.tabSlideGapTextView.selectedImage = @"arrow-up";
    NSMutableArray *dataArray1 = [NSMutableArray array];
    NSInteger  count1 = temp2.count;
    for (int i = 0; i < count1; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[temp2 objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dataArray1 addObject:dic];
    }
    [_storeTabView.tabSlideGapTextView setTabSlideDataArray:dataArray1];
    _storeTabView.tabSlideGapTextView.callBack = ^(int index) {
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
            default:
                break;
        }
        
    };

}

#pragma mark - 点击了附近tab
- (void)clickNearTab
{
    //    if (isShowDoubleTableView) {
    //        doubleTableView.hidden = YES;
    //        isShowDoubleTableView = NO;
    //    } else {
    if (domainFDataArray.count == 0) {
        if (_city.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        } else {
            [self requestGetFAreaList];
        }
    } else {
        [self showNearDomainSelectView];
    }
    // }
}
#pragma mark 点击了所有商店
- (void)clickAllStore
{
    //    if (isShowDoubleTableView) {
    //        doubleTableView.hidden = YES;
    //        isShowDoubleTableView = NO;
    //    } else {
    if (storeFDataArray.count == 0) {
        [self requestGetShopTypeList];
    } else {
        [self showStoreTypeSelectView];
    }
    //   }
}

#pragma mark 点击了所有品类
- (void)clickAllType
{
    
    //    if (isShowDoubleTableView) {
    //        doubleTableView.hidden = YES;
    //        isShowDoubleTableView = NO;
    //    } else {
    if (pinleiFDataArray.count == 0) {
        [self requestDetShopCategory];
    } else {
        [self showPinleiSelectView];
    }
    
    //  }
}

#pragma mark - 显示附近区域选择view
- (void)showNearDomainSelectView
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    if (searchType == SearchTypeProduct) {
        doubleTable.indicateImageViewCenterXCon.constant = - SCREEN_WIDTH / 3;
    } else {
        doubleTable.indicateImageViewCenterXCon.constant = - SCREEN_WIDTH / 4;
    }
    
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = YES;
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
    
    doubleTable.dataArrayF = tempFArray;
    doubleTable.dataArrayS = tempSArray;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.tableFCallBack = ^(NSInteger index) {
        domainFIndex = (int)index;
        NSDictionary *dic = [domainFDataArray objectAtIndex:index];
        NSString *districtId = [dic stringForKey:@"districtId"];
        switch (searchType) {
            case SearchTypeProduct:
            {
                  self.districtId = districtId;
            }
                break;
            case SearchTypeStore:
            {
                self.store_districtId = districtId;
            }
                break;
            default:
                break;
        }
      
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
            WSDoubleTableView *doubleTable= [self getDoubleTableView];
            doubleTable.dataArrayS = tempSArray;
            [doubleTable.tableS reloadData];
        }
        
    };
    doubleTable.tableSCallBack = ^(NSInteger index) {
        domainSIndex = (int)index;
        NSDictionary *dic = [domainFDataArray objectAtIndex:domainFIndex];
        NSString *districtId = [dic stringForKey:@"districtId"];
        NSArray *secondArray = [domainSDataDic objectForKey:districtId];
        NSDictionary *SDic = [secondArray objectAtIndex:index];
        NSString *title = [SDic objectForKey:@"name"];
       
        if (searchType == SearchTypeProduct) {
            [_productTabView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
             self.townId = [SDic stringForKey:@"townId"];
        } else {
            [_storeTabView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
            self.store_townId = [SDic stringForKey:@"townId"];
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        
      
    };
    
}

#pragma mark 显示商店选择view
- (void)showStoreTypeSelectView
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    switch (searchType) {
        case SearchTypeProduct:
        {
             doubleTable.indicateImageViewCenterXCon.constant = 0;
        }
            break;
        case SearchTypeStore:
        {
             doubleTable.indicateImageViewCenterXCon.constant = SCREEN_WIDTH / 4;
        }
            break;
        default:
            break;
    }
   
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = YES;
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
    
    doubleTable.dataArrayF = tempFArray;
    doubleTable.dataArrayS = tempSArray;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.tableFCallBack = ^(NSInteger index) {
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
            WSDoubleTableView *doubleTable= [self getDoubleTableView];
            doubleTable.dataArrayS = tempSArray;
            [doubleTable.tableS reloadData];
        }
    };
    doubleTable.tableSCallBack = ^(NSInteger index) {
        storeSIndex = (int)index;
        NSDictionary *dic = [storeFDataArray objectAtIndex:storeFIndex];
        NSString *shopTypeId = [dic objectForKey:@"shopTypeId"];
        NSArray *secondArray = [storeSDic objectForKey:shopTypeId];
        NSDictionary *SDic = [secondArray objectAtIndex:index];
        NSString *title = [SDic objectForKey:@"name"];
        self.retailId = [SDic stringForKey:@"retailId"];
        if (searchType == SearchTypeProduct) {
            [_productTabView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        } else {
            [_storeTabView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
    };
    
}

#pragma mark 显示品类选择view
- (void)showPinleiSelectView
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.indicateImageViewCenterXCon.constant = 2*SCREEN_WIDTH / 6;
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = YES;
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
    
    //    NSMutableArray *tempSArray = [NSMutableArray array];
    //    if (FCount > 0) {
    //        NSDictionary *dic = [pinleiFDataArray objectAtIndex:0];
    //        NSString *mainId = [dic stringForKey:@"mainId"];
    //        NSArray *secondArray = [storeSDic objectForKey:mainId];
    //        // 第一个数据的二级品类数据是否为空
    //        if (secondArray.count == 0) {
    //            // 请求二级品类数据
    //            [self requestGetShopCategoryWithParentId:mainId];
    //            // 添加二级品类数据源
    //        } else {
    //            NSDictionary *dic = [pinleiFDataArray objectAtIndex:0];
    //            NSArray *tempArray = [pinleiSDic objectForKey:[dic objectForKey:@"mainId"]];
    //            NSInteger SCount = tempArray.count;
    //            for (int i = 0; i < SCount; i++) {
    //                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
    //                NSDictionary *dic = [tempArray objectAtIndex:i];
    //                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
    //                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
    //                [tempSArray addObject:datadic];
    //            }
    //        }
    //    }
    
    doubleTable.dataArrayF = tempFArray;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.tableSCallBack = nil;
    doubleTable.tableFCallBack = ^(NSInteger index) {
        pinleiFIndex = (int)index;
        NSDictionary *dic = [pinleiFDataArray objectAtIndex:index];
        NSString *mainId = [dic stringForKey:@"mainId"];
        self.mainId = mainId;
        NSString *name = [dic stringForKey:@"name"];
        if (searchType == SearchTypeProduct) {
            [_productTabView.tabSlideGapTextView getItemViewWithIndex:2].label.text = name;
        } else {
            [_storeTabView.tabSlideGapTextView getItemViewWithIndex:1].label.text = name;
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        
        //        NSArray *secondArray = [pinleiSDic objectForKey:mainId];
        //        // 第一个数据的二级数据是否为空
        //        // 二级数据为空时请求数据
        //        if (secondArray.count == 0) {
        //            [self requestGetShopCategoryWithParentId:mainId];
        //
        //            // 二级品类数据不为空时刷新二级表格
        //        } else {
        //            NSMutableArray *tempSArray = [NSMutableArray array];
        //            NSDictionary *dic = [pinleiFDataArray objectAtIndex:index];
        //            NSArray *tempArray = [pinleiSDic objectForKey:[dic stringForKey:@"mainId"]];
        //            NSInteger SCount = tempArray.count;
        //            for (int i = 0; i < SCount; i++) {
        //                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
        //                NSDictionary *dic = [tempArray objectAtIndex:i];
        //                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
        //                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
        //                [tempSArray addObject:datadic];
        //            }
        //            WSDoubleTableView *doubleTable= [self getDoubleTableView];
        //            doubleTable.dataArrayS = tempSArray;
        //            [doubleTable.tableS reloadData];
        //        }
    };
    //    doubleTable.tableSCallBack = ^(NSInteger index) {
    //        isSelectedPinlei = YES;
    //        pinleiSIndex = (int)index;
    //        NSDictionary *dic = [pinleiFDataArray objectAtIndex:pinleiFIndex];
    //        NSString *mainId = [dic stringForKey:@"mainId"];
    //        NSArray *secondArray = [pinleiSDic objectForKey:mainId];
    //        NSDictionary *SDic = [secondArray objectAtIndex:index];
    //        self.categoryId = [SDic stringForKey:@"mainId"];
    //        NSString *title = [SDic objectForKey:@"name"];
    //        if (isInStore) {
    //            [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = title;
    //        } else {
    //            [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
    //        }
    //        WSDoubleTableView *doubleTable= [self getDoubleTableView];
    //        doubleTable.hidden = YES;
    //    };
    
}

- (WSDoubleTableView *)getDoubleTableView
{
    if (doubleTableView) {
        return doubleTableView;
    } else {
        doubleTableView = GET_XIB_FIRST_OBJECT(@"WSDoubleTableView");
        [self.view addSubview:doubleTableView];
        doubleTableView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:@[top, bottom, left, right]];
        return doubleTableView;
    }
}

#pragma mark - 请求区域筛选getAreaList
- (void)requestGetFAreaList
{
    
#ifdef DEBUG
    _city = @"广州";
#endif
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
            
            WSDoubleTableView *doubleTable= [self getDoubleTableView];
            doubleTable.dataArrayS = tempSArray;
            [doubleTable.tableS reloadData];
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
            
            WSDoubleTableView *doubleTable= [self getDoubleTableView];
            doubleTable.dataArrayS = tempSArray;
            [doubleTable.tableS reloadData];
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

- (void)doResetSearch
{
    switch (searchType) {
        case SearchTypeProduct:
        {
            productCutPage = 0;
            [self requestSelectGoods];
        }
            break;
        case SearchTypeStore:
        {
            productCutPage = 0;
            [self requestSearchShop];
        }
            break;
        default:
            break;
    }
}

//#pragma mark 请求二级品类
//- (void)requestGetShopCategoryWithParentId:(NSString *)ParentId
//{
//    ParentId = ParentId.length > 0 ? ParentId : @"";
//    [SVProgressHUD showWithStatus:@"加载中……"];
//    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopCategory] data:@{@"level": @"2", @"parentId": ParentId} tag:WSInterfaceTypeGetShopTypeList sucCallBack:^(id result) {
//        [SVProgressHUD dismiss];
//        BOOL flag = [WSInterfaceUtility validRequestResult:result];
//        if (flag) {
//            NSArray *categorys = [[result objectForKey:@"data"] objectForKey:@"categorys"];
//            [pinleiSDic setValue:categorys forKey:ParentId];
//            NSMutableArray *tempSArray = [NSMutableArray array];
//            NSInteger SCount = categorys.count;
//            for (int i = 0; i < SCount; i++) {
//                NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
//                NSDictionary *dic = [categorys objectAtIndex:i];
//                [datadic setValue:[dic objectForKey:@"name"] forKey:DOUBLE_TABLE_TITLE];
//                [datadic setValue:[dic objectForKey:@"0"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
//                [datadic setValue:[dic objectForKey:@"1"] forKey:DOUBLE_TABLE_SELECTED_FLAG];
//                [tempSArray addObject:datadic];
//            }
//            
//            WSDoubleTableView *doubleTable= [self getDoubleTableView];
//            doubleTable.dataArrayS = tempSArray;
//            [doubleTable.tableS reloadData];
//        }
//    } failCallBack:^(id error) {
//        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
//    }];
//
//}


- (void)changeTopTabView
{
    switch (searchType) {
        case SearchTypeProduct:
        {
            _productTabView.hidden = NO;
            _storeTabView.hidden = YES;
            _pinleiBut.hidden = NO;
        }
            break;
        case SearchTypeStore:
        {
            _pinleiBut.hidden = YES;
            _productTabView.hidden = YES;
            _storeTabView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)setSearchTypeTitle
{
    WSSearchTypeView *searchView = _searchManagerView.searchTypeView;
    NSString *title = [typeArray objectAtIndex:searchType];
    searchView.typeLabel.text = title;
}

- (WSTableToastView *)getToastView
{
    if (toastView) {
        toastView.hidden = NO;
        return toastView;
    } else {
        toastView = [WSTableToastView getView];
        toastView.titleArray = typeArray;
        [toastView.contentTableView reloadData];
        __weak WSSearchViewController *vc = self;
        __weak WSTableToastView *tasView = toastView;
       // __block SearchType type = searchType;
        toastView.callBack = ^(NSInteger index) {
            tasView.hidden = YES;
            searchType = index;
            [vc setSearchTypeTitle];
            [self changeTopTabView];
            [self showHistoryView];
            [_collectionView reloadData];
        };
        [self.view addSubview:toastView];
        toastView.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *relativeview = _searchManagerView.searchTypeView.leftView;
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:toastView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:toastView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:toastView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relativeview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];

        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:toastView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:typeArray.count * WSCLEARHISTORYCELL_HEIGHT];
        [self.view addConstraints:@[left, right, top, height]];
        return toastView;
    }
}

#pragma mark - 商店搜索
- (void)requestSearchShop
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_collectionView endHeaderAndFooterRefresh];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_city forKey:@"cityName"];
    [params setValue:_store_districtId forKey:@"districtId"];
    [params setValue:_store_townId forKey:@"townId"];
    [params setValue:_store_shopTypeId forKey:@"shopTypeId"];
    [params setValue:_store_retailId forKey:@"retailId"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    if (_searchname.length > 0) {
        [params setValue:_searchname forKey:@"searchname"];
    }
    
    [params setValue:[NSString stringWithFormat:@"%d", storeCurPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSearchShop] data:params tag:WSInterfaceTypeSearchShop sucCallBack:^(id result) {
        [_collectionView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"];
            if (storeCurPage == 0) {
                [storeDataArray removeAllObjects];
            }
            storeCurPage ++;
            
            // 将不可变字典转为可变字典
            NSInteger count = shopList.count;
            NSMutableArray *resultArray = [NSMutableArray array];
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *resultShopDic = [NSMutableDictionary dictionary];
                NSDictionary *shopDic = [shopList objectAtIndex:i];
                [resultShopDic setValuesForKeysWithDictionary:shopDic];
                
                NSArray *tempGoodsList = [shopDic objectForKey:@"goodsList"];
                tempGoodsList = [tempGoodsList converDictionaryToMutableDictionary];
                for (NSMutableDictionary *goodDic in tempGoodsList) {
                    [goodDic setValue:[shopDic stringForKey:@"shopId"] forKey:@"shopId"];
                }
                [resultShopDic setValue:tempGoodsList forKey:@"goodsList"];
                [resultArray addObject:resultShopDic];
            }
           
            [storeDataArray addObjectsFromArray:resultArray];
        }
        [_collectionView reloadData];
    } failCallBack:^(id error) {
         [_collectionView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

#pragma mark  商品搜索
- (void)requestSelectGoods
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_collectionView endHeaderAndFooterRefresh];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
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
    }
   
    [params setValue:[NSString stringWithFormat:@"%d", productCutPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSelectGoods] data:params tag:WSInterfaceTypeSelectGoods sucCallBack:^(id result) {
        [_collectionView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"] ;
            if (productCutPage == 0) {
                [productDataArray removeAllObjects];
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
                    [productDataArray addObject:dic];
                }
            }
            productCutPage ++;
           
        }
        [_collectionView reloadData];
    } failCallBack:^(id error) {
        [_collectionView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!hasRequestData) {
        hasRequestData = YES;
        return 0;
    }
    switch (searchType) {
        case SearchTypeProduct:
        {
            if (productDataArray.count == 0) {
                return 1;
            }
            return productDataArray.count;
        }
            break;
        case SearchTypeStore:
        {
            if (storeDataArray.count == 0) {
                return 1;
            }
            return storeDataArray.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch (searchType) {
        case SearchTypeStore:
        {
            if (storeDataArray.count == 0) {
                WSSearchNoDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSSearchNoDataCollectionViewCell" forIndexPath:indexPath];
                return cell;
            }
            WSPromotionCouponOutStoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell" forIndexPath:indexPath];
            cell.refreshPage = ^() {
                [self refreshPage];
            };
//            [cell.signupBut addTarget:self action:@selector(outStoreSignupButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.logoBut addTarget:self action:@selector(outStoreSeeMoreButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.seeMoreBut addTarget:self action:@selector(outStoreSeeMoreButAction:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [cell.leftCollectBut addTarget:self action:@selector(outStoreLeftCollectButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.rightCollectBut addTarget:self action:@selector(outStoreRightCollectButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.leftShareBut addTarget:self action:@selector(outStoreLeftShareButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.rightShareBut addTarget:self action:@selector(outStoreRightShareButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.leftProductBut addTarget:self action:@selector(leftProductButAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.rightProductBut addTarget:self action:@selector(rightProductButAction:) forControlEvents:UIControlEventTouchUpInside];
            //[cell.distanceBut addTarget:self action:@selector(outStoreDistanceButAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.signupBut.tag = row;
            cell.logoBut.tag = row;
            cell.seeMoreBut.tag = row;
            cell.leftCollectBut.tag = row;
            cell.rightCollectBut.tag = row;
            cell.leftShareBut.tag = row;
            cell.rightShareBut.tag = row;
            cell.leftProductBut.tag = row;
            cell.rightProductBut.tag = row;

            NSDictionary *dic = [storeDataArray objectAtIndex:row];
            [cell setModel:dic];
            return cell;

        }
            break;
        case SearchTypeProduct:
        {
            if (storeDataArray.count == 0) {
                WSSearchNoDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSSearchNoDataCollectionViewCell" forIndexPath:indexPath];
                return cell;
            }
            WSPromotionCouponInStoreCollectionViewCell *cell = (WSPromotionCouponInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            NSDictionary *dic = [productDataArray objectAtIndex:row];
            [cell setModel:dic];
        }
            break;
        default:
            break;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (searchType) {
        case SearchTypeProduct:
        {
            if (productDataArray.count == 0) {
               return CGSizeMake(SCREEN_WIDTH, SCREEN_HEITHT);
            }
            NSInteger row =indexPath.row;
            CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
            if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
                return CGSizeMake(width, WSPromotionCouponInStoreCollectionViewCell_HEIGHT);
            } else {
                return CGSizeMake(width, WSPromotionCouponInStoreCollectionViewCell_HEIGHT_SMALL);
            }

        }
            break;
        case SearchTypeStore:
        {
            if (storeDataArray.count == 0) {
                return CGSizeMake(SCREEN_WIDTH, SCREEN_HEITHT);
            }
             return CGSizeMake(collectionView.bounds.size.width, WSPROMOTION_COUPON_OUTSTORE_COLLECTIONVIEW_CELL_HEIGHT);
        }
            break;
        default:
            break;
    }
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return -20;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CELLECTIONVIEW_CELL_SPACE;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (searchType) {
        case SearchTypeProduct:
        {
            if (productDataArray.count != 0) {
                NSInteger row = indexPath.row;
                NSDictionary *dic = [productDataArray objectAtIndex:row];
                NSString *shopId = [dic stringForKey:@"shopId"];
                WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
                NSString *goodsId = [dic stringForKey:@"goodsId"];
                productDetailVC.goodsId = goodsId;
                productDetailVC.shopId = shopId;
                [self.navigationController pushViewController:productDetailVC animated:YES];

            }
        }
            break;
            
        default:
            break;
    }
}

- (void)refreshPage
{
    if (productDataArray.count != 0) {
        productCutPage = 0;
        [self requestSelectGoods];
    }
    if (storeDataArray.count != 0) {
        storeCurPage = 0;
        [self requestSearchShop];
    }
}

#pragma mark - 搜索商店 
#pragma mark 商品详情按钮事件
- (void)leftProductButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *FDic = [goodsList objectAtIndex:0];
    NSString *shopId = [dic stringForKey:@"shopId"];
    [self processProductDetailWithDictionary:FDic shopId:shopId];
}


- (void)rightProductButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *SDic = [goodsList objectAtIndex:1];
    NSString *shopId = [dic stringForKey:@"shopId"];
    [self processProductDetailWithDictionary:SDic shopId:shopId];
}

#pragma mark  距离按钮事件
- (void)outStoreDistanceButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
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

#pragma mark  签到按钮事件
- (void)outStoreSignupButAction:(UIButton *)but
{
    // 跳到3.3.1 不在签到范围内
    WSInStoreNoSignScopeViewController *inStoreNoSignScopeVC = [[WSInStoreNoSignScopeViewController alloc ] init];
    [self.navigationController pushViewController:inStoreNoSignScopeVC animated:YES];
}

#pragma mark 查看更过按钮事件
- (void)outStoreSeeMoreButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
    NSString *shopId = [dic stringForKey:@"shopId"];
//    inStoreCurPage = 0;
//    self.shopId = shopId;
//    [self requestStoreDetail];
}

#pragma mark 不在店内收藏按钮事件
- (void)outStoreLeftCollectButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *FDic = [goodsList objectAtIndex:0];
    [self processCollectWithDictionary:FDic shopId:[dic stringForKey:@"shopId"]];
}

- (void)outStoreRightCollectButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *SDic = [goodsList objectAtIndex:1];
    [self processCollectWithDictionary:SDic shopId:[dic stringForKey:@"shopId"]];
}

- (void)outStoreLeftShareButAction:(UIButton *)but
{
    
}

- (void)outStoreRightShareButAction:(UIButton *)but
{
    
}

- (void)processCollectWithDictionary:(NSDictionary *)dic shopId:(NSString *)shopId
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSString *isCollect = [dic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                [SVProgressHUD dismiss];
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {

                }
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            }];
            
            // 已收藏
        } else {
            [SVProgressHUD showErrorWithStatus:@"亲，您已收藏！" duration:TOAST_VIEW_TIME];
        }
    } else {
        [WSUserUtil actionAfterLogin:^{

        }];
    }
    
}

- (void)processProductDetailWithDictionary:(NSDictionary *)dic shopId:(NSString *)shopId
{
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [dic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = shopId;
    [self.navigationController pushViewController:productDetailVC animated:YES];
}


#pragma mark - WSPromotionCouponInStoreCollectionViewCellDelegate
#pragma mark 搜索商品 收藏
- (void)WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:(WSPromotionCouponInStoreCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSMutableDictionary *dic = [productDataArray objectAtIndex:tag];
        NSString *isCollect = [dic stringForKey:@"isCollect"];
        
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"])
        {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSString *shopId = [dic stringForKey:@"shopId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                [SVProgressHUD dismiss];
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [dic setValue:@"Y" forKey:@"isCollect"];
                    [_collectionView reloadData];
                    [CollectSucView showCollectSucView];
                }
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            }];
            
            // 已收藏
        } else {
            [SVProgressHUD showErrorWithStatus:@"亲，您已收藏！" duration:TOAST_VIEW_TIME];
        }
    } else {
        [WSUserUtil actionAfterLogin:^{
//            inStoreCurPage = 0;
//            [self requestStoreDetail];
        }];
    }
}

#pragma mark 在店内 分享
- (void)WSPromotionCouponInStoreCollectionViewCellDidClickRightBut:(WSPromotionCouponInStoreCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"分享：%d", (int)tag);
}

#pragma mark - 在店内 到店签到按钮事件
- (void)signupButAction:(UIButton *)but
{
    //如果商店支持到店签到，则有到店签到图标按钮，点击到店签到图标按钮，因为已经在店内，所以跳到4.3.4，如果已完成签到，跳到4.3.6
    NSString *isSign = [_shop stringForKey:@"isSign"];
    NSString *shopId = [_shop stringForKey:@"shopId"];
    // 可以签到
    if ([isSign isEqualToString:@"1"]) {
        [WSUserUtil actionAfterLogin:^{
            WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
            inStoreNoSignVC.shopid = shopId;
            inStoreNoSignVC.shopName = [_shop objectForKey:@"shopName"];
            [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
        }];
        
    } else {
        WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
        storeDetailVC.shopid = shopId;
        [self.navigationController pushViewController:storeDetailVC animated:YES];
    }
}

- (IBAction)cancalButAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pinleiButAction:(id)sender {
    if (_mainId) {
        WSFilterBrandViewController *filterBrandVC = [[WSFilterBrandViewController alloc] init];
        filterBrandVC.mainId = self.mainId;
        filterBrandVC.callBack = ^(NSArray *array) {
            NSMutableArray *subIdArray = [NSMutableArray array];
            BOOL hasMain = NO; // 是否选了全部
            for (NSDictionary *dic in array) {
                NSString *mainId = [dic stringForKey:@"mainId"];
                if (mainId) {
                    hasMain = YES;
                    self.mainId = mainId;
                    [_productTabView.tabSlideGapTextView getItemViewWithIndex:2].label.text = [dic objectForKey:@"name"];
                    [_brandIds removeAllObjects];
                    productCutPage = 0;
                    [self requestSelectGoods];
                    break;
                }
                NSString *subId = [dic stringForKey:@"subId"];
                [subIdArray addObject:subId];
            }
            if (!hasMain) {
                self.brandIds = subIdArray;
                if (_brandIds.count > 0) {
                    productCutPage = 0;
                    [self requestSelectGoods];
                }
            }
        };
        [self.navigationController pushViewController:filterBrandVC animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先选择品类" duration:TOAST_VIEW_TIME];
    }
}

- (IBAction)backButAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
