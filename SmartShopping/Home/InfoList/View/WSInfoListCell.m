//
//  InfoListCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/14.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInfoListCell.h"

@implementation WSInfoListCell

+ (instancetype)getCelll
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WSInfoListCell" owner:nil options:nil];
    return [array firstObject];
}

- (void)setModel:(NSDictionary *)dic
{
    NSString *isRead = [dic stringForKey:@"isRead"];
    // 未读
    if ([isRead isEqualToString:@"1"]) {
        _contentLabel.textColor = [UIColor colorWithWhite:0.353 alpha:1.000];
    } else {
        _contentLabel.textColor = [UIColor colorWithWhite:0.651 alpha:1.000];
    }
    _contentLabel.text = [dic objectForKey:@"title"];
    _timeLabel.text = [dic objectForKey:@"time"];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
