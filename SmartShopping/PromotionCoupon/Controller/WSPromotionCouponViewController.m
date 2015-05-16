//
//  PromotionCouponViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponViewController.h"
#import "WSPromotionCouponInStoreCollectionReusableView.h"
#import "WSPromotionCouponOutStoreCollectionViewCell.h"
#import "HomeCollectionViewCell.h"
#import "WSHomeViewController.h"
#import "WSFilterBrandViewController.h"
#import "WSPromotionCouponSearchViewController.h"
#import "WSDoubleTableView.h"
#import "CollectSucView.h"
#import "WSProductDetailViewController.h"
#import "WSPromotionCouponInStoreCollectionViewCell.h"

@interface WSPromotionCouponViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NavigationBarButSearchButViewDelegate, WSPromotionCouponInStoreCollectionViewCellDelegate>
{
    NSMutableArray *inStoreDataArray;
    NSMutableArray *outStoreDataArray;
    BOOL isInStore;
    int outStoreCurPage;
    int inStoreCurPage;
    
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
    BOOL isSelectedPinlei;

    
    BOOL isShowDoubleTableView;
}

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;
@property (strong, nonatomic) NSString *districtId; //区id
@property (strong, nonatomic) NSString *townId;// 商圈id
@property (strong, nonatomic) NSString *shopTypeId; // 商店类型id
@property (strong, nonatomic) NSString *retailId; //零售商id
@property (strong, nonatomic) NSString *categoryId; //品类id
@property (strong, nonatomic) NSString *brandIds; //品牌id数组
@property (strong, nonatomic) NSString *distance;

@property (strong, nonatomic) NSDictionary *isInShop;
@property (strong, nonatomic) NSDictionary *shop; // 在店内商店信息
@property (strong, nonatomic) NSString *mainId;// 一级品类id

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *changeContainerView;

// 不在店内
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *outStoreTabSlideManagerView;

// 在店内
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *inStoreTabSlideMnagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;



@end

@implementation WSPromotionCouponViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    inStoreDataArray = [[NSMutableArray alloc] init];
    outStoreDataArray = [[NSMutableArray alloc] init];
    isInStore = NO;
    outStoreCurPage = 0;
    inStoreCurPage = 0;
    
    domainFDataArray = [[NSMutableArray alloc] init];
    domainSDataDic = [[NSMutableDictionary alloc] init];
    storeFDataArray = [[NSMutableArray alloc] init];
    storeSDic = [[NSMutableDictionary alloc] init];
    pinleiFDataArray = [[NSMutableArray alloc] init];
    pinleiSDic = [[NSMutableDictionary alloc] init];
    isSelectedPinlei = NO;
    isShowDoubleTableView = NO;
    // 初始化视图
    [self initView];
    
    
    //[self addTestData];
}

- (void)didReceiveMemoryWarning
{
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
    [self clearParam];
    
    // 判断用户是否在店内
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSProjUtil isInStoreWithIsInStoreType:IsInStoreTypePromotionCoupon callback:^(id result) {
        isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
        // 在店内
        if (isInStore) {
            NSDictionary *isInShop = [result objectForKey:IS_IN_SHOP_DATA];
            self.isInShop = isInShop;
            // 请求商店详情
            [self requestStoreDetail];
            // 不在店内
        } else {
            [self toOutStoreStatus];
            if (outStoreDataArray.count == 0) {
                if (_city.length > 0) {
                    [self requestOutShopGoodsList];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
                }
            }
            [_contentCollectionView reloadData];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [params setValue:[NSString stringWithFormat:@"%d", inStoreCurPage + 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCheckMoreGoodsList] data:params tag:WSInterfaceTypeCheckMoreGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *shop = [[result objectForKey:@"data"] objectForKey:@"shop"];
            self.shop = shop;
            NSString *shopName = [shop objectForKey:@"shopName"];
            isInStore = YES;
            [self toInStoreStatus:shopName];
            if (inStoreCurPage == 0) {
                [inStoreDataArray removeAllObjects];
            }
            inStoreCurPage ++;
            NSArray *goodsList = [shop objectForKey:@"goodsList"];
            NSInteger count = goodsList.count;
            for (int i = 0; i < count; i++) {
                NSDictionary *dic = [goodsList objectAtIndex:i];
                NSMutableDictionary *converDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [inStoreDataArray addObject:converDic];
            }
            [_contentCollectionView reloadData];
        } else {
            //不在店内
            [self toOutStoreStatus];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismiss];
        // 不在店内
        [self toOutStoreStatus];
    } showMessage:NO];
}

