//
//  WSMineCollectCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineCollectCollectionViewCell.h"

@implementation WSMineCollectCollectionViewCell

- (void)setModel:(NSDictionary *)dic
{
    NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"goodsLogo"]];
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
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

@end
