//
//  WSStoreDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSScanInStoreViewController.h"
#import "WSStoreDetailCollectionViewCell.h"
#import "WSHomeViewController.h"
#import "WSStoreDetailCollectionReusableView.h"
#import "WSScanProductViewController.h"
#import "WSScanProductViewController.h"
#import "WSProductDetailViewController.h"
#import "WSScanAfterViewController.h"
#import "WSAdvertisementDetailViewController.h"

@interface WSScanInStoreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    WSStoreDetailCollectionReusableView *reusableView;
    NSMutableArray *dataArray;
    NSMutableArray *slideImageArray;
    int currentPage;
    BOOL toEndPage;
    BOOL canSign;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (strong, nonatomic) NSDictionary *shop;

@end

@implementation WSScanInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _navigationBarManagerView.navigationBarButLabelView.label.text = @"";
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    currentPage = 0;
    toEndPage = NO;
    canSign = NO;
    
//    NSString *commitName = @"而而而而而而而";
//    if (_shopName.length > commitName.length) {
//        _shopName = [NSString stringWithFormat:@"%@…", [_shopName substringToIndex:commitName.length]];
//    }
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = _shopName;
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSStoreDetailCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSStoreDetailCollectionReusableView"];
    
    
    [_collectionView addLegendHeaderWithRefreshingBlock:^{
        currentPage = 0;
        [self requestInShopGoodsScanList];
    }];
    [_collectionView addLegendFooterWithRefreshingBlock:^{
        [self requestInShopGoodsScanList];
    }];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = COLLECTION_VIEW_GAP;
    layout.minimumInteritemSpacing = COLLECTION_VIEW_GAP;
    _collectionView.collectionViewLayout = layout;

    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    [self requestGetAdsPhoto];
    
    // 请求店内扫描产品
    [self requestInShopGoodsScanList];

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
    //    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    //    if (deoCodeFalg == 0) {
    DLog(@"city:%@", _city);
    NSString *city = [locationDic objectForKey:LOCATION_CITY];
    self.city = city;
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    if (slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
}

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"5"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
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

