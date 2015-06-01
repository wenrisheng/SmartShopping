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
#import "WSInStoreNoSignScopeViewController.h"
#import "WSLocationDetailViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSSearchViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "WSSearchCommonViewController.h"

typedef NS_ENUM(NSInteger, SearchType) {
    SearchTypeInStore = 0,
    SearchTypeOutStore,
};

@interface WSPromotionCouponViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NavigationBarButSearchButViewDelegate, WSPromotionCouponInStoreCollectionViewCellDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    NSMutableArray *inStoreDataArray;
    NSMutableArray *outStoreDataArray;
    SearchType searchType;
    int inStoreCurPage;
    int outStoreCurPage;
    
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

@property (strong, nonatomic) NSString *outStore_districtId; //区id
@property (strong, nonatomic) NSString *outStore_townId;// 商圈id
@property (strong, nonatomic) NSString *outStore_shopTypeId; // 商店类型id
@property (strong, nonatomic) NSString *outStore_retailId; //零售商id
@property (strong, nonatomic) NSString *outStore_distance; //距离
@property (strong, nonatomic) NSString *outStore_categoryId; //品类id
@property (strong, nonatomic) NSMutableArray *outStore_brandIds; //品牌id数组

@property (strong, nonatomic) NSString *inStore_shopId;
@property (strong, nonatomic) NSString *inStore_categoryId; //品类id
@property (strong, nonatomic) NSMutableArray *inStore_brandIds; //品牌id数组

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
@property (weak, nonatomic) IBOutlet UICollectionView *outStoreCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *instoreCollectionView;



@end

