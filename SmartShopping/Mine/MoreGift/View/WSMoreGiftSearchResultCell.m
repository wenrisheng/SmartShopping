//
//  WSMoreGiftCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMoreGiftSearchResultCell.h"
#import "WSMoreGiftViewController.h"

@implementation WSMoreGiftSearchResultCell

- (void)setLeftModel:(NSDictionary *)dic;
{
    NSString *leftImageURL = @"";
    NSString *leftName = @"--";
    NSString *leftPeaNum = @"";
    leftImageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"giftLogo"]];
    leftName = [dic objectForKey:@"giftName"];
    leftPeaNum = [dic stringForKey:@"requiredBean"];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _leftLabel.text = leftName;
    _leftPeaLabel.text = leftPeaNum;
}

- (void)setRightModel:(NSDictionary *)dic
{
    NSString *rightImageURL = @"";
    NSString *rightName = @"--";
    NSString *rightPeaNum = @"";
    rightImageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"giftLogo"]];
    rightName = [dic objectForKey:@"giftName"];
    rightPeaNum = [dic stringForKey:@"requiredBean"];
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _rightLabel.text = rightName;
    _rightPeaLabel.text = rightPeaNum;
}

- (void)awakeFromNib {
    // Initialization code
    NSArray *array = @[_leftProduct, _rightProduct];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000] cornerRadius:5];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