- (void)clearParam
{
    self.districtId = nil;
    self.townId = nil;
    self.shopTypeId = nil;
    self.retailId = nil;
    self.categoryId = nil;
    self.brandIds = nil;
    self.distance = nil;
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

#pragma mark - 初始化视图
- (void)initView
{
    //   导航条
    _navigationBarManagerView.navigationBarButSearchButView.delegate = self;
    _navigationBarManagerView.navigationBarButSearchButView.leftLabel.text = @"--";
    [_navigationBarManagerView.navigationBarButSearchButView.leftBut setEnabled:NO];
    
    // tab 切换按钮
    isInStore = NO;
    _inStoreTabSlideMnagerView.hidden = YES;
    _outStoreTabSlideManagerView.hidden = NO;
    _outStoreTabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _outStoreTabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-up";
    _outStoreTabSlideManagerView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _outStoreTabSlideManagerView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    NSArray *titleArray = @[@"附近", @"所有商店"];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger  count = titleArray.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[titleArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dataArray addObject:dic];
    }
    [_outStoreTabSlideManagerView.tabSlideGapTextView setTabSlideDataArray:dataArray];
    _outStoreTabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        [self outOfStoreClickTag:index];
    };
    
    // 添加在店内搜索框右边的搜索按钮
    UIButton *but = [[UIButton alloc] init];
    [but setBackgroundImage:[UIImage imageNamed:@"screening"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(inStoreSearchButAction:) forControlEvents:UIControlEventTouchUpInside];
    // but.backgroundColor = [UIColor grayColor];
    UIView *rightView = _navigationBarManagerView.navigationBarButSearchButView.rightView;
    [rightView clearSubviews];
    [rightView addSubview:but];
    but.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:but attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:30];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:but attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:30];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:but attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rightView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:but attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rightView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [rightView addConstraints:@[width, height, centerX, centerY]];

    // 注册
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponOutStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell"];
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView"];
    [_contentCollectionView addHeaderWithCallback:^{
        if (isInStore) {
            inStoreCurPage = 0;
            [self requestStoreDetail];
        } else {
            [self requestOutShopGoodsList];
        }
    }];
    [_contentCollectionView addFooterWithCallback:^{
        if (isInStore) {
            [self requestStoreDetail];
        } else {
            [self requestOutShopGoodsList];
        }
    }];
}

#pragma mark - 测试数据
- (void)addTestData
{
    [inStoreDataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
    [outStoreDataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
    dataArrayF = [[NSMutableArray alloc] init];
    dataArrayS = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[NSString stringWithFormat:@"title%d", i] forKey:DOUBLE_TABLE_TITLE];
        if (i == 0) {
             [dic setValue:[NSNumber numberWithInt:0] forKey:DOUBLE_TABLE_SELECTED_FLAG];
        } else {
             [dic setValue:[NSNumber numberWithInt:1] forKey:DOUBLE_TABLE_SELECTED_FLAG];
        }
        [dataArrayF addObject:dic];
    }
    
    for (int i = 0; i < 10; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[NSString stringWithFormat:@"title%d", i] forKey:DOUBLE_TABLE_TITLE];
        [dic setValue:[NSNumber numberWithInt:1] forKey:DOUBLE_TABLE_SELECTED_FLAG];
        [dataArrayS addObject:dic];
    }
}

