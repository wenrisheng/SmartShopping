//
//  WSStoreDetailCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSStoreDetailCollectionViewCell.h"

@implementation WSStoreDetailCollectionViewCell

- (void)setModel:(NSDictionary *)dic
{
    NSString *goodsLogo= [dic objectForKey:@"goodsLogo"];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:goodsLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (_downloadImageFinish) {
            _downloadImageFinish();
        }
    }];
    
    _peaLabel.text = [dic stringForKey:@"beannumber"];
    _dateLabel.text = [WSProjUtil converDateWithDateStr:[dic objectForKey:@"goodsEndDate"]];
    NSString *isScan = [dic stringForKey:@"isScan"];
    NSString *scanImage = nil;
    if ([isScan isEqualToString:@"Y"]) {
        scanImage = @"scan_green";
    } else {
        scanImage = @"scanning";
    }
    [_scanBut setBackgroundImage:[UIImage imageNamed:scanImage] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    // Initialization code
    [_scanBut setEnlargeEdgeWithTop:19 right:20 bottom:10 left:20];
}

@end
