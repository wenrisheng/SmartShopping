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

@interface WSStoreDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    WSStoreDetailCollectionReusableView *reusableView;
    NSMutableArray *dataArray;
    NSMutableArray *slideImageArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation WSStoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _navigationBarManagerView.navigationBarButLabelView.label.text = @"珠江新城汇景新城店";
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSStoreDetailCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSStoreDetailCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSStoreDetailCollectionReusableView"];
    
    
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

    
    
    [dataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
     [slideImageArray addObjectsFromArray: @[@"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg"]];

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
    WSStoreDetailCollectionViewCell *cell = (WSStoreDetailCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSStoreDetailCollectionViewCell" forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];

    NSInteger row = indexPath.row;
    cell.scanBut.tag = row;
    [cell.scanBut addTarget:self action:@selector(scanButActioin:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
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
        return CGSizeMake(collectionView.bounds.size.width, WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT);
    } else {
        return CGSizeZero;
    }
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSStoreDetailCollectionReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = reusableView.imageScrollManagerView.acImageScrollView;
        [imageScrollView setImageData:slideImageArray];
        return reusableView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - 扫描按钮事件
- (void)scanButActioin:(UIButton *)but
{
    // 1. 不在店内则提示不在店内
    // 2. 在店内则跳到 WSScanProductViewController
    [self toScanProduct];
}

- (void)toScanProduct
{
    WSScanProductViewController *scanProductVC = [[WSScanProductViewController alloc] init];
    [self.navigationController pushViewController:scanProductVC animated:YES];
}

@end
