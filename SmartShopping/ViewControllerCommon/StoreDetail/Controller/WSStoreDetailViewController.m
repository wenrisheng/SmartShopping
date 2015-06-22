//
//  WSStoreDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSStoreDetailViewController.h"
#import "WSStoreDetailCollectionViewCell.h"
#import "WSHomeViewController.h"
#import "WSStoreDetailCollectionReusableView.h"
#import "WSScanProductViewController.h"
#import "WSScanProductViewController.h"
#import "WSProductDetailViewController.h"
#import "WSScanAfterViewController.h"
#import "WSAdvertisementDetailViewController.h"

@interface WSStoreDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
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

@property (strong, nonatomic) NSMutableDictionary *goodsscanlist;


@end

@implementation WSStoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    NSString *commitName = @"而而而而而而而";
    NSString *shopName = [_shop objectForKey:@"shopName"];
    if (shopName.length == 0) {
        shopName = [_shop objectForKey:@"shopname"];
    }
//    if (shopName.length > commitName.length) {
//        shopName = [NSString stringWithFormat:@"%@…", [shopName substringToIndex:commitName.length]];
//    }
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = shopName;
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    currentPage = 0;
    toEndPage = NO;
    canSign = NO;
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSStoreDetailCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSStoreDetailCollectionReusableView"];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = COLLECTION_VIEW_GAP;
    layout.minimumInteritemSpacing = COLLECTION_VIEW_GAP;
    _collectionView.collectionViewLayout = layout;

    
    [_collectionView addLegendHeaderWithRefreshingBlock:^{
        currentPage = 0;
        [self requestInShopGoodsScanList];
    }];
    [_collectionView addLegendFooterWithRefreshingBlock:^{
        [self requestInShopGoodsScanList];
    }];

    [self requestGetAdsPhoto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    if (_city && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    currentPage = 0;
    [dataArray removeAllObjects];
    [_collectionView reloadData];
    [self requestInShopGoodsScanList];
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
        [SVProgressHUD showErrorWithStatus:@"定位失败" duration:TOAST_VIEW_TIME];
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
    NSString *shopId = [_shop stringForKey:@"shopid"];
    if (shopId.length == 0) {
        shopId = [_shop stringForKey:@"shopId"];
    }
    [params setValue:shopId forKey:@"shopid"];
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
            if (!_goodsscanlist) {
                self.goodsscanlist = [[NSMutableDictionary alloc] init];
            }
            [_goodsscanlist setValuesForKeysWithDictionary:[[result objectForKey:@"data"] objectForKey:@"goodsscanlist"]];
            NSArray *goodslist = [_goodsscanlist objectForKey:@"goodslist"];
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
        __weak ACImageScrollView *weekImageScrollView = imageScrollView;
        imageScrollView.downloadImageFinish = ^(NSInteger index, UIImage *image) {
            float height = 0;
            CGSize imageSize = image.size;
            height = weekImageScrollView.bounds.size.width * imageSize.height / imageSize.width;
            height =  height + WS_STORE_DETAIL_COLLECTION_RESUSABLE_VIEW_BOTTOMVIEW_HEIGHT;
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
        
        NSInteger imageCount = slideImageArray.count;
        NSMutableArray *imageDataArray = [NSMutableArray array];
        for (int i = 0; i < imageCount; i++) {
            NSDictionary *dic = [slideImageArray objectAtIndex:i];
            NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"pic_path"]];
            [imageDataArray addObject:imageURL];
        }

        [imageScrollView setImageData:imageDataArray];
        if (_goodsscanlist) {
            NSString *userIsSign = [_goodsscanlist stringForKey:@"userIsSign"];
            NSString *signImage = nil;
            NSString *scanImage = nil;
            // 可以签到
            if ([userIsSign isEqualToString:@"N"]) {
                signImage = @"gainpeas_icon-06";
                
                canSign = YES;
            // 不可以签到
            } else {
                signImage = @"gainpeas_icon-04";
                canSign = NO;
            }
            BOOL hasScanGood = NO;
            for (NSDictionary *dic in dataArray) {
                NSString *isScan = [dic stringForKey:@"isScan"];
                if ([isScan isEqualToString:@"Y"]) {
                    hasScanGood = YES;
                    break;
                }
            }
            if (hasScanGood) {
                scanImage = @"gainpeas_icon-02";
            } else {
                scanImage = @"gainpeas_icon-05";
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
        NSString *shopid = [_shop stringForKey:@"shopid"];
        productDetailVC.shopId = shopid;
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
    NSDictionary *dic = [dataArray objectAtIndex:but.tag];
    NSString *isScan = [dic stringForKey:@"isScan"];
   
    if ([isScan isEqualToString:@"Y"]) {
        // 1. 不在店内则提示不在店内
        // 2. 在店内则跳到 WSScanProductViewController
        [[WSRunTime sharedWSRunTime] findIbeaconWithCallback:^(NSArray *beaconsArray) {
            if (beaconsArray.count > 0) {
                [WSProjUtil isInStoreWithIBeacon:[beaconsArray objectAtIndex:0] callback:^(id result) {
                    BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
                    // 在店内
                    if (isInStore) {
                        [WSUserUtil actionAfterLogin:^{
                            
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
                [SVProgressHUD showErrorWithStatus:@"亲，没发现iBeacon哦！" duration:TOAST_VIEW_TIME];
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"亲，该商品已经扫描过了哦！" duration:TOAST_VIEW_TIME];
    }
}


@end
