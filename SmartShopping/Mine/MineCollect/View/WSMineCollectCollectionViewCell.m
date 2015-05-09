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
    NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"goodlogo"]];
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    NSString *enddate = [dic objectForKey:@"enddate"];
    _validateDateLabel.text = [NSString stringWithFormat:@"%@前有效", enddate];
}

- (void)awakeFromNib
{
    // Initialization code
    [_conView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.706 green:0.710 blue:0.714 alpha:1.000] cornerRadius:5];
}

@end
