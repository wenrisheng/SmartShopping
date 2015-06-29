//
//  WSMineConverCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConverCell.h"

@implementation WSMineConverCell

+ (instancetype)getCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSMineConverCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)setModel:(NSDictionary *)dic
{
    NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"logoPath"]];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    _giftNumLabel.text = [NSString stringWithFormat:@"礼品编号：%@", [dic stringForKey:@"giftNumber"]];
    _nameLabel.text = [dic objectForKey:@"giftName"];
    _numLabel.text = [dic stringForKey:@"beanNumber"];
    _timeLabel.text = [dic objectForKey:@"exchangeTime"];
    _statusLabel.text = [dic objectForKey:@"giftStatus"];
    _shuliangLabel.text = [NSString stringWithFormat:@"数量：%@", [dic stringForKey:@"count"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