@implementation WSPromotionCouponViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    inStoreDataArray = [[NSMutableArray alloc] init];
    outStoreDataArray = [[NSMutableArray alloc] init];
    _outStore_brandIds = [[NSMutableArray alloc] init];
    _inStore_brandIds = [[NSMutableArray alloc] init];
    
    domainFDataArray = [[NSMutableArray alloc] init];
    domainSDataDic = [[NSMutableDictionary alloc] init];
    storeFDataArray = [[NSMutableArray alloc] init];
    storeSDic = [[NSMutableDictionary alloc] init];
    pinleiFDataArray = [[NSMutableArray alloc] init];
    pinleiSDic = [[NSMutableDictionary alloc] init];

    // 初始化视图
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self clearParam];
    // 开始初始化数据在店外
    searchType = SearchTypeOutStore;
    isSelectedPinlei = NO;
    isShowDoubleTableView = NO;
    _inStore_categoryId = nil;
    outStoreCurPage = 0;
    inStoreCurPage= 0;
    [outStoreDataArray removeAllObjects];
    [_outStore_brandIds removeAllObjects];
    [inStoreDataArray removeAllObjects];
    [_inStore_brandIds removeAllObjects];
    [_outStoreCollectionView reloadData];
    [_instoreCollectionView reloadData];
    _instoreCollectionView.hidden = YES;
    _outStoreCollectionView.hidden = NO;
    _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = YES;
    
    NSArray *titleArray = @[@"附近", @"所有商店"];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger  count = titleArray.count;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[titleArray objectAtIndex:i] forKey:TABSLIDEGAPTEXTVIEW_IMAGE_TITLE];
        [dataArray addObject:dic];
    }
    [_outStoreTabSlideManagerView.tabSlideGapTextView setTabSlideDataArray:dataArray];
    
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
   
    
    // 判断用户是否在店内
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSProjUtil isInStoreWithIsInStoreType:IsInStoreTypePromotionCoupon callback:^(id result) {
       BOOL isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
        // 在店内
        if (isInStore) {
            NSDictionary *isInShop = [result objectForKey:IS_IN_SHOP_DATA];
            self.isInShop = isInShop;
            self.inStore_shopId = [isInShop stringForKey:@"shopId"];
            // 请求商店详情
            outStoreCurPage = 0;
            [self requestStoreDetail];
            // 不在店内
        } else {
            [self toOutStoreStatus];
#if DEBUG
            self.city = @"广州";
#endif
            if (_city.length > 0) {
                inStoreCurPage = 0;
                [self requestOutShopGoodsList];
            } else {
                [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
            }
            
            [_outStoreCollectionView reloadData];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (doubleTableView) {
        doubleTableView.hidden = YES;
    }
}

#pragma mark - 请求商店详情
- (void)requestStoreDetail
{
    //请求商店详情接口获取商店名
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    
    self.inStore_shopId = self.inStore_shopId.length > 0 ? self.inStore_shopId : @"";
    self.inStore_categoryId = self.inStore_categoryId.length > 0 ? self.inStore_categoryId : @"";

    
    [params setValue:_inStore_shopId forKey:@"shopid"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    [params setValue:_inStore_categoryId forKey:@"categoryId"];
    if (_inStore_brandIds.count != 0) {
        [params setValue:_inStore_brandIds forKey:@"brandIds"];
    } else {
        [params setValue:@"" forKey:@"brandIds"];
    }
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [params setValue:[NSString stringWithFormat:@"%d", inStoreCurPage + 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCheckMoreGoodsList] data:params tag:WSInterfaceTypeCheckMoreGoodsList sucCallBack:^(id result) {
        [_instoreCollectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            _instoreCollectionView.backgroundColor = [UIColor whiteColor];
            NSDictionary *shop = [[result objectForKey:@"data"] objectForKey:@"shop"];
            self.shop = shop;
            NSString *shopName = [shop objectForKey:@"shopName"];
            shopName = shopName == nil ? @"" : shopName;
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
            searchType = SearchTypeInStore;
            [_instoreCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        [_instoreCollectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismiss];

    } showMessage:YES];
}

#pragma mark 店外查询接口
- (void)requestOutShopGoodsList
{
    if (_city.length == 0) {
        [SVProgressHUD showSuccessWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_outStoreCollectionView.header endRefreshing];
        return;
    }
    searchType = SearchTypeOutStore;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    self.outStore_districtId = self.outStore_districtId.length > 0 ? self.outStore_districtId : @"";
    self.outStore_townId = self.outStore_townId.length > 0 ? self.outStore_townId : @"";
    self.outStore_shopTypeId = self.outStore_shopTypeId.length > 0 ? self.outStore_shopTypeId : @"";
    self.outStore_retailId = self.outStore_retailId.length > 0 ? self.outStore_retailId : @"";
    self.outStore_categoryId = self.outStore_categoryId.length > 0 ? self.outStore_categoryId : @"";
    self.outStore_distance = self.outStore_distance.length > 0 ? self.outStore_distance : @"";
    [params setValue:_city forKey:@"cityName"];
   
    [params setValue:_outStore_districtId forKey:@"districtId"];
    [params setValue:_outStore_townId forKey:@"townId"];
    [params setValue:_outStore_shopTypeId forKey:@"shopTypeId"];
    [params setValue:_outStore_retailId forKey:@"retailId"];
    [params setValue:_outStore_categoryId forKey:@"categoryId"];
    if (_outStore_brandIds.count != 0) {
        [params setValue:_outStore_brandIds forKey:@"brandIds"];
    } else {
         [params setValue:@"" forKey:@"brandIds"];
    }
    
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    //    [params setValue:@"2000" forKey:@"distance"];
    [params setValue:[NSString stringWithFormat:@"%d", outStoreCurPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeOutShopGoodsList] data:params tag:WSInterfaceTypeOutShopGoodsList sucCallBack:^(id result) {
        [_outStoreCollectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *shopList = [[result objectForKey:@"data"] objectForKey:@"shopList"];
            NSInteger count = shopList.count;
            NSMutableArray *shopArray = [NSMutableArray array];
            for (int i = 0; i < count; i++) {
                NSDictionary *shop = [shopList objectAtIndex:i];
                NSMutableDictionary *resultShopDic = [NSMutableDictionary dictionaryWithDictionary:shop];
                NSArray *goodsList = [shop objectForKey:@"goodsList"];
                NSInteger goodCount = goodsList.count;
                NSMutableArray *tempArray = [NSMutableArray array];
                for (int j = 0; j < goodCount; j++) {
                    NSDictionary *goodDic = [goodsList objectAtIndex:j];
                    NSMutableDictionary *resultGoodDic = [NSMutableDictionary dictionaryWithDictionary:goodDic];
                    [resultGoodDic setValue:[shop stringForKey:@"shopId"] forKey:@"shopId"];
                    [tempArray addObject:resultGoodDic];
                }
                [resultShopDic setValue:tempArray forKey:@"goodsList"];
                [shopArray addObject:resultShopDic];
            }
            if (inStoreCurPage == 0) {
                [outStoreDataArray removeAllObjects];
            }
            inStoreCurPage++;
            [outStoreDataArray addObjectsFromArray:shopArray];
            [_outStoreCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        [_outStoreCollectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    } showMessage:YES];
}


- (void)clearParam
{
    self.outStore_districtId = nil;
    self.outStore_townId = nil;
    self.outStore_shopTypeId = nil;
    self.outStore_retailId = nil;
    self.outStore_distance = nil;
    self.outStore_categoryId = nil;
    [self.outStore_brandIds removeAllObjects];
    
    self.inStore_shopId = nil;
    self.inStore_categoryId = nil;
    [self.inStore_brandIds removeAllObjects];
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
    self.city = city;
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    _navigationBarManagerView.navigationBarButSearchButView.leftLabel.text = city;
    DLog(@"定位：%@", city);
}

#pragma mark - 初始化视图
- (void)initView
{
    //   导航条
    _navigationBarManagerView.navigationBarButSearchButView.delegate = self;
    _navigationBarManagerView.navigationBarButSearchButView.leftLabel.text = @"--";
    [_navigationBarManagerView.navigationBarButSearchButView.leftBut setEnabled:NO];
    
    // 店外
    //tab 切换按钮
    _inStoreTabSlideMnagerView.hidden = YES;
    _outStoreTabSlideManagerView.hidden = NO;
    _outStoreTabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _outStoreTabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-up";
    _outStoreTabSlideManagerView.tabSlideGapTextView.imageheight = TOP_TAB_IMAGE_WIDTH;
    _outStoreTabSlideManagerView.tabSlideGapTextView.imageWith = TOP_TAB_IMAGE_WIDTH;
    
    _outStoreTabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        [self outOfStoreClickTag:index];
    };
    
    // 注册  店外
    [_outStoreCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponOutStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell"];
    [_outStoreCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView"];
    CHTCollectionViewWaterfallLayout *outStoreLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
    outStoreLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    outStoreLayout.headerHeight = 0;
    outStoreLayout.footerHeight = 0;
    outStoreLayout.minimumColumnSpacing = 20;
    outStoreLayout.minimumInteritemSpacing = 20;
    outStoreLayout.columnCount = 1;
    _outStoreCollectionView.collectionViewLayout = outStoreLayout;
    [_outStoreCollectionView addLegendHeaderWithRefreshingBlock:^{
        outStoreCurPage = 0;
        [self requestOutShopGoodsList];
    }];
    [_outStoreCollectionView addLegendHeaderWithRefreshingBlock:^{
        [self requestOutShopGoodsList];
    }];

    
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

    
    // 店内
    [_instoreCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView"];
    [_instoreCollectionView registerNib:[UINib nibWithNibName:@"WSPromotionCouponInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell"];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = WSPROMOTIONCOUPON_INSTORE_COLLECTIONREUSABLEVIEW_HEIGHT;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    _instoreCollectionView.collectionViewLayout = layout;
    
    [_instoreCollectionView addLegendHeaderWithRefreshingBlock:^{
        inStoreCurPage = 0;
        [self requestStoreDetail];
    }];
    [_instoreCollectionView addLegendFooterWithRefreshingBlock:^{
        [self requestStoreDetail];
    }];
}

#pragma mark - 品类搜索按钮事件
- (void)inStoreSearchButAction:(UIButton *)but
{
    if (_inStore_categoryId) {
        WSFilterBrandViewController *filterBrandVC = [[WSFilterBrandViewController alloc] init];
        filterBrandVC.mainId = self.inStore_categoryId;
        filterBrandVC.callBack = ^(NSArray *array) {
            NSMutableArray *subIdArray = [NSMutableArray array];
            BOOL hasMain = NO; // 是否选了全部
            for (NSDictionary *dic in array) {
                NSString *mainId = [dic stringForKey:@"mainId"];
                if (mainId) {
                    hasMain = YES;
                    self.inStore_categoryId = mainId;
                    [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = [dic objectForKey:@"name"];
                    [_inStore_brandIds removeAllObjects];
                    inStoreCurPage = 0;
                    [self requestStoreDetail];
                    break;
                }
                NSString *subId = [dic stringForKey:@"subId"];
                [subIdArray addObject:subId];
            }
            if (!hasMain) {
                self.inStore_brandIds = subIdArray;
                if (_inStore_brandIds.count > 0) {
                    inStoreCurPage = 0;
                    [self requestStoreDetail];
                }
            }
        };
        [self.navigationController pushViewController:filterBrandVC animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先选择品类" duration:TOAST_VIEW_TIME];
    }
}

#pragma mark - 切换到在店内的状态
- (void)toInStoreStatus:(NSString *)storeName
{
    _outStoreTabSlideManagerView.hidden = YES;
    _outStoreCollectionView.hidden = YES;
    _inStoreTabSlideMnagerView.hidden = NO;
    _instoreCollectionView.hidden = NO;
    _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = NO;
    searchType = SearchTypeInStore;
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
    _instoreCollectionView.backgroundColor = [UIColor clearColor];
    [_instoreCollectionView reloadData];
}

- (void)toOutStoreStatus
{
    _outStoreTabSlideManagerView.hidden = NO;
    _outStoreCollectionView.hidden = NO;
    _inStoreTabSlideMnagerView.hidden = YES;
    _instoreCollectionView.hidden = YES;
    _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = YES;
    searchType = SearchTypeOutStore;
    _outStoreCollectionView.backgroundColor =  [UIColor colorWithRed:0.878 green:0.882 blue:0.886 alpha:1.000];
    [_outStoreCollectionView reloadData];
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
            if (storeFDataArray.count == 0) {
                [self requestGetShopTypeList];
            } else {
                [self showStoreTypeSelectView];
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

#pragma mark - 显示附近区域选择view
- (void)showNearDomainSelectView
{
    isShowDoubleTableView = YES;
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.dataArrayF = nil;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    if (_outStoreTabSlideManagerView.hidden) {
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
        self.outStore_districtId = districtId;
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
        self.outStore_townId = [SDic stringForKey:@"townId"];
        
        // 在店内
        if (_outStoreTabSlideManagerView.hidden) {
             [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
            
        // 在店外
        } else {
           [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:0].label.text = title;
        }
       
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;

        // 无论店内店外都是搜索商店
        _outStoreCollectionView.hidden = NO;
        _instoreCollectionView.hidden = YES;
        outStoreCurPage = 0;
        [outStoreDataArray removeAllObjects];
        [_outStoreCollectionView reloadData];
        searchType = SearchTypeOutStore;
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
        self.outStore_shopTypeId = shopTypeId;
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
        
        // 在店内
        if (_outStoreTabSlideManagerView.hidden) {
            [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        // 在店外
        } else {
            [_outStoreTabSlideManagerView.tabSlideGapTextView getItemViewWithIndex:1].label.text = title;
        }
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        
        self.outStore_retailId = [SDic stringForKey:@"retailId"];
        
        // 无论店内店外都是搜索商店
        _outStoreCollectionView.hidden = NO;
        _instoreCollectionView.hidden = YES;
        outStoreCurPage = 0;
        [outStoreDataArray removeAllObjects];
        [_outStoreCollectionView reloadData];
        searchType = SearchTypeOutStore;
        [self requestOutShopGoodsList];
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
    
    doubleTable.dataArrayF = tempFArray;
    doubleTable.dataArrayS = nil;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.tableSCallBack = nil;
    doubleTable.tableFCallBack = ^(NSInteger index) {
        pinleiFIndex = (int)index;
        NSDictionary *dic = [pinleiFDataArray objectAtIndex:index];
        NSString *mainId = [dic stringForKey:@"mainId"];
        self.inStore_categoryId = mainId;
        NSString *name = [dic stringForKey:@"name"];
        [_inStoreTabSlideMnagerView.tabSlideGapTextView getItemViewWithIndex:2].label.text = name;
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        inStoreCurPage = 0;
        [self requestStoreDetail];
    };
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
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAreaList] data:@{@"cityName": _city} tag:WSInterfaceTypeGetAreaList sucCallBack:^(id result) {
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
  
    } showMessage:YES];
}

#pragma mark  请求二级区域筛选getAreaList
- (void)requestGetSAreaListWithDistrictId:(NSString *)districtId
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败!" duration:TOAST_VIEW_TIME];
        return;
    }

    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAreaList] data:@{@"cityName": _city, @"districtId": districtId} tag:WSInterfaceTypeGetAreaList sucCallBack:^(id result) {
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

    } showMessage:YES];
}

#pragma mark - 所有商店筛选
- (void)requestGetShopTypeList
{
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopTypeList] data:nil tag:WSInterfaceTypeGetShopTypeList sucCallBack:^(id result) {
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
       
    } showMessage:YES];
}

#pragma mark  请求二级商店
- (void)requestGetShopTypeListWithShopTypeId:(NSString *)shopTypeId
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopTypeList] data:@{@"shopTypeId": shopTypeId} tag:WSInterfaceTypeGetShopTypeList sucCallBack:^(id result) {
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

    } showMessage:YES];
}

#pragma mark - 请求一级品类
- (void)requestDetShopCategory
{
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetShopCategory] data:@{@"level": @"1"} tag:WSInterfaceTypeGetShopCategory sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSArray *categorys = [[result objectForKey:@"data"] objectForKey:@"categorys"];
            [pinleiFDataArray removeAllObjects];
            [pinleiFDataArray addObjectsFromArray:categorys];
            [self showPinleiSelectView];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    } showMessage:YES];

}

#pragma mark - 搜索框代理
#pragma mark  NavigationBarButSearchButViewDelegate
- (BOOL)navigationBarSearchViewTextFieldShouldBeginEditing:(UITextField *)textField
{
//    WSSearchViewController *searchHistoryVC =[[WSSearchViewController alloc] init];
//    [self.navigationController pushViewController:searchHistoryVC animated:YES];
    WSSearchCommonViewController *searchCommon = [[WSSearchCommonViewController alloc] init];
    [self.navigationController pushViewController:searchCommon animated:YES];

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
    NSInteger tag = collectionView.tag;
    switch (tag) {
            // 店外
        case 0:
        {
             tempArray = outStoreDataArray;
        }
            break;
        // 店内
        case 1:
        {
            tempArray = inStoreDataArray;
        }
            break;
        default:
            break;
    }
    NSInteger count = tempArray.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = collectionView.tag;
     NSInteger row = indexPath.row;
    switch (tag) {
        // 店外
        case 0:
        {
            WSPromotionCouponOutStoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell" forIndexPath:indexPath];
            cell.dealInCell = NO;
            NSMutableDictionary *dic = [outStoreDataArray objectAtIndex:row];
            cell.downloadImageFinish = ^() {
                CHTCollectionViewWaterfallLayout *layout =
                (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
                [layout invalidateLayout];
            };
            [cell setModel:dic];
            [cell.seeMoreBut addTarget:self action:@selector(outStoreSeeMoreButAction:) forControlEvents:UIControlEventTouchUpInside];

            return cell;
        }
            break;
        // 店内
        case 1:
        {
            WSPromotionCouponInStoreCollectionViewCell *cell = (WSPromotionCouponInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponInStoreCollectionViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            NSMutableDictionary *dic = [inStoreDataArray objectAtIndex:row];
            cell.downloadImageFinish = ^() {
                CHTCollectionViewWaterfallLayout *layout =
                (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
                [layout invalidateLayout];
            };
            [cell setModel:dic];
           
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = collectionView.tag;
    NSInteger row = indexPath.row;
    switch (tag) {
            // 店外
        case 0:
        {
            NSMutableDictionary *dic = [outStoreDataArray objectAtIndex:row];
            NSArray *goodsList = [dic objectForKey:@"goodsList"];
            float width = collectionView.bounds.size.width;
            UIImage *image = nil;
            for (NSDictionary * dic in goodsList) {
                NSString *goodsLogo = [dic objectForKey:@"goodsLogo"];
                NSString *goodsLogoURL = [WSInterfaceUtility getImageURLWithStr:goodsLogo];
                if (!image) {
                    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:goodsLogoURL];
                    if (!image) {
                        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:goodsLogoURL];
                    }
                }
            }
            if (image) {
                width = WS_PROMOTION_COUPON_OUTSTORE_COLLECTION_VIEW_CELL_IMAGE_WIDTH_PERCENG * SCREEN_WIDTH;
                float height = image.size.height * width / image.size.width;
                return CGSizeMake(collectionView.bounds.size.width, WSPROMOTION_COUPON_OUTSTORE_COLLECTIONVIEW_CELL_HEIGHT - WS_PROMOTION_COUPON_OUTSTORE_COLLECTION_VIEW_CELL_IMAGE_HEIGHT + height);

            }
            
            return CGSizeMake(width, WSPROMOTION_COUPON_OUTSTORE_COLLECTIONVIEW_CELL_HEIGHT);
        }
            break;
        // 店内
        case 1:
        {
            CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
            NSDictionary *dic = [inStoreDataArray objectAtIndex:row];
            NSString *goodsLogo = [dic objectForKey:@"goodsLogo"];
            NSString *goodsLogoURL = [WSInterfaceUtility getImageURLWithStr:goodsLogo];
            UIImage *image = nil;
            image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:goodsLogoURL];
            if (!image) {
                image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:goodsLogoURL];
            }
            if (image) {
                float height = image.size.height * width / image.size.width;
                return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL - HOMECOLLECTIONVIEWCELL_IMAGE_HEIGHT_SMALL + height);
            }
            return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL);
        }
            break;
        default:
            break;
    }
    return CGSizeZero;
}


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
    NSInteger tag = collectionView.tag;
    switch (tag) {
             // 店外
        case 0:
        {
            return CGSizeMake(collectionView.bounds.size.width, WSPROMOTIONCOUPON_INSTORE_COLLECTIONREUSABLEVIEW_HEIGHT);
        }
            break;
        // 店内
        case 1:
        {
            
            return CGSizeZero;
        }
            break;
        default:
            break;
    }
    return CGSizeZero;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = collectionView.tag;
    switch (tag) {
            // 店外
        case 0:
        {
            
        }
            break;
        //在店内
        case 1:
        {
            if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
                WSPromotionCouponInStoreCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView" forIndexPath:indexPath];
                [view.signupBut addTarget:self action:@selector(signupButAction:) forControlEvents:UIControlEventTouchUpInside];
                NSString *shopLogo = [_shop objectForKey:@"shopLogo"];
                NSString *shopName = [_shop objectForKey:@"shopName"];
                NSString *distance = [_shop objectForKey:@"distance"];
                NSString *resultDicsance = [WSProjUtil converDistanceWithDistanceStr:distance];
                NSString *address = [_shop objectForKey:@"address"];
                [view.loginImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:shopLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    view.loginImageView.contentMode = UIViewContentModeScaleAspectFit;
                }];
                view.storeNameLabel.text = shopName;
                view.addressLabel.text = address;
                view.distanceLabel.text = resultDicsance;
                
                NSString *isSign = [_shop stringForKey:@"isSign"];
                
                // 可以签到
                if ([isSign isEqualToString:@"1"]) {
                    view.signupImageView.image = [UIImage imageNamed:@"gainpeas_icon-06"];
                } else {
                    view.signupImageView.image = [UIImage imageNamed:@"gainpeas_icon-04"];
                }
                return view;
            }
        }
            break;
        default:
            break;
    }
  //  if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        WSPromotionCouponInStoreCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"WSPromotionCouponInStoreCollectionReusableView" forIndexPath:indexPath];
        return view;
  //  }

}

