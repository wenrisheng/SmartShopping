//
//  WSMineCollectViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineCollectViewController.h"
#import "WSMineCollectCollectionViewCell.h"

#define CELLECTIONVIEW_CELL_SPACE       10   //cell与cell的间距
#define CELLECTIONVIEW_CONTENT_INSET    10   //CollectionView 左右下三边的内容边距

@interface WSMineCollectViewController () <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>
{
    NSMutableArray *dataArray;
    int curPage;
    UIAlertView *alertView;
}

@property (strong, nonatomic) NSDictionary *delectDic;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

@end

@implementation WSMineCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc] init];
    curPage = 0;
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的收藏";
  //  _contentCollectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    // 注册
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"WSMineCollectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSMineCollectCollectionViewCell"];
    
    [_contentCollectionView addLegendHeaderWithRefreshingBlock:^{
        curPage = 0;
        [self requestMineCollect];
    }];
    [_contentCollectionView addLegendFooterWithRefreshingBlock:^{
        [self requestMineCollect];
    }];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(20, 10, 10, 10);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = COLLECTION_VIEW_GAP;
    layout.minimumInteritemSpacing = COLLECTION_VIEW_GAP;
    _contentCollectionView.collectionViewLayout = layout;
    dataArray = [[NSMutableArray alloc] init];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    curPage = 0;
    [self requestMineCollect];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    self.city = [locationDic objectForKey:LOCATION_CITY];
    self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];

    DLog(@"定位：%@", _city);
    if (_city.length > 0) {
        if (self.city.length > 0 && dataArray.count == 0) {
            [self requestMineCollect];
        }
    }
}

- (void)requestMineCollect
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败!" duration:TOAST_VIEW_TIME];
        [_contentCollectionView endHeaderAndFooterRefresh];
        return;
    }
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeMyCollectList] data:@{@"uid": userId,  @"lon": [NSString stringWithFormat:@"%f", _latitude], @"lat": [NSString stringWithFormat:@"%f", _longtide], @"pages": [NSString stringWithFormat:@"%d", curPage + 1], @"pageSize":WSPAGE_SIZE } tag:WSInterfaceTypeMyCollectList sucCallBack:^(id result) {
        [_contentCollectionView endHeaderAndFooterRefresh];
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            if (curPage == 0) {
                [dataArray removeAllObjects];
            }
            curPage ++;
            NSArray *myCollectList = [[result objectForKey:@"data"]objectForKey:@"myCollectList"];
            [dataArray addObjectsFromArray:myCollectList];
            
            [_contentCollectionView reloadData];
        }
    } failCallBack:^(id error) {
         [_contentCollectionView endHeaderAndFooterRefresh];
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
    WSMineCollectCollectionViewCell *cell = (WSMineCollectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSMineCollectCollectionViewCell" forIndexPath:indexPath];
    UISwipeGestureRecognizer *swipeGest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestAction:)];
    swipeGest.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell addGestureRecognizer:swipeGest];
    cell.downloadImageFinish = ^() {
        CHTCollectionViewWaterfallLayout *layout =
        (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
        [layout invalidateLayout];
    };
    NSInteger row = indexPath.row;
    cell.tag = row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
    [cell setModel:dic];
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
    if (image) {
        float height = image.size.height * width / image.size.width;
        return CGSizeMake(width, WSMINECOLLECTCOLLECTIONVIEWCELL_HEIGHT - WSMINE_COLLECT_COLLECTION_VIEW_CELL_IMAGE_HEIGHT + height);
    }
    if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, WSMINECOLLECTCOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, WSMINECOLLECTCOLLECTIONVIEWCELL_HEIGHT_SMALL);
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

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - swipeGestAction
- (void)swipeGestAction:(UISwipeGestureRecognizer *)swipeGest
{
    if (!alertView) {
      alertView  = [[UIAlertView alloc] initWithTitle:@"操作" message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    }
   
    [alertView show];
    
    UIView *view = [swipeGest view];
    NSInteger tag = view.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    self.delectDic = dic;
      DLog(@"tag:%d", (int)tag);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex==1) {
        NSString *goodsid = [_delectDic stringForKey:@"goodsId"];
        NSString *shopId = [_delectDic stringForKey:@"shopId"];
        NSString *uid = [WSRunTime sharedWSRunTime].user._id;
        [SVProgressHUD showWithStatus:@"正在删除……"];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:@{@"uid": uid, @"goodsid": goodsid, @"shopid": shopId} tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [dataArray removeObject:_delectDic];
                self.delectDic = nil;
                [_contentCollectionView reloadData];
            }
        } failCallBack:^(id error) {
            [SVProgressHUD dismissWithError:@"删除失败！" afterDelay:TOAST_VIEW_TIME];
        }];

    }
    

}


@end
