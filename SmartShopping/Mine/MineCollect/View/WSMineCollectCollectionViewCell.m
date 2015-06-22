//
//  WSMineCollectCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineCollectCollectionViewCell.h"
#import "WSProductDetailViewController.h"
#import "WSLocationDetailViewController.h"

@implementation WSMineCollectCollectionViewCell

- (void)setModel:(NSMutableDictionary *)dic
{
    self.dic = dic;
    NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"goodsLogo"]];
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (_downloadImageFinish) {
            _downloadImageFinish();
        }
    }];
    NSString *goodsEndDate = [dic objectForKey:@"goodsEndDate"];
    NSString *formatDate = [WSProjUtil converDateWithDateStr:goodsEndDate];
    _validateDateLabel.text = formatDate;
    
    NSString *distance = [dic stringForKey:@"distance"];
    NSString *restultDistance = [WSProjUtil converDistanceWithDistanceStr:distance];
    _distanceLabel.text = restultDistance;
    
    NSString *shopLogo = [dic objectForKey:@"shopLogo"];
    NSString *shopLogoURL = [WSInterfaceUtility getImageURLWithStr:shopLogo];
    [_smallImageView sd_setImageWithURL:[NSURL URLWithString:shopLogoURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _smallImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            _smallImageView.contentMode = UIViewContentModeScaleToFill;
        }
    }];
}

- (void)awakeFromNib
{
    // Initialization code
    [_conView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.706 green:0.710 blue:0.714 alpha:1.000] cornerRadius:5];
}

- (IBAction)prodcutDetailButAction:(id)sender {
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [_dic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = [_dic stringForKey:@"shopId"];
    productDetailVC.CollectCallBack = ^(NSDictionary *resultDic) {
        NSString *isCollect = [resultDic stringForKey:@"isCollect"];
        [_dic setValue:isCollect forKey:@"isCollect"];
        [self setModel:_dic];
    };
    [self.viewController.navigationController pushViewController:productDetailVC animated:YES];
}

- (IBAction)distanceButAction:(id)sender {
    NSString *lat = [_dic stringForKey:@"lat"];
    NSString *lon = [_dic stringForKey:@"lon"];
    NSString *shopName = [_dic stringForKey:@"shopName"];
    NSString *address = [_dic objectForKeyedSubscript:@"address"];
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    locationDetailVC.latitude = [lat doubleValue];
    locationDetailVC.longitude = [lon doubleValue];
    locationDetailVC.locTitle = shopName;
    locationDetailVC.address = address;
    [self.viewController.navigationController pushViewController:locationDetailVC animated:YES];
}
@end
