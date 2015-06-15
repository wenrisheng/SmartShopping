//
//  HomeViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSHomeViewController.h"
#import "HomeHeaderCollectionReusableView.h"
#import "HomeCollectionViewCell.h"
#import "WSInfoListViewController.h"
#import "WSProductDetailViewController.h"
#import "WSAdvertisementDetailViewController.h"
#import "WSLocationDetailViewController.h"
#import "WSNoInStoreViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSScanNoInStoreViewController.h"
#import "WSInviateFriendViewController.h"
#import "CollectSucView.h"
#import "WSCollectHeaderView.h"
#import "WSScanInStoreViewController.h"
#import "WSSearchCommonViewController.h"

typedef NS_ENUM(NSInteger, ShopType)
{
    ShopTypeSuperMarket = 0,
    ShopTypeBaihuoFuzhuang
};

@interface WSHomeViewController () <NavigationBarButSearchButViewDelegate, WSSlideSwitchViewDelegate, HomeCollectionViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    NSMutableArray *superMarketDataArray;
    NSMutableArray *baihuoFuzhuangDataArray;
    NSMutableArray *slideImageArray;
    HomeHeaderCollectionReusableView *headerView;
    WSCollectHeaderView *collectHeaderView;
    ShopType shopType;
    int supermarketCurPage;
    BOOL supermarketToEndPage;
    int baihuoCurPage;
    BOOL baihuoToEndPage;
}

@property (strong, nonatomic) UIImage *downloadAcImage;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *supermarketCollectionView;

@property (strong, nonatomic) NSDictionary *isInShop;
@property (strong, nonatomic) NSDictionary *shop;

@end

@implementation WSHomeViewController

- (void)dealloc
{
    _supermarketCollectionView.dataSource = nil;
    _supermarketCollectionView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    //[_navBarManagerView.navigationBarButSearchButView.rightBut setBackgroundImage:[UIImage imageNamed:@"navigationBarButSearchButView"] forState:UIControlStateNormal];
    _navBarManagerView.navigationBarButSearchButView.delegate = self;
    _navBarManagerView.navigationBarButSearchButView.leftLabel.text = @"--";
    _navBarManagerView.navigationBarButSearchButView.leftBut.enabled = NO;
    // 没有登录时隐藏消息数量
    _navBarManagerView.navigationBarButSearchButView.rightLabel.hidden = YES;
    
    superMarketDataArray = [[NSMutableArray alloc] init];
    baihuoFuzhuangDataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    shopType = ShopTypeSuperMarket;
    supermarketCurPage = 0;
    supermarketToEndPage = NO;
    baihuoCurPage = 0;
    baihuoToEndPage = NO;
    
    // 注册

    [_supermarketCollectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    [_supermarketCollectionView registerNib:[UINib nibWithNibName:@"HomeHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView"];
    [_supermarketCollectionView addLegendFooterWithRefreshingBlock:^{
        [self requestGetHomePageGoos];
    }];

    [_supermarketCollectionView addLegendHeaderWithRefreshingBlock:^{
        switch (shopType) {
            case ShopTypeSuperMarket:
            {
                supermarketCurPage = 0;
            }
                break;
            case ShopTypeBaihuoFuzhuang:
            {
                baihuoCurPage = 0;
            }
                break;
            default:
                break;
        }
        [self requestGetHomePageGoos];
        DLog(@"下拉刷新完成！");
    }];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = HOMEHEADERCOLLECTIONREUSABLEVIEW_HEIGHT;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = COLLECTION_VIEW_GAP;
    layout.minimumInteritemSpacing = COLLECTION_VIEW_GAP;
   _supermarketCollectionView.collectionViewLayout = layout;
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

    // 没有幻灯片时请求幻灯片数据
    if (self.city.length != 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    if (_city.length != 0) {
        // 页面没有数据时请求数据
        [self requestData];
    }
    
    // 请求消息列表
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserMessage] data:@{@"userId": user._id} tag:WSInterfaceTypeUserMessage sucCallBack:^(id result) {
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                NSDictionary *data = [result objectForKey:@"data"];
                self.messages = [data objectForKey:@"messages"];
                NSString *isNews = [data stringForKey:@"isNews"];
                if ([isNews isEqualToString:@"Y"]) {
                    _navBarManagerView.navigationBarButSearchButView.rightLabel.hidden = NO;
                } else {
                    _navBarManagerView.navigationBarButSearchButView.rightLabel.hidden = YES;
                }
            }
        } failCallBack:^(id error) {
            
        } showMessage:NO];
    }
    
    if (headerView) {
        headerView.peasLabel.text = [NSString stringWithFormat:@"%@豆", [WSUserUtil getUserPeasNum]];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    //int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    //if (deoCodeFalg == 0) {
    self.city = [locationDic objectForKey:LOCATION_CITY];
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    _navBarManagerView.navigationBarButSearchButView.leftLabel.text = _city;
    DLog(@"定位：%@", _city);
    if (_city.length > 0) {
        // 幻灯片
        if (self.city.length > 0 && slideImageArray.count == 0) {
            [self requestGetAdsPhoto];
        }
        
        // 页面没有数据时请求数据
        [self requestData];
    }
  //  }
}

