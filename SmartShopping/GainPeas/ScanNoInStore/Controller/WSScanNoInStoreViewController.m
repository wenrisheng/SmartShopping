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

@interface WSScanNoInStoreViewController ()
{
    WSScanNoInStoreReusableView *headerView;
    NSMutableArray *dataArray;
    NSMutableArray *slideImageArray;
}

@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)backButAction:(id)sender;
- (IBAction)allStoreButAction:(id)sender;


@end

@implementation WSScanNoInStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    [_tipView setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:_tipView.bounds.size.height / 2];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"WSScanNoInStoreReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSScanNoInStoreReusableView"];
    
    
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
 [self addTestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 测试数据
- (void)addTestData
{
    [dataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
    [slideImageArray addObjectsFromArray: @[@"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg"]];
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
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    WSScanNoInStoreCollectionViewCell *cell = (WSScanNoInStoreCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WSScanNoInStoreCollectionViewCell" forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    [cell.smallImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
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
        [imageScrollView setImageData:slideImageArray];
        imageScrollView.callback = ^(int index) {
            
        };
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - 产品按钮时间
- (void)productButAction:(UIButton *)but
{
    
}

#pragma mark 商店logo按钮事件
- (void)storeLogoButAction:(UIButton *)but
{
    
}

@end
