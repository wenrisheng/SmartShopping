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

@interface WSMineCollectViewController ()
{
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

@end

@implementation WSMineCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的收藏";
    _contentCollectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    // 注册
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"WSMineCollectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSMineCollectCollectionViewCell"];
    
    [_contentCollectionView addHeaderWithCallback:^{
        [self requestMineCollect];
    }];
//    [_contentCollectionView addFooterWithCallback:^{
//        // 模拟延迟加载数据，因此2秒后才调用）
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 结束刷新
//            [_contentCollectionView footerEndRefreshing];
//        });
//        
//        DLog(@"下拉刷新完成！");
//    }];
    dataArray = [[NSMutableArray alloc] init];
    [self requestMineCollect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestMineCollect
{
    [SVProgressHUD showWithStatus:@"加载中……"];
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeMyCollectList] data:@{@"uid": userId} tag:WSInterfaceTypeMyCollectList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [dataArray removeAllObjects];
            NSArray *myCollectList = [result objectForKey:@"myCollectList"];
            [dataArray addObjectsFromArray:myCollectList];
            
            [dataArray addObjectsFromArray:@[@"", @"", @""]];
            [_contentCollectionView reloadData];
        }
    } failCallBack:^(id error) {
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
    NSInteger row = indexPath.row;
    cell.tag = row;
    NSDictionary *dic = [dataArray objectAtIndex:row];
   // [cell setModel:dic];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CELLECTIONVIEW_CELL_SPACE;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - swipeGestAction
- (void)swipeGestAction:(UISwipeGestureRecognizer *)swipeGest
{
    UIView *view = [swipeGest view];
    NSInteger tag = view.tag;
    NSDictionary *dic = [dataArray objectAtIndex:tag];
    NSString *goodsid = [dic objectForKey:@"goodsid"];
    NSString *uid = [WSRunTime sharedWSRunTime].user._id;
    [SVProgressHUD showWithStatus:@"正在删除……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:@{@"uid": uid, @"goodsid": goodsid} tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [dataArray removeObjectAtIndex:tag];
            [_contentCollectionView reloadData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"删除失败！" afterDelay:TOAST_VIEW_TIME];
    }];
    DLog(@"tag:%d", (int)tag);
}

@end