- (void)requestGetHomePageGoos
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_supermarketCollectionView endHeaderAndFooterRefresh];
        
    } else{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:_city forKey:@"cityName"];
        [params setValue:[NSNumber numberWithDouble:_latitude] forKey:@"lon"];
        [params setValue:[NSNumber numberWithDouble:_longtide] forKey:@"lat"];
        [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
        switch (shopType) {
            case ShopTypeSuperMarket:
            {
                [params setValue:[NSString stringWithFormat:@"%d", supermarketCurPage + 1] forKey:@"pages"];
                [params setValue:@"1" forKey:@"shopType"];
            }
                break;
            case ShopTypeBaihuoFuzhuang:
            {
                [params setValue:[NSString stringWithFormat:@"%d", baihuoCurPage + 1] forKey:@"pages"];
                [params setValue:@"2" forKey:@"shopType"];
            }
                break;
            default:
                break;
        }
        WSUser *user = [WSRunTime sharedWSRunTime].user;
        if (user) {
            [params setValue:user._id forKey:@"uid"];
        }
        [SVProgressHUD showWithStatus:@"加载中……"];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetHomePageGoods] data:params tag:WSInterfaceTypeGetHomePageGoods sucCallBack:^(id result) {
            [_supermarketCollectionView endHeaderAndFooterRefresh];
            [SVProgressHUD dismiss];
            float flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                switch (shopType) {
                    case ShopTypeSuperMarket:
                    {
                        //  刷新时清楚以前数据
                        if (supermarketCurPage == 0) {
                            [superMarketDataArray removeAllObjects];
                        }
                        supermarketCurPage ++;
                        NSArray *array = [[result objectForKey:@"data"] objectForKey:@"goodsList"];
                        NSInteger count = array.count;
                        for (int i = 0; i < count; i++) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setDictionary:[array objectAtIndex:i]];
                            [superMarketDataArray addObject:dic];
                        }
                       
                    }
                        break;
                    case ShopTypeBaihuoFuzhuang:
                    {
                        //  刷新时清楚以前数据
                        if (baihuoCurPage == 0) {
                            [baihuoFuzhuangDataArray removeAllObjects];
                        }
                        baihuoCurPage++;
                        NSArray *array = [[result objectForKey:@"data"] objectForKey:@"goodsList"];
                        NSInteger count = array.count;
                        for (int i = 0; i < count; i++) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setDictionary:[array objectAtIndex:i]];
                            [baihuoFuzhuangDataArray addObject:dic];
                        }
                    }
                        break;
                    default:
                        break;
                }
                [_supermarketCollectionView reloadData];
            }
        } failCallBack:^(id error) {
            [_supermarketCollectionView endHeaderAndFooterRefresh];
            [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
        }];
    }
}

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    self.city = _city.length > 0 ? self.city : @"";
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"1"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [slideImageArray removeAllObjects];
            NSArray *photoList = [[result objectForKey:@"data"] objectForKey:@"photoList"];
            [slideImageArray addObjectsFromArray:photoList];
            [_supermarketCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        
    }];
}

