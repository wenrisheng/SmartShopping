//
//  WSMoreGiftCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMoreGiftCell.h"
#import "WSMoreGiftViewController.h"

@implementation WSMoreGiftCell

- (void)setModel:(NSDictionary *)dic
{
    NSArray *dataArray = [dic objectForKey:CATEGORY_DATA_ARRAY];
    NSString *title = [dic objectForKey:CATEGORY_TITLE];
    _titleLabel.text = title;
    
    _leftBut.enabled = NO;
    NSString *leftImageURL = @"";
    NSString *leftName = @"--";
    NSString *leftPeaNum = @"";
    if (dataArray.count > 0) {
        NSDictionary *firstDic = [dataArray objectAtIndex:0];
        leftImageURL = [WSInterfaceUtility getImageURLWithStr:[firstDic objectForKey:@"giftLogo"]];
        leftName = [firstDic objectForKey:@"giftName"];
        leftPeaNum = [firstDic stringForKey:@"requiredBean"];
        _leftBut.enabled = YES;
    }
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _leftLabel.text = leftName;
    _leftPeaLabel.text = leftPeaNum;
    
    NSString *rightImageURL = @"";
    NSString *rightName = @"--";
    NSString *rightPeaNum = @"";
    if (dataArray.count > 1) {
        NSDictionary *secondDic = [dataArray objectAtIndex:1];
        rightImageURL = [WSInterfaceUtility getImageURLWithStr:[secondDic objectForKey:@"giftLogo"]];
        rightName = [secondDic objectForKey:@"giftName"];
        rightPeaNum = [secondDic stringForKey:@"requiredBean"];
        [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        _rightLabel.text = rightName;
        _rightPeaLabel.text = rightPeaNum;
        _rightView.hidden = NO;
    } else {
        _rightView.hidden = YES;
    }

}

- (void)awakeFromNib {
    // Initialization code
    NSArray *array = @[_leftView, _rightView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.855 green:0.859 blue:0.863 alpha:1.000] cornerRadius:5];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
