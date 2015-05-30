//
//  HomeCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "CollectSucView.h"
#import "WSProductDetailViewController.h"
#import "WSLocationDetailViewController.h"

@implementation HomeCollectionViewCell
@synthesize dic;

- (void)setModel:(NSMutableDictionary *)modelDic
{
    self.dic = modelDic;
    NSString *goodsScan = [dic stringForKey:@"goodsScan"];
    if ([goodsScan isEqualToString:@"1"]) {
        _scanImageView.hidden = NO;
    } else {
        _scanImageView.hidden = YES;
    }
    
    NSString *goodsEndDate = [dic objectForKey:@"goodsEndDate"];
    NSString *formatDate = [WSProjUtil converDateWithDateStr:goodsEndDate];
    _validDateLabel.text = formatDate;
    
    NSString *goodsLogo = [dic objectForKey:@"goodsLogo"];
    NSString *goodsLogoURL = [WSInterfaceUtility getImageURLWithStr:goodsLogo];
     _bigImageView.contentMode = UIViewContentModeScaleToFill;
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:goodsLogoURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
            if (_downloadImageFinish) {
                _downloadImageFinish();
            }
        }
    }];
    NSString *shopLogo = [dic objectForKey:@"shopLogo"];
    NSString *shopLogoURL = [WSInterfaceUtility getImageURLWithStr:shopLogo];
    [_smallImageView sd_setImageWithURL:[NSURL URLWithString:shopLogoURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _smallImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            _smallImageView.contentMode = UIViewContentModeScaleToFill;
        }
    }];
    
    NSString *shopName = [dic objectForKey:@"shopName"];
    _addressLabel.text = shopName;
    
    NSString *distance = [dic stringForKey:@"distance"];
    NSString *restultDistance = [WSProjUtil converDistanceWithDistanceStr:distance];
    _distanceLabel.text = restultDistance;
    
    NSString *isCollect = [dic stringForKey:@"isCollect"];
    // 没有收藏  白色安心
    if ([isCollect isEqualToString:@"N"]) {
        [_leftBut setBackgroundImage:[UIImage imageNamed:@"colleation-011"] forState:UIControlStateNormal];
    // 已收藏
    } else {
        [_leftBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib
{
    // Initialization code
    [_conView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.706 green:0.710 blue:0.714 alpha:1.000] cornerRadius:5];
    
//    [self.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];

    [_leftBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
    [_rightBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
}

- (void)leftButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(homeCollectionViewCellDidClickLeftBut:)]) {
        [_delegate homeCollectionViewCellDidClickLeftBut:self];
    }
}

- (void)rightButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(homeCollectionViewCellDidClickRightBut:)]) {
        [_delegate homeCollectionViewCellDidClickRightBut:self];
    }
}
- (IBAction)distanceButAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(homeCollectionViewCellDidClickDistanceBut:)]) {
        [_delegate homeCollectionViewCellDidClickDistanceBut:self];
    } else {
        NSString *lat = [dic stringForKey:@"lat"];
        NSString *lon = [dic stringForKey:@"lon"];
        NSString *shopName = [dic stringForKey:@"shopName"];
        NSString *address = [dic objectForKeyedSubscript:@"address"];
        WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
        locationDetailVC.latitude = [lon doubleValue];
        locationDetailVC.longitude = [lat doubleValue];
        locationDetailVC.locTitle = shopName;
        locationDetailVC.address = address;
        [self.viewController.navigationController pushViewController:locationDetailVC animated:YES];
    }
}

- (IBAction)collectButAction:(id)sender
{
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSString *isCollect = [dic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [dic setValue:@"Y" forKey:@"isCollect"];
                    [_leftBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [CollectSucView showCollectSucView];
                    });
                }
                
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            } showMessage:YES];
        // 已收藏 取消收藏
        } else {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:param tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
                float flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [self.viewController.view makeToast:@"已取消收藏！"];
                    [dic setValue:@"N" forKey:@"isCollect"];
                    [_leftBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
                }
            } failCallBack:^(id error) {
                [SVProgressHUD showErrorWithStatus:@"操作失败！" duration:TOAST_VIEW_TIME];
            } showMessage:YES];
           
        }
    } else {
        [WSUserUtil actionAfterLogin:^{
            if (_refreshPage) {
                _refreshPage();
            }
        }];
    }
}

- (IBAction)shareButAction:(id)sender
{
    NSString *goodsName = [dic objectForKey:@"goodsName"];
    NSString *shopName = [dic objectForKey:@"shopName"];
    NSString *goodsLogo = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"goodsLogo"]];
    NSString *url = [dic objectForKey:@"h5Url"];
    
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    
    [shareDic setValue:goodsName forKey:GOODS_NAME];
    [shareDic setValue:shopName forKey:SHOP_NAME];
    [shareDic setValue:goodsLogo forKey:GOODS_LOGO];
    [shareDic setValue:url forKey:GOODS_URL];
    [WSProjShareUtil shareGoodsDetails:shareDic];

}

- (IBAction)productButAction:(id)sender
{
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [dic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = [dic stringForKey:@"shopId"];
    [self.viewController.navigationController pushViewController:productDetailVC animated:YES];

}


@end
