//
//  WSScanNoInStoreViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSScanNoInStoreViewController.h"
#import "WSScanNoInStoreCollectionViewCell.h"
#import "WSScanNoInStoreReusableView.h"
#import "WSHomeViewController.h"
#import "WSAdvertisementDetailViewController.h"
#import "WSProductDetailViewController.h"
#import "WSStoreDetailViewController.h"

#import "WSDoubleTableView.h"

@interface WSScanNoInStoreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    WSScanNoInStoreReusableView *headerView;
    NSMutableArray *dataArray;
    NSMutableArray *slideImageArray;
    int curPage;
    
    WSDoubleTableView *doubleTableView;
    
    NSMutableArray *storeFDataArray;// 商店一级数据
    NSMutableDictionary *storeSDic;// 商店二级数据
    int storeFIndex; // 当前选中的一级商店
    int storeSIndex; // 当前选中的二级商店
}

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (strong, nonatomic) NSString *shopTypeId; // 商店类型id
@property (strong, nonatomic) NSString *retailId; //零售商id
@property (weak, nonatomic) IBOutlet UILabel *topRightLabel;

@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *allStoreBut;

- (IBAction)backButAction:(id)sender;
- (IBAction)allStoreButAction:(id)sender;


@end

@implementation WSScanNoInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    storeFDataArray = [[NSMutableArray alloc] init];
    storeSDic = [[NSMutableDictionary alloc] init];
    
    curPage = 0;
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    [_tipView setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:_tipView.bounds.size.height / 2];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSScanNoInStoreReusableView"];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = WSSCANNOINSTOREREUSABLEVIEW_HEIGHT;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = COLLECTION_VIEW_GAP;
    layout.minimumInteritemSpacing = COLLECTION_VIEW_GAP;
    _collectionView.collectionViewLayout = layout;
    
    [_collectionView addLegendHeaderWithRefreshingBlock:^{
        curPage = 0;
        [self requestGoodsScanList];
    }];
    [_collectionView addLegendFooterWithRefreshingBlock:^{
        [self requestGoodsScanList];
    }];
    [self requestGoodsScanList];

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
    if (_city.length != 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (doubleTableView && !doubleTableView.hidden) {
        doubleTableView.hidden = YES;
    }
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
    if (_city.length > 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    if (dataArray.count == 0) {
        [self requestGoodsScanList];
    }
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
//    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
//    if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
        self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    if (slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    if (dataArray.count == 0) {
        [self requestGoodsScanList];
    }
        DLog(@"定位：%@", city);
//    }
}


- (WSDoubleTableView *)getDoubleTableView
{
    if (doubleTableView) {
        return doubleTableView;
    } else {
        doubleTableView = GET_XIB_FIRST_OBJECT(@"WSDoubleTableView");
        doubleTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [doubleTableView.topView clearSubviews];
        doubleTableView.topViewHeightCon = 0;
        doubleTableView.topView.hidden = YES;
        doubleTableView.bottomViewTopCon.constant = -10;
        [doubleTableView updateConstraintsIfNeeded];
        [self.view addSubview:doubleTableView];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:doubleTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:@[top, bottom, left, right]];
       
        return doubleTableView;
    }
}


#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"2"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
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

- (void)requestGoodsScanList
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        [_collectionView endHeaderAndFooterRefresh];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:_city forKey:@"cityName"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    [params setValue:_shopTypeId forKey:@"shopTypeId"];
    [params setValue:_retailId forKey:@"retailId"];
    [params setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGoodsScanList] data:params tag:WSInterfaceTypeGoodsScanList sucCallBack:^(id result) {
        [_collectionView endHeaderAndFooterRefresh];
        NSArray *goodsScanList = [[result objectForKey:@"data"] objectForKey:@"goodsScanList"];
        if (curPage == 0) {
            [dataArray removeAllObjects];
        }
        curPage++;
        [dataArray addObjectsFromArray:goodsScanList];
        [_collectionView reloadData];
    } failCallBack:^(id error) {
        [_collectionView endHeaderAndFooterRefresh];
    } showMessage:YES];
}

#pragma mark - 测试数据
- (void)addTestData
{
    [dataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
   // [slideImageArray addObjectsFromArray: @[@"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg"]];
}

- (IBAction)backButAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)allStoreButAction:(id)sender
{
    if (storeFDataArray.count == 0) {
        [self requestGetShopTypeList];
    } else {

        if (doubleTableView && doubleTableView.hidden == NO) {
            doubleTableView.hidden = YES;
            
        } else {
               [self showStoreTypeSelectView];
        }
    }
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

#pragma mark 显示商店选择view
- (void)showStoreTypeSelectView
{
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

        _topRightLabel.text = title;
        WSDoubleTableView *doubleTable= [self getDoubleTableView];
        doubleTable.hidden = YES;
        curPage = 0;
        [self requestGoodsScanList];
    };
    
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
    NSInteger row = indexPath.row;
    WSScanNoInStoreCollectionViewCell *cell = (WSScanNoInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell" forIndexPath:indexPath];

    NSDictionary *dic = [dataArray objectAtIndex:row];
    cell.downloadImageFinish = ^() {
        CHTCollectionViewWaterfallLayout *layout =
        (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
        [layout invalidateLayout];
    };
    [cell setModel:dic];
    
    [cell.bigbut addTarget:self action:@selector(productButAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.logoBut addTarget:self action:@selector(storeLogoButAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.bigbut.tag = row;
    cell.logoBut.tag = row;
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
        return CGSizeMake(width, WSSCANNOINSTOREREUSABLEVIEW_HEIGHT - WS_SCAN_NOINSTORE_REUSABLE_BOTTOM_VIEW_HEIGHT + height);
    }
    
    if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, WSSCANNOINSTORECOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, WSSCANNOINSTORECOLLECTIONVIEWCELL_HEIGHT_SMALL);
    }
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return -20;
//}



-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"WSScanNoInStoreReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = headerView.acImageScrollManagaerView.acImageScrollView;
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
            height =  height + WSSCANNOINSTOREREUSABLEVIEW_HEIGHT - WS_SCAN_NOINSTORE_REUSABLE_BOTTOM_VIEW_HEIGHT;
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

        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - 产品按钮时间
- (void)productButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    NSString *goodsId = [dic stringForKey:@"goodsId"];
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = shopId;
    [self.navigationController pushViewController:productDetailVC animated:YES];
}

#pragma mark 商店logo按钮事件
- (void)storeLogoButAction:(UIButton *)but
{
    NSInteger tag = but.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    storeDetailVC.shop = dic;
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

@end
