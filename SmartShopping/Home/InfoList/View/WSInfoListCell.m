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
        _contentLabel.textColor = [UIColor blackColor];
        DLog("未读消息");
    } else {
        DLog("已读消息");
        _contentLabel.textColor = [UIColor colorWithWhite:0.651 alpha:1.000];
    }
    _contentLabel.text = [dic objectForKey:@"title"];
    NSString *timeStr = [dic objectForKey:@"time"];
    NSDate *date = [WSCalendarUtil getDateWithDateStr:timeStr format:@"yyyy-MM-dd HH:ss:mm"];
    NSString *dateStr = [WSCalendarUtil getDateStrWithDate:date format:@"yyyy-MM-dd HH:ss"];
    _timeLabel.text = dateStr;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
