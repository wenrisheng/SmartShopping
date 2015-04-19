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

#define CELLECTIONVIEW_CELL_SPACE       10   //cell与cell的间距
#define CELLECTIONVIEW_CONTENT_INSET    10   //CollectionView 左右下三边的内容边距

@interface WSHomeViewController () <NavigationBarButSearchButViewDelegate, WSSlideSwitchViewDelegate, HomeCollectionViewCellDelegate, BMKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    NSMutableArray *collectionViewDataArray;
    NSMutableArray *slideImageArray;
    
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geocodesearch;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation WSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    //[_navBarManagerView.navigationBarButSearchButView.rightBut setBackgroundImage:[UIImage imageNamed:@"navigationBarButSearchButView"] forState:UIControlStateNormal];
    _navBarManagerView.navigationBarButSearchButView.delegate = self;
    _navBarManagerView.navigationBarButSearchButView.leftLabel.text = nil;
    collectionViewDataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    
    // 启动百度地区定位
    [self initBMK];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView"];
    

    [_collectionView addHeaderWithCallback:^{
    // 模拟延迟加载数据，因此2秒后才调用）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 结束刷新
        [_collectionView headerEndRefreshing];
    });

    DLog(@"下拉刷新完成！");
}];
    [_collectionView addFooterWithCallback:^{
        DLog(@"上拉刷新完成");
    }];
    
    [self addTestData];
}

- (void)initBMK
{
    // 地理位置反编码
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //启动LocationService
    [_locService startUserLocationService];
    _locService.delegate = self;
    _geocodesearch.delegate = self;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止LocationService
    //[_locService stopUserLocationService];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

#pragma mark - 测试数据
- (void)addTestData
{
    [collectionViewDataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
   // [slideImageArray addObjectsFromArray: @[[UIImage imageNamed:@"slideswitch"], [UIImage imageNamed:@"normal"], [UIImage imageNamed:@"selected"], [UIImage imageNamed:@"normal"]]];
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
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"定位失败！！！");
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
   
    if (error == 0) {
        BMKAddressComponent *addressCom = result.addressDetail;
        _navBarManagerView.navigationBarButSearchButView.leftLabel.text = addressCom.city;
        DLog(@"%@%@%@%@%@", addressCom.province, addressCom.city, addressCom.district, addressCom.streetName, addressCom.streetNumber);
    } else {
        DLog(@"反地理编码失败");
    }
}

#pragma mark - NavigationBarButSearchButViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    DLog(@"navigationBarLeftButClick");
}

- (void)navigationBarRightButClick:(UIButton *)but
{
    WSInfoListViewController *infoListVC = [[WSInfoListViewController alloc] init];
    [self.navigationController pushViewController:infoListVC animated:YES];
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
    return collectionViewDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.validDateLabel.text = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
 if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL);
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
    if (section == 0) {
         return CGSizeMake(collectionView.bounds.size.width, HOMEHEADERCOLLECTIONREUSABLEVIEW);
    } else {
        return CGSizeZero;
    }
   
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HomeHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView" forIndexPath:indexPath];
        WSSlideSwitchView *slideSwitchView = headerView.slideSwitchManagerView.slideSwitchView;
        [slideSwitchView setImageViewArray:slideImageArray];
        slideSwitchView.delegate = self;
        [headerView.storeSignInBut addTarget:self action:@selector(shopSignInAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.scanProductBut addTarget:self action:@selector(scanProductAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.inviteFriendBut addTarget:self action:@selector(invateFriendAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.segmentedControl addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchUpInside];
        headerView.tag = indexPath.row;
        return headerView;
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

#pragma mark - SlideSwitchViewDelegate
- (void)slideSwitchViewDidSelectedIndex:(int)index
{
    DLog(@"点击了index:%d", index);
}

#pragma mark - 到店签到
- (void)shopSignInAction:(id)sender
{
    DLog(@"到店签到");
}

#pragma mark 扫描产品
- (void)scanProductAction:(id)sender
{
     DLog(@"扫描产品");
}

#pragma mark 邀请好友
- (void)invateFriendAction:(id)sender
{
    DLog(@"邀请好友");
}

#pragma mark 
- (void)typeSegmentControlAction:(UISegmentedControl *)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    switch (index) {
        //超市
        case 0:
        {
            DLog(@"超市");
        }
            break;
        //百货服装
        case 1:
        {
          DLog(@"百货服装");
        }
            break;
        default:
            break;
    }
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"regionDidChangeAnimated");
}

@end