#pragma mark 页面没有数据时请求数据
- (void)requestData
{
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            if (superMarketDataArray.count == 0) {
                [self requestGetHomePageGoos];
            }
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            if (baihuoFuzhuangDataArray.count == 0) {
                [self requestGetHomePageGoos];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - NavigationBarButSearchButViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    DLog(@"navigationBarLeftButClick");
}

- (void)navigationBarRightButClick:(UIButton *)but
{
    [WSUserUtil actionAfterLogin:^{
        WSInfoListViewController *infoListVC = [[WSInfoListViewController alloc] init];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_messages];
        infoListVC.dataArray = tempArray;
        [self.navigationController pushViewController:infoListVC animated:YES];
    }];
}

- (BOOL)navigationBarSearchViewTextFieldShouldBeginEditing:(UITextField *)textField
{
//    WSSearchViewController *searchHistoryVC =[[WSSearchViewController alloc] init];
//    [self.navigationController pushViewController:searchHistoryVC animated:YES];
    WSSearchCommonViewController *searchCommon = [[WSSearchCommonViewController alloc] init];
    [self.navigationController pushViewController:searchCommon animated:YES];
    return NO;
}

- (void)navigationBarSearchViewTextFieldDidEndEditing:(UITextField *)textField
{
     DLog(@"navigationBarSearchViewTextFieldDidEndEditing:--%@", textField.text);
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
    NSArray *dataArray = nil;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            dataArray = superMarketDataArray;
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            dataArray = baihuoFuzhuangDataArray;
        }
            break;
        default:
            break;
    }
    NSInteger count = dataArray.count;
    if (count == 0) {
        return 0;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = nil;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            array = superMarketDataArray;
            
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            array = baihuoFuzhuangDataArray;
            
        }
            break;
        default:
            break;
    }
    NSInteger row = indexPath.row;
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.refreshPage = ^() {
        [self refreshPage];
    };
    NSInteger count = array.count;
    if (count == 0) {
        cell.hidden = YES;
    } else {
        cell.hidden = NO;
        cell.tag = row;
        cell.downloadImageFinish = ^() {
            CHTCollectionViewWaterfallLayout *layout =
            (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
            [layout invalidateLayout];
        };
        NSDictionary *dic = [array objectAtIndex:row];
        [cell setModel:dic];
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
     CGFloat width = collectionView.bounds.size.width - 3 * COLLECTION_VIEW_GAP;
    NSArray *array = nil;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            array = superMarketDataArray;
            
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            array = baihuoFuzhuangDataArray;
            
        }
            break;
        default:
            break;
    }
    NSDictionary *dic = [array objectAtIndex:row];
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
    
  
    if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL);
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HomeHeaderCollectionReusableView" forIndexPath:indexPath];
        [headerView.storeSignInBut addTarget:self action:@selector(shopSignInAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.scanProductBut addTarget:self action:@selector(scanProductAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.inviteFriendBut addTarget:self action:@selector(invateFriendAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger imageCount = slideImageArray.count;
        if (imageCount != 0) {
            ACImageScrollView *imageScrollView = headerView.imageScrollManagerView.acImageScrollView;
            NSMutableArray *imageDataArray = [NSMutableArray array];
            for (int i = 0; i < imageCount; i++) {
                NSDictionary *dic = [slideImageArray objectAtIndex:i];
                NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"pic_path"]];
                [imageDataArray addObject:imageURL];
            }
            
            [imageScrollView setImageData:imageDataArray];
            __weak ACImageScrollView *weekImageScrollView = imageScrollView;
            imageScrollView.downloadImageFinish = ^(NSInteger index, UIImage *image) {
                float height = 0;
                CGSize imageSize = image.size;
                height = weekImageScrollView.bounds.size.width * imageSize.height / imageSize.width;
                height =  height + HOMEHEADERCOLLECTIONREUSABLEVIEW_HEIGHT - HOMEHEADER_COLLECTION_REUSABLE_VIEW_IMAGESCROLLVIEW_HEIGHT;
                CHTCollectionViewWaterfallLayout *layout =
                (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
                layout.headerHeight = height;
                [layout invalidateLayout];
                //[weekImageScrollView layoutIfNeeded];
                [weekImageScrollView updateConstraintsIfNeeded];
                [weekImageScrollView updateConstraints];
            };
            imageScrollView.callback = ^(int index) {
                DLog(@"广告：%d", index);
                NSDictionary *dic = [slideImageArray objectAtIndex:index];
                WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
                advertisementVC.url = [dic objectForKey:@"third_link"];
                [self.navigationController pushViewController:advertisementVC animated:YES];
            };
        }
        NSString *beanNum = [WSUserUtil getUserPeasNum];
        headerView.peasLabel.text = [NSString stringWithFormat:@"%@豆", beanNum];
        headerView.tag = indexPath.row;
        [headerView.segmentedControl addTarget:self action:@selector(typeSegmentControlAction:)forControlEvents:UIControlEventValueChanged];
        return headerView;
    }
        return nil;
       
    } else {
        return nil;
    }
}