#pragma mark 不在店查看更过按钮事件
- (void)outStoreSeeMoreButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [outStoreDataArray objectAtIndex:tag];
    NSString *shopId = [dic stringForKey:@"shopId"];
    outStoreCurPage = 0;
    self.inStore_shopId = shopId;
    [self requestStoreDetail];
}
//
//#pragma mark 不在店内收藏按钮事件
//- (void)outStoreLeftCollectButAction:(UIButton *)but
//{
//    NSInteger tag = but.tag;
//    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
//     NSArray *goodsList = [dic objectForKey:@"goodsList"];
//     NSDictionary *FDic = [goodsList objectAtIndex:0];
//    [self processCollectWithDictionary:FDic shopId:[dic stringForKey:@"shopId"]];
//}
//
//- (void)outStoreRightCollectButAction:(UIButton *)but
//{
//    NSInteger tag = but.tag;
//    NSDictionary *dic = [storeDataArray objectAtIndex:tag];
//    NSArray *goodsList = [dic objectForKey:@"goodsList"];
//    NSDictionary *SDic = [goodsList objectAtIndex:1];
//    [self processCollectWithDictionary:SDic shopId:[dic stringForKey:@"shopId"]];
//}
//
//- (void)outStoreLeftShareButAction:(UIButton *)but
//{
//    
//}
//
//- (void)outStoreRightShareButAction:(UIButton *)but
//{
//    
//}
//
//- (void)processCollectWithDictionary:(NSDictionary *)dic shopId:(NSString *)shopId
//{
//    WSUser *user = [WSRunTime sharedWSRunTime].user;
//    if (user) {
//        NSString *isCollect = [dic stringForKey:@"isCollect"];
//        // 没有收藏  白色安心
//        if ([isCollect isEqualToString:@"N"]) {
//            NSString *goodsid = [dic stringForKey:@"goodsId"];
//            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
//            [SVProgressHUD show];
//            [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
//                [SVProgressHUD dismiss];
//                BOOL flag = [WSInterfaceUtility validRequestResult:result];
//                if (flag) {
//                    outStoreCurPage = 0;
//                    [self requestOutShopGoodsList];
//                    [CollectSucView showCollectSucView];
//                }
//            } failCallBack:^(id error) {
//                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
//            }];
//            
//            // 已收藏
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"亲，您已收藏！" duration:TOAST_VIEW_TIME];
//        }
//    } else {
//        [WSUserUtil actionAfterLogin:^{
//        outStoreCurPage = 0;
//        [self requestOutShopGoodsList];
//        }];
//    }
//
//}
//
//- (void)processProductDetailWithDictionary:(NSDictionary *)dic shopId:(NSString *)shopId
//{
//    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
//    NSString *goodsId = [dic stringForKey:@"goodsId"];
//    productDetailVC.goodsId = goodsId;
//    productDetailVC.shopId = shopId;
//    [self.navigationController pushViewController:productDetailVC animated:YES];
//}
//
//#pragma mark - WSPromotionCouponInStoreCollectionViewCellDelegate
//#pragma mark 在店内 收藏
//- (void)WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:(WSPromotionCouponInStoreCollectionViewCell *)cell
//{
//    NSInteger tag = cell.tag;
//    WSUser *user = [WSRunTime sharedWSRunTime].user;
//    if (user) {
//        NSMutableDictionary *dic = [productDataArray objectAtIndex:tag];
//        NSString *isCollect = [dic stringForKey:@"isCollect"];
//        
//        // 没有收藏  白色安心
//        if ([isCollect isEqualToString:@"N"])
//        {
//            NSString *goodsid = [dic stringForKey:@"goodsId"];
//            NSString *shopId = [dic stringForKey:@"shopId"];
//            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
//            [SVProgressHUD show];
//            [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
//                [SVProgressHUD dismiss];
//                BOOL flag = [WSInterfaceUtility validRequestResult:result];
//                if (flag) {
//                    [dic setValue:@"Y" forKey:@"isCollect"];
//                    [_contentCollectionView reloadData];
//                    [CollectSucView showCollectSucView];
//                }
//            } failCallBack:^(id error) {
//                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
//            }];
//            
//            // 已收藏
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"亲，您已收藏！" duration:TOAST_VIEW_TIME];
//        }
//    } else {
//        [WSUserUtil actionAfterLogin:^{
//            inStoreCurPage = 0;
//            [self requestStoreDetail];
//        }];
//    }
//}
//
//#pragma mark 在店内 分享
//- (void)WSPromotionCouponInStoreCollectionViewCellDidClickRightBut:(WSPromotionCouponInStoreCollectionViewCell *)cell
//{
//    NSInteger tag = cell.tag;
//    DLog(@"分享：%d", (int)tag);
//}

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

@end