- (void)requestInShopGoodsScanList
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_shopid forKey:@"shopid"];
    [params setValue:[NSString stringWithFormat:@"%d", currentPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeInShopGoodsScanList] data:params tag:WSInterfaceTypeInShopGoodsScanList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        [_collectionView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            if (currentPage == 0) {
                [dataArray removeAllObjects];
            }
            currentPage ++;
            NSArray *goodslist = [[[result objectForKey:@"data"] objectForKey:@"goodsscanlist"] objectForKey:@"goodslist"];
            NSInteger count = goodslist.count;
            for (int i = 0; i < count; i++) {
                NSDictionary *dic = [goodslist objectAtIndex:i];
                NSMutableDictionary *converDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dataArray addObject:converDic];
            }
            [_collectionView reloadData];
        }
    } failCallBack:^(id error) {
        [_collectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

- (void)requestStoreDetail
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_collectionView endHeaderAndFooterRefresh];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:_shopid forKey:@"shopid"];
    [params setValue:@"" forKey:@"categoryId"];
    [params setValue:@"" forKey:@"brandIds"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCheckMoreGoodsList] data:params tag:WSInterfaceTypeCheckMoreGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        [_collectionView endHeaderAndFooterRefresh];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            self.shop = [[result objectForKey:@"data"] objectForKey:@"shop"];
            NSString *shopName = [_shop objectForKey:@"shopName"];
            _navigationBarManagerView.navigationBarButLabelView.label.text = shopName;
        }
    } failCallBack:^(id error) {
        [_collectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSStoreDetailCollectionViewCell *cell = (WSStoreDetailCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSStoreDetailCollectionViewCell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    cell.downloadImageFinish = ^() {
        CHTCollectionViewWaterfallLayout *layout =
        (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
        [layout invalidateLayout];
    };
    [cell setModel:dic];


    cell.scanBut.tag = row;
    [cell.scanBut addTarget:self action:@selector(scanButActioin:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = collectionView.bounds.size.width - 3 * COLLECTION_VIEW_GAP;
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
        return CGSizeMake(width, WSSTOREDETAILCOLLECTIONVIEWCELL_HEIGHT - WS_STORE_DETAIL_COLLECTION_VIEW_CELL_IMAGE_HEIGHT + height);
    }

    
    if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, WSSTOREDETAILCOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, WSSTOREDETAILCOLLECTIONVIEWCELL_HEIGHT_SMAIL);
    }
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return -20;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return CELLECTIONVIEW_CELL_SPACE;
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET);
//}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(collectionView.bounds.size.width, WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT);
    } else {
        return CGSizeZero;
    }
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSStoreDetailCollectionReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = reusableView.imageScrollManagerView.acImageScrollView;
        NSInteger imageCount = slideImageArray.count;
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
            DLog(@"IMAGE height:%.1f", height);
            height =  height + WS_STORE_DETAIL_COLLECTION_RESUSABLE_VIEW_BOTTOMVIEW_HEIGHT + 30;
            CHTCollectionViewWaterfallLayout *layout =
            (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
            layout.headerHeight = height;
            [layout invalidateLayout];

        };
        imageScrollView.callback = ^(int index) {
            DLog(@"广告：%d", index);
            NSDictionary *dic = [slideImageArray objectAtIndex:index];
            WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
            advertisementVC.dic = dic;
            [self.navigationController pushViewController:advertisementVC animated:YES];
        };
        
        if (_shop) {
            NSString *isSign = [_shop stringForKey:@"isSign"];
            NSString *signImage = nil;
            NSString *scanImage = nil;
            // 可以签到
            if ([isSign isEqualToString:@"1"]) {
                signImage = @"gainpeas_icon-06";
                scanImage = @"gainpeas_";
                canSign = YES;
            // 不可以签到
            } else {
                signImage = @"gainpeas_icon-04";
                scanImage = @"icon-05";
                canSign = NO;
            }
            reusableView.signupImageView.image = [UIImage imageNamed:signImage];
            reusableView.scanImageView.image = [UIImage imageNamed:scanImage];
        }
        return reusableView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (dataArray.count != 0) {
        NSMutableDictionary *dic = [dataArray objectAtIndex:row];
        NSString *goodsId = [dic stringForKey:@"goodsId"];
        WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
        productDetailVC.goodsId = goodsId;
        productDetailVC.shopId = _shopid;
        productDetailVC.CollectCallBack = ^(NSDictionary *resultDic) {
            NSString *isCollect = [resultDic stringForKey:@"isCollect"];
            [dic setValue:isCollect forKey:@"isCollect"];
            [_collectionView reloadData];
        };
        [self.navigationController pushViewController:productDetailVC animated:YES];
    }
}

#pragma mark - 扫描按钮事件
- (void)scanButActioin:(UIButton *)but
{
    // 1. 不在店内则提示不在店内
    // 2. 在店内则跳到 WSScanProductViewController
    [[WSRunTime sharedWSRunTime] findIbeaconWithCallback:^(NSArray *beaconsArray) {
        if (beaconsArray.count > 0) {
            [WSProjUtil isInStoreWithIBeacon:[beaconsArray objectAtIndex:0] callback:^(id result) {
                BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
                // 在店内
                if (isInStore) {
                    [WSUserUtil actionAfterLogin:^{
                        NSDictionary *dic = [dataArray objectAtIndex:but.tag];
                        WSScanProductViewController *scanProductVC = [[WSScanProductViewController alloc] init];
                        NSString *shopid = [_shop stringForKey:@"shopid"];
                        NSString *goodsId = [dic stringForKey:@"goodsId"];
                        scanProductVC.scanSucCallBack = ^(NSString *beanNumber) {
                            WSScanAfterViewController *scanAfterVC = [[WSScanAfterViewController alloc] init];
                            scanAfterVC.goodsId = goodsId;
                            scanAfterVC.shopid = shopid;
                            scanAfterVC.beanNum = beanNumber;
                            [self.navigationController pushViewController:scanAfterVC animated:YES];
                        };
                        scanProductVC.shopid = shopid;
                        scanProductVC.goodsId = goodsId;
                        [self.navigationController pushViewController:scanProductVC animated:YES];
                    }];
                    
                    // 不在店内
                } else {
                    [SVProgressHUD showErrorWithStatus:@"亲，您当前不在店内！" duration:TOAST_VIEW_TIME];
                }
                
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"亲，没有扫描到iBeacon哦！" duration:TOAST_VIEW_TIME];
        }
    }];
}


@end
