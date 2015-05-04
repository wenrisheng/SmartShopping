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


@interface WSPromotionCouponViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NavigationBarButSearchButViewDelegate, HomeCollectionViewCellDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    NSMutableArray *inStoreDataArray;
    NSMutableArray *outStoreDataArray;
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geocodesearch;
    BOOL isInStore;
    
    WSDoubleTableView *doubleTableView;
    NSMutableArray *dataArrayF;
    NSMutableArray *dataArrayS;
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    inStoreDataArray = [[NSMutableArray alloc] init];
    outStoreDataArray = [[NSMutableArray alloc] init];

    // 启动百度地区定位
    [self initBMK];
    
    // 初始化视图
    [self initView];
    
    [self addTestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //启动LocationService
    [_locService startUserLocationService];
    _locService.delegate = self;
    _geocodesearch.delegate = self;
    if (isInStore) {
        [self toInStoreStatus:@"沃尔玛"];
    } else {
        [self toOutStoreStatus];
    }
}

#pragma mark - 初始化百度地图
- (void)initBMK
{
    // 地理位置反编码
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:LOCATION_DISTANCE_FILTER];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
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
    _outStoreTabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _outStoreTabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-click";
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
    [but setBackgroundImage:[UIImage imageNamed:@"05"] forState:UIControlStateNormal];
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
        // 模拟延迟加载数据，因此2秒后才调用）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_contentCollectionView headerEndRefreshing];
        });
        
        DLog(@"下拉刷新完成！");
    }];
    [_contentCollectionView addFooterWithCallback:^{
        // 模拟延迟加载数据，因此2秒后才调用）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_contentCollectionView footerEndRefreshing];
        });
        
        DLog(@"下拉刷新完成！");
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

#pragma mark - 在店内搜索按钮事件
- (void)inStoreSearchButAction:(UIButton *)but
{
    WSFilterBrandViewController *filterBrandVC = [[WSFilterBrandViewController alloc] init];
    [self.navigationController pushViewController:filterBrandVC animated:YES];
//    if (isInStore) {
//        [self toOutStoreStatus];
//    } else {
//        [self toInStoreStatus:@"沃尔玛"];
//    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    DLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        DLog(@"反geo检索发送成功");
    }
    else
    {
        DLog(@"反地理编码失败");
    }
    
   // [self toInStoreStatus:@"沃尔玛"];
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [_locService stopUserLocationService];
    DLog(@"定位失败！！！");
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == 0) {
        BMKAddressComponent *addressCom = result.addressDetail;
        _navigationBarManagerView.navigationBarButSearchButView.leftLabel.text = addressCom.city;
        DLog(@"%@%@%@%@%@", addressCom.province, addressCom.city, addressCom.district, addressCom.streetName, addressCom.streetNumber);
    } else {
        DLog(@"反地理编码失败");
    }
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
    _inStoreTabSlideMnagerView.tabSlideGapTextView.selectedImage = @"arrow-click";
    NSArray *titleArray = @[@"附近", storeName, @"所有"];
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
   // _navigationBarManagerView.navigationBarButSearchButView.rightView.hidden = YES;
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
            // 所有
        case 1:
        {
            [self clickAllTab];
        }
            break;
        default:
            break;
    }
}

#pragma mark 点击了附近tab
- (void)clickNearTab
{
    WSDoubleTableView *doubleTable= [self getDoubleTableView];
    doubleTable.hidden = NO;
    doubleTable.cellFSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellFUnSelectColor = [UIColor colorWithRed:0.929 green:0.937 blue:0.941 alpha:1.000];
    doubleTable.cellSSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.cellSUnSelectColor = [UIColor colorWithRed:0.996 green:1.000 blue:1.000 alpha:1.000];
    doubleTable.isLeftToRight = YES;
    doubleTable.dataArrayF = dataArrayF;
    doubleTable.dataArrayS = dataArrayS;
    [doubleTable.tableF reloadData];
    [doubleTable.tableS reloadData];
    doubleTable.tableFCallBack = ^(NSInteger index) {
        
    };
    doubleTable.tableSCallBack = ^(NSInteger index) {
        doubleTable.hidden = YES;
    };
}

#pragma mark 点击了所有tab
- (void)clickAllTab
{
    
}

#pragma mark - 在商店内点击tab
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
        }
            break;
            // 所有
        case 2:
        {
            [self clickAllTab];
        }
            break;
        default:
            break;
    }
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
    if (isInStore) {
        return inStoreDataArray.count;
    } else {
        return outStoreDataArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInStore) { // 在店内
        HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
        cell.validDateLabel.text = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
        cell.delegate = self;
        [cell.bigImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [cell.smallImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        return cell;
    } else { // 不在店内
        WSPromotionCouponOutStoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSPromotionCouponOutStoreCollectionViewCell" forIndexPath:indexPath];
        [cell.loginImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [cell.rightImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
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
        return view;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - HomeCollectionViewCellDelegate
//收藏
- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"收藏：%d", (int)tag);
}

//分享
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"分享：%d", (int)tag);
}

#pragma mark - 在店内 到店签到按钮事件
- (void)signupButAction:(UIButton *)but
{
    
}

@end
