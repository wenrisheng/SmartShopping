//
//  WSNoinStoreCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSNoinStoreCell.h"

@implementation WSNoinStoreCell

+ (instancetype)getCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSNoinStoreCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)setModel:(NSDictionary *)dic
{
    NSString *logopath = [dic objectForKey:@"logopath"];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:logopath]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _storeNameLabel.text = [dic objectForKey:@"shopname"];
    _addressLabel.text = [dic objectForKey:@"address"];
    NSString *resultDistance = [WSProjUtil converDistanceWithDistanceStr:[dic objectForKey:@"distance"]];
    _distanceLabel.text = resultDistance;
    _beanNumLabel.text = [NSString stringWithFormat:@"到店即可赚取%@精明豆", [dic stringForKey:@"beannumber"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
