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
#import "WSSearchHistoryViewController.h"
#import "CollectSucView.h"

typedef NS_ENUM(NSInteger, ShopType)
{
    ShopTypeSuperMarket = 0,
    ShopTypeBaihuoFuzhuang
};

@interface WSHomeViewController () <NavigationBarButSearchButViewDelegate, WSSlideSwitchViewDelegate, HomeCollectionViewCellDelegate, BMKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *superMarketDataArray;
    NSMutableArray *baihuoFuzhuangDataArray;
    NSMutableArray *slideImageArray;
    HomeHeaderCollectionReusableView *headerView;
    ShopType shopType;
    int supermarketCurPage;
    BOOL supermarketToEndPage;
    int baihuoCurPage;
    BOOL baihuoToEndPage;
}

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation WSHomeViewController

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
        // 模拟延迟加载数据，因此2秒后才调用）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_collectionView footerEndRefreshing];
        });
        
        DLog(@"下拉刷新完成！");
    }];
    
   
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
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    // 没有幻灯片时请求幻灯片数据
    if (_city.length != 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    if (_city.length != 0) {
        // 页面没有数据时请求数据
        [self requestData];
    }
    
    // 请求消息列表
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUserMessage] data:@{@"userId": user._id} tag:WSInterfaceTypeUserMessage sucCallBack:^(id result) {
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                self.messages = [[result objectForKey:@"data"] objectForKey:@"messages"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead CONTAINS %@", @"2"];
                NSArray *temp = [_messages filteredArrayUsingPredicate:predicate];
                NSInteger count= temp.count;
                if (count == 0) {
                    _navBarManagerView.navigationBarButSearchButView.rightLabel.hidden = YES;
                } else {
                    _navBarManagerView.navigationBarButSearchButView.rightLabel.text = [NSString stringWithFormat:@"%d", (int)count];
                    _navBarManagerView.navigationBarButSearchButView.rightLabel.hidden = NO;
                }
            }
        } failCallBack:^(id error) {
            
        }];
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
    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    if (deoCodeFalg == 0) {
        self.city = [locationDic objectForKey:LOCATION_CITY];
        self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
        self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
        _navBarManagerView.navigationBarButSearchButView.leftLabel.text = _city;
        DLog(@"定位：%@", _city);
        
        // 幻灯片
        if (slideImageArray.count == 0) {
            [self requestGetAdsPhoto];
        }
        
        // 页面没有数据时请求数据
        [self requestData];
    }
}

- (void)requestGetHomePageGoos
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:_city forKey:@"cityName"];
    [params setValue:[NSNumber numberWithDouble:_longtide] forKey:@"lon"];
    [params setValue:[NSNumber numberWithDouble:_latitude] forKey:@"lat"];
    [params setValue:PAGE_SIZE forKey:@"pageSize"];
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
                    NSArray *array = [[result objectForKey:@"data"] objectForKey:@"goodsList"];
                    [superMarketDataArray addObjectsFromArray:array];
                }
                    break;
                case ShopTypeBaihuoFuzhuang:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
    } failCallBack:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败！" duration:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"1"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [slideImageArray removeAllObjects];
            NSArray *photoList = [[result objectForKey:@"data"] objectForKey:@"photoList"];
            [slideImageArray addObjectsFromArray:photoList];
            [_collectionView reloadData];
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
    WSSearchHistoryViewController *searchHistoryVC =[[WSSearchHistoryViewController alloc] init];
    [self.navigationController pushViewController:searchHistoryVC animated:YES];
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
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            if (superMarketDataArray.count == 0) {
               // return 1;
            }
            return superMarketDataArray.count;
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            if (baihuoFuzhuangDataArray.count == 0) {
             //   return 1;
            }
            return baihuoFuzhuangDataArray.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = nil;
    switch (shopType) {
        case ShopTypeSuperMarket:
        {
            if (superMarketDataArray.count == 0) {
//                return cell;
            }
            array = superMarketDataArray;
            
        }
            break;
        case ShopTypeBaihuoFuzhuang:
        {
            if (baihuoFuzhuangDataArray.count == 0) {
                
            }
            array = baihuoFuzhuangDataArray;
            
        }
            break;
        default:
            break;
    }
    NSInteger row = indexPath.row;
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.tag = row;
    cell.delegate = self;
    NSDictionary *dic = [array objectAtIndex:row];
    [cell setModel:dic];
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
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = headerView.imageScrollManagerView.acImageScrollView;
        NSInteger imageCount = slideImageArray.count;
        NSMutableArray *imageDataArray = [NSMutableArray array];
        for (int i = 0; i < imageCount; i++) {
            NSDictionary *dic = [slideImageArray objectAtIndex:i];
            NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"pic_path"]];
            [imageDataArray addObject:imageURL];
        }
        [imageScrollView setImageData:imageDataArray];
        imageScrollView.callback = ^(int index) {
            DLog(@"广告：%d", index);
            NSDictionary *dic = [slideImageArray objectAtIndex:index];
            WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
            advertisementVC.url = [dic objectForKey:@"third_link"];
            [self.navigationController pushViewController:advertisementVC animated:YES];
        };
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
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    productDetailVC.hasScan = YES;
    productDetailVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:productDetailVC animated:YES];
}


#pragma mark - HomeCollectionViewCellDelegate
#pragma mark 收藏
- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSInteger tag = cell.tag;
        NSDictionary *dic = [superMarketDataArray objectAtIndex:tag];
        NSDictionary *param = @{@"uid": user._id, @"goodsid": [dic objectForKey:@"goodsid"]};
        [SVProgressHUD show];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [CollectSucView showCollectSucView];
            }
        } failCallBack:^(id error) {
            
        }];
    } else {
        [WSUserUtil actionAfterLogin:^{
            
        }];
    }
}

#pragma mark 分享
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"分享：%d", (int)tag);
}

#pragma mark 距离按钮
- (void)homeCollectionViewCellDidClickDistanceBut:(HomeCollectionViewCell *)cell
{
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    [self.navigationController pushViewController:locationDetailVC animated:YES];
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
    
    [self toNoInStoreVC];
    DLog(@"到店签到");
}

#pragma mark 扫描产品
- (void)scanProductAction:(id)sender
{
    // 1. 在店内跳到 WSStoreDetailViewController
    // 2. 不在店内跳到 WSScanNoInStoreViewController
    [self toScanNoInStore];
     DLog(@"扫描产品");
}

#pragma mark 邀请好友
- (void)invateFriendAction:(id)sender
{
    WSInviateFriendViewController *inviateFriendVC = [[WSInviateFriendViewController alloc] init];
    [self.navigationController pushViewController:inviateFriendVC animated:YES];
    DLog(@"邀请好友");
}

#pragma mark - 到店签到 不在店内
- (void)toNoInStoreVC
{
    WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:noInstoreVC animated:YES];
}

#pragma mark 在店内没签到
- (void)toInStoreNoSign
{
    WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
    [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
    
}

#pragma mark 在店内已签到
- (void)toStoreDetail
{
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

- (void)toScanNoInStore
{
    WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
}

#pragma mark 
- (void)typeSegmentControlAction:(UISegmentedControl *)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    shopType = index;
    if (_city.length != 0) {
        [self requestData];
    }
    [_collectionView reloadData];
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"regionDidChangeAnimated");
}

@end