- (void)requestSearchShop
{
    if (_city.length == 0) {
        [SVProgressHUD showSuccessWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_city forKey:@"cityName"];
    if (_districtId) {
        [params setValue:_districtId forKey:@"districtId"];
    }
    if (_townId) {
        [params setValue:_townId forKey:@"townId"];
    }
    if (_shopTypeId) {
        [params setValue:_shopTypeId forKey:@"shopTypeId"];
    }
    if (_retailId) {
        [params setValue:_retailId forKey:@"retailId"];
    }
    if (_categoryId) {
        [params setValue:_categoryId forKey:@"categoryId"];
    }
    
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
    //    [params setValue:@"2000" forKey:@"distance"];
    [params setValue:[NSString stringWithFormat:@"%d", outStoreCurPage + 1] forKey:@"pages"];
    [params setValue:@"20" forKey:@"pageSize"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeOutShopGoodsList] data:params tag:WSInterfaceTypeOutShopGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"];
            if (outStoreCurPage == 0) {
                [outStoreDataArray removeAllObjects];
            }
            [outStoreDataArray addObjectsFromArray:shopList];
            [_contentCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

- (void)requestOutShopGoodsList
{
    if (_city.length == 0) {
        [SVProgressHUD showSuccessWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_city forKey:@"cityName"];
    if (_districtId) {
        [params setValue:_districtId forKey:@"districtId"];
    }
    if (_townId) {
        [params setValue:_townId forKey:@"townId"];
    }
    if (_shopTypeId) {
        [params setValue:_shopTypeId forKey:@"shopTypeId"];
    }
    if (_retailId) {
        [params setValue:_retailId forKey:@"retailId"];
    }
    if (!isInStore) {
        if (_categoryId) {
            [params setValue:_categoryId forKey:@"categoryId"];
        }
    }

    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
//    [params setValue:@"2000" forKey:@"distance"];
    [params setValue:[NSString stringWithFormat:@"%d", outStoreCurPage + 1] forKey:@"pages"];
    [params setValue:@"20" forKey:@"pageSize"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeOutShopGoodsList] data:params tag:WSInterfaceTypeOutShopGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            isInStore = NO;
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"];
            if (outStoreCurPage == 0) {
                [outStoreDataArray removeAllObjects];
            }
            outStoreCurPage++;
            [outStoreDataArray addObjectsFromArray:shopList];
            [_contentCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 在店内搜索按钮事件
- (void)inStoreSearchButAction:(UIButton *)but
{
    if (!_mainId) {
        [SVProgressHUD showErrorWithStatus:@"请先选择品类" duration:TOAST_VIEW_TIME];
        return;
    }
    WSFilterBrandViewController *filterBrandVC = [[WSFilterBrandViewController alloc] init];
    filterBrandVC.mainId = _mainId;
    [self.navigationController pushViewController:filterBrandVC animated:YES];
//    if (isInStore) {
//        [self toOutStoreStatus];
//    } else {
//        [self toInStoreStatus:@"沃尔玛"];
//    }
}

#pragma mark - 切换在不在店内的状态
- (void)toInStoreStatus:(NSString *)storeName
{
    _outStoreTabSlideManagerView.hidden = YES;
    _inStoreTabSlideMnagerView.hidden = NO;
    _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = NO;
    isInStore = YES;
    _inStoreTabSlideMnagerView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _inStoreTabSlideMnagerView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    _inStoreTabSlideMnagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _inStoreTabSlideMnagerView.tabSlideGapTextView.selectedImage = @"arrow-up";
    NSArray *titleArray = @[@"附近", storeName, @"所有品类"];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger  count = titleArray.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[titleArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dataArray addObject:dic];
    }
    [_inStoreTabSlideMnagerView.tabSlideGapTextView setTabSlideDataArray:dataArray];
    _inStoreTabSlideMnagerView.tabSlideGapTextView.callBack = ^(int index) {
        [self inOfStoreClickTag:index];
    };
    _contentCollectionView.backgroundColor = [UIColor clearColor];
    [_contentCollectionView reloadData];
}

- (void)toOutStoreStatus
{
    _outStoreTabSlideManagerView.hidden = NO;
    _inStoreTabSlideMnagerView.hidden = YES;
    _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = YES;
    isInStore = NO;
    _contentCollectionView.backgroundColor =  [UIColor colorWithRed:0.878 green:0.882 blue:0.886 alpha:1.000];
    [_contentCollectionView reloadData];
}

#pragma mark - 不在商店内点击tab
- (void)outOfStoreClickTag:(int)index
{
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
}

#pragma mark 在商店内点击tab
- (void)inOfStoreClickTag:(int)index
{
    switch (index) {
            // 附近
        case 0:
        {
            [self clickNearTab];
        }
            break;
            // 店名
        case 1:
        {
            DLog(@"点击了店名");
            isInStore = YES;
            if (inStoreDataArray == 0) {
                [self requestStoreDetail];
            }
        }
            break;
            // 所有品类
        case 2:
        {
            [self clickAllType];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点击了附近tab
- (void)clickNearTab
{
    if (isShowDoubleTableView) {
        doubleTableView.hidden = YES;
        isShowDoubleTableView = NO;
    } else {
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
}
#pragma mark 点击了所有商店
- (void)clickAllStore
{
    if (isShowDoubleTableView) {
        doubleTableView.hidden = YES;
        isShowDoubleTableView = NO;
    } else {
        if (storeFDataArray.count == 0) {
            [self requestGetShopTypeList];
        } else {
            [self showStoreTypeSelectView];
        }
    }
}

#pragma mark 点击了所有品类
- (void)clickAllType
{
    
    if (isShowDoubleTableView) {
        doubleTableView.hidden = YES;
        isShowDoubleTableView = NO;
    } else {
        if (pinleiFDataArray.count == 0) {
            [self requestDetShopCategory];
        } else {
            [self showPinleiSelectView];
        }

    }
}

#pragma mark - 显示附近区域选择view
- (void)showNearDomainSelectView
{
    isShowDoubleTableView = YES;
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    if (isInStore) {
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
        self.townId = [SDic stringForKey:@"townId"];
        if (isInStore) {
            [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
        } else {
            [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        outStoreCurPage = 0;
        
        [self requestOutShopGoodsList];
    };

}

#pragma mark 显示商店选择view
- (void)showStoreTypeSelectView
{
    isShowDoubleTableView = YES;
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
     doubleTable.indicateImageViewCenterXCon.constant = SCREEN_WIDTH / 4;
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
        if (isInStore) {
            [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        } else {
            [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        };
    
}

#pragma mark 显示品类选择view
- (void)showPinleiSelectView
{
    isShowDoubleTableView = YES;
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.indicateImageViewCenterXCon.constant = SCREEN_WIDTH / 6;
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
        NSString *name = [dic stringForKey:@"mainId"];
        if (isInStore) {
            [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = name;
        } else {
            [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = name;
        }
        
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
        CGRect rect = [_changeContainerView convertRect:_changeContainerView.frame toView:self.view];
        float y = rect.origin.y + rect.size.height;
        float h = self.view.bounds.size.height - y;
        doubleTableView.frame = CGRectMake(0, y, rect.size.width, h);
        [self.view addSubview:doubleTableView];
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

#pragma mark - 搜索框代理 
#pragma mark  NavigationBarButSearchButViewDelegate
- (BOOL)navigationBarSearchViewTextFieldShouldBeginEditing:(UITextField *)textField
{
    WSPromotionCouponSearchViewController *promotioncouponSearchVC = [[WSPromotionCouponSearchViewController alloc] init];
    [self.navigationController pushViewController:promotioncouponSearchVC animated:YES];
    return NO;
}

- (void)navigationBarLeftButClick:(UIButton *)but
{

}

- (void)navigationBarRightButClick:(UIButton *)but
{
   
}

- (void)navigationBarSearchViewTextFieldDidEndEditing:(UITextField *)textField
{
   
}

- (BOOL)navigationBarSearchViewTextFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *tempArray = nil;
    if (isInStore) {
        tempArray = inStoreDataArray;
    } else {
        tempArray = outStoreDataArray;
    }
    NSInteger count = tempArray.count;
    if (count == 0) {
        return 1;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (isInStore) { // 在店内
        WSPromotionCouponInStoreCollectionViewCell *cell = (WSPromotionCouponInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell" forIndexPath:indexPath];
        NSInteger count = inStoreDataArray.count;
        if (count == 0) {
            cell.hidden = YES;
        } else {
            cell.hidden = NO;
            
            cell.validDateLabel.text = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
            cell.delegate = self;
            NSDictionary *dic = [inStoreDataArray objectAtIndex:row];
            [cell setModel:dic];
        }
        return cell;
    } else { // 不在店内
        WSPromotionCouponOutStoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell" forIndexPath:indexPath];
        NSInteger count = outStoreDataArray.count;
        if (count == 0) {
            cell.hidden = YES;
        } else {
            cell.hidden = NO;
            [cell.leftCollectBut addTarget:self action:@selector(outStoreLeftCollectButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightCollectBut addTarget:self action:@selector(outStoreRightCollectButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.leftShareBut addTarget:self action:@selector(outStoreLeftShareButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightShareBut addTarget:self action:@selector(outStoreRightShareButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.leftProductBut addTarget:self action:@selector(leftProductButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightProductBut addTarget:self action:@selector(rightProductButAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.leftCollectBut.tag = row;
            cell.rightCollectBut.tag = row;
            cell.leftShareBut.tag = row;
            cell.rightShareBut.tag = row;
            cell.leftProductBut.tag = row;
            cell.rightProductBut.tag = row;
            
            NSDictionary *dic = [outStoreDataArray objectAtIndex:row];
            [cell setModel:dic];
        }
       
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInStore) { // 在店内
        NSInteger row =indexPath.row;
        CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
        if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
            return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT);
        } else {
            return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL);
        }
    } else { // 不在店内
        return CGSizeMake(collectionView.bounds.size.width, WSPROMOTION_COUPON_OUTSTORE_COLLECTIONVIEW_CELL_HEIGHT);
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (isInStore) {
        return CGSizeMake(collectionView.bounds.size.width, WSPROMOTIONCOUPON_INSTORE_COLLECTIONREUSABLEVIEW_HEIGHT);
    } else {
        return CGSizeZero;
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (isInStore) {
        WSPromotionCouponInStoreCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView" forIndexPath:indexPath];
        [view.signupBut addTarget:self action:@selector(signupButAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *shopLogo = [_shop objectForKey:@"shopLogo"];
        NSString *shopName = [_shop objectForKey:@"shopName"];
        NSString *distance = [_shop objectForKey:@"distance"];
        NSString *resultDicsance = [WSProjUtil converDistanceWithDistanceStr:distance];
        NSString *address = [_shop objectForKey:@"address"];
        [view.loginImageView sd_setImageWithURL:[NSURL URLWithString:shopLogo] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            view.loginImageView.contentMode = UIViewContentModeScaleAspectFit;
        }];
        view.storeNameLabel.text = shopName;
        view.addressLabel.text = address;
        view.distanceLabel.text = resultDicsance;
        
        NSString *isSign = [_shop stringForKey:@"isSign"];
        
        // 可以签到
        if ([isSign isEqualToString:@"1"]) {
            view.signupImageView.image = [UIImage imageNamed:@"gainpeas_icon-06"];
            view.signupBut.enabled = YES;
        } else {
            view.signupImageView.image = [UIImage imageNamed:@"gainpeas_icon-04"];
            view.signupBut.enabled = NO;
        }
        return view;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - 不在店内 商品详情按钮事件
- (void)leftProductButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [outStoreDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *FDic = [goodsList objectAtIndex:0];
    NSString *shopId = [FDic stringForKey:@"shopId"];
    [self processProductDetailWithDictionary:FDic shopId:shopId];
}

- (void)rightProductButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [outStoreDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *SDic = [goodsList objectAtIndex:1];
     NSString *shopId = [SDic stringForKey:@"shopId"];
    [self processProductDetailWithDictionary:SDic shopId:shopId];
}

#pragma mark - 不在店内收藏按钮事件
- (void)outStoreLeftCollectButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [outStoreDataArray objectAtIndex:tag];
     NSArray *goodsList = [dic objectForKey:@"goodsList"];
     NSDictionary *FDic = [goodsList objectAtIndex:0];
    [self processCollectWithDictionary:FDic];
}

- (void)outStoreRightCollectButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [outStoreDataArray objectAtIndex:tag];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *SDic = [goodsList objectAtIndex:1];
    [self processCollectWithDictionary:SDic];
}

- (void)outStoreLeftShareButAction:(UIButton *)but
{
    
}

- (void)outStoreRightShareButAction:(UIButton *)but
{
    
}

- (void)processCollectWithDictionary:(NSDictionary *)dic
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSString *isCollect = [dic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSString *shopId = [dic stringForKey:@"shopId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                [SVProgressHUD dismiss];
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    outStoreCurPage = 0;
                    [self requestOutShopGoodsList];
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
        outStoreCurPage = 0;
        [self requestOutShopGoodsList];
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
#pragma mark 在店内 收藏
- (void)WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:(WSPromotionCouponInStoreCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSMutableDictionary *dic = [inStoreDataArray objectAtIndex:tag];
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
                    [_contentCollectionView reloadData];
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
            inStoreCurPage = 0;
            [self requestStoreDetail];
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

}

@end
