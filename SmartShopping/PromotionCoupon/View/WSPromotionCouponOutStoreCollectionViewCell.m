//
//  WSPromotionCouponInStoreCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/23.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponOutStoreCollectionViewCell.h"

@implementation WSPromotionCouponOutStoreCollectionViewCell

- (void)setModel:(NSDictionary *)dic
{
    NSString *shopLogo= [dic objectForKey:@"shopLogo"];
    [_loginImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:shopLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _storeNameLabel.text = [dic objectForKey:@"shopName"];
    _addressLabel.text = [dic objectForKey:@"address"];
    NSString *distance = [dic stringForKey:@"distance"];
    float distanceFloat = [distance floatValue];

    _distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distanceFloat];;
    _couponNumLabel.text = [NSString stringWithFormat:@"共有%@促销", [dic objectForKey:@"saleCount"]];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSString *FgoodsScan = nil;
    NSString *FisCollect = nil;
    NSString *FgoodsEndDate = nil;
    NSString *FgoodsLogo = nil;
    NSString *FgoodsName = @"N";
    
    NSString *SgoodsScan = nil;
    NSString *SisCollect = nil;
    NSString *SgoodsEndDate = nil;
    NSString *SgoodsLogo = nil;
    NSString *SgoodsName = @"N";
    if (goodsList.count > 0) {
        NSDictionary *FDic = [goodsList objectAtIndex:0];
        FgoodsEndDate = [FDic objectForKey:@"goodsEndDate"];
        FgoodsLogo = [FDic objectForKey:@"goodsLogo"];
        FgoodsName = [FDic objectForKey:@"goodsName"];
        FgoodsScan = [FDic objectForKey:@"goodsScan"];
        FisCollect = [FDic objectForKey:@"isCollect"];
    }
   
    if (goodsList.count > 1) {
        NSDictionary *SDic = [goodsList objectAtIndex:1];
        SgoodsEndDate = [SDic objectForKey:@"goodsEndDate"];
        SgoodsLogo = [SDic objectForKey:@"goodsLogo"];
        SgoodsName = [SDic objectForKey:@"goodsName"];
        SgoodsScan = [SDic objectForKey:@"goodsScan"];
        SisCollect = [SDic objectForKey:@"isCollect"];
    }

    _leftValidDateLabel.text = [self getValidateWithDateStr:FgoodsEndDate];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:FgoodsLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    // 没有收藏
    if ([FisCollect isEqualToString:@"N"]) {
        [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
       
    } else {
        [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
       
    }
    
    _rightValidDateLabel.text = [self getValidateWithDateStr:SgoodsEndDate];
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:SgoodsLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    // 没有收藏
    if ([SisCollect isEqualToString:@"N"]) {
        [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
        _rightCollectBut.enabled = YES;
    } else {
        [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
        _rightCollectBut.enabled = NO;
    }

    
}

- (NSString *)getValidateWithDateStr:(NSString *)dateStr
{
    if (!dateStr) {
        return @"有效日期未知";
    }
    NSArray *array = [dateStr componentsSeparatedByString:@"-"];
    if (array.count < 3) {
        return  @"有效日期未知";
    }
    NSString *month = [array objectAtIndex:1];
    int monthInt = [month intValue];
    NSString *day = [array objectAtIndex:2];
    int dayInt = [day intValue];
    NSString *result = [NSString stringWithFormat:@"%d月%d日前有效", monthInt, dayInt];
    return result;
}

- (void)awakeFromNib {
    // Initialization code
    NSArray *array = @[_leftProductView, _rightProductView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.867 green:0.875 blue:0.878 alpha:1.000] cornerRadius:5];
    }
}

@end
