//
//  WSScanNoInStoreCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSScanNoInStoreCollectionViewCell.h"

@implementation WSScanNoInStoreCollectionViewCell

- (void)setModel:(NSDictionary *)dic
{
    NSString *goodslLogo = [dic objectForKey:@"goodslLogo"];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:goodslLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    NSString *shopLogo = [dic objectForKey:@"shopLogo"];
    [_smallImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:shopLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    NSString *goodsEndDate = [dic objectForKey:@"goodsEndDate"];
    NSString *resultDate = [WSProjUtil converDateWithDateStr:goodsEndDate];
    _dateLabel.text = resultDate;
    NSString *beannumber = [dic stringForKey:@"beannumber"];
    _peaLabel.text = beannumber;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
