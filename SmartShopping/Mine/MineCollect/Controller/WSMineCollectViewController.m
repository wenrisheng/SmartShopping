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
    dataArray = [[NSMutableArray alloc] init];
    [dataArray addObjectsFromArray:@[@"", @"", @"", @""]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