#pragma mark -
- (void)refreshPage
{
    if (superMarketDataArray.count != 0) {
        supermarketCurPage = 0;
        [self requestGetHomePageGoos];
    }
    if (baihuoFuzhuangDataArray.count != 0) {
        [self requestGetHomePageGoos];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSArray *dataArray = nil;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            dataArray = superMarketDataArray;
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            dataArray = baihuoFuzhuangDataArray;
        }
            break;
        default:
            break;
    }
    NSInteger row = indexPath.row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    NSString *goodsId = [dic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = [dic stringForKey:@"shopId"];
    [self.navigationController pushViewController:productDetailVC animated:YES];


}

#pragma mark - SlideSwitchViewDelegate
- (void)slideSwitchViewDidSelectedIndex:(int)index
{
    DLog(@"点击了index:%d", index);
}

#pragma mark - 到店签到
- (void)shopSignInAction:(id)sender
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

#pragma mark 扫描产品
- (void)scanProductAction:(id)sender
{
    // 1. 在店内跳到 WSStoreDetailViewController
    // 2. 不在店内跳到 WSScanInStoreViewController
    [[WSRunTime sharedWSRunTime] findIbeaconWithCallback:^(NSArray *beaconsArray) {
        CLBeacon *beacon = nil;
        if (beaconsArray.count > 0) {
            beacon = [beaconsArray objectAtIndex:0];
        }
        [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
            BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
            // 在店内
            if (isInStore) {
                [WSUserUtil actionAfterLogin:^{
                    NSDictionary *dic = [result objectForKey:IS_IN_SHOP_DATA];
                    NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
                    NSString *shopId = [dic stringForKey:@"shopId"];
                    NSString *shopName = [shop objectForKey:@"shopName"];
                    WSScanInStoreViewController *scanInStoreVC = [[WSScanInStoreViewController alloc] init];
                    scanInStoreVC.shopName = shopName;
                    scanInStoreVC.shopid = shopId;
                    [self.navigationController pushViewController:scanInStoreVC animated:YES];
                }];
                
                // 不在店内
            } else {
                WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
                [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
            }
        }];
        
    }];
}

#pragma mark 邀请好友
- (void)invateFriendAction:(id)sender
{
    [WSUserUtil actionAfterLogin:^{
        WSInviateFriendViewController *inviateFriendVC = [[WSInviateFriendViewController alloc] init];
        [self.navigationController pushViewController:inviateFriendVC animated:YES];
    }];
}

- (void)toScanNoInStore
{
    WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
}

#pragma mark - 超市、百货服装切换
- (void)typeSegmentControlAction:(UISegmentedControl *)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    
    shopType = index;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
//            _supermarketCollectionView.hidden = NO;
//            _baihuofuzhuangCollectView.hidden = YES;
            if (superMarketDataArray.count == 0) {
                [self requestGetHomePageGoos];
            }
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
//            _supermarketCollectionView.hidden = YES;
//            _baihuofuzhuangCollectView.hidden = NO;
            if (baihuoFuzhuangDataArray.count == 0) {
                [self requestGetHomePageGoos];
            }
        }
            break;
        default:
            break;
    }
    [_supermarketCollectionView reloadData];
}

@end
