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

@interface WSScanNoInStoreViewController ()
{
    WSScanNoInStoreReusableView *headerView;
    NSMutableArray *dataArray;
    NSMutableArray *slideImageArray;
    int curPage;
}

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)backButAction:(id)sender;
- (IBAction)allStoreButAction:(id)sender;


@end

@implementation WSScanNoInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    curPage = 0;
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    [_tipView setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:_tipView.bounds.size.height / 2];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSScanNoInStoreReusableView"];
    
    
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

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
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
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:_city forKey:@"cityName"];
    [params setValue:[NSString stringWithFormat:@"%f", _latitude] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%f", _longtide] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%d", curPage + 1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGoodsScanList] data:params tag:WSInterfaceTypeGoodsScanList sucCallBack:^(id result) {
        NSArray *goodsScanList = [[result objectForKey:@"data"] objectForKey:@"goodsScanList"];
        if (curPage == 0) {
            [dataArray removeAllObjects];
        }
        curPage++;
        [dataArray addObjectsFromArray:goodsScanList];
        [_collectionView reloadData];
    } failCallBack:^(id error) {
        
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
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (dataArray.count == 0) {
        return 1;
    }
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    WSScanNoInStoreCollectionViewCell *cell = (WSScanNoInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell" forIndexPath:indexPath];
    if (dataArray.count == 0) {
        cell.hidden = YES;
        return cell;
    } else {
        cell.hidden = NO;
        NSDictionary *dic = [dataArray objectAtIndex:row];
        [cell setModel:dic];
    }
    [cell.bigbut addTarget:self action:@selector(productButAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.logoBut addTarget:self action:@selector(storeLogoButAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.bigbut.tag = row;
    cell.logoBut.tag = row;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
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
        return CGSizeMake(collectionView.bounds.size.width, WSSCANNOINSTOREREUSABLEVIEW_HEIGHT);
    } else {
        return CGSizeZero;
    }
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSScanNoInStoreReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = headerView.acImageScrollManagaerView.acImageScrollView;
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
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    storeDetailVC.shopid = shopId;
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

@end
