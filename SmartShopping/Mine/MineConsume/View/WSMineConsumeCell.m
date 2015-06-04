//
//  WSMineConsumeCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/20.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConsumeCell.h"

@implementation WSMineConsumeCell

- (void)setModel:(NSDictionary *)dic
{
    UIColor *color = nil;
    NSString *statusFlag = [dic stringForKey:@"giftStatus"];
    NSString *status = nil;
    if ([statusFlag isEqualToString:@"未使用"]) {
        color = [UIColor colorWithRed:0.784 green:0.576 blue:0.000 alpha:1.000];
        status = @"未使用";
    } else {
        color = [UIColor colorWithRed:0.655 green:0.659 blue:0.667 alpha:1.000];
        status = @"已使用";
    }
    [_leftView setBorderCornerWithBorderWidth:1 borderColor:color cornerRadius:1];
    _consumeLabel.textColor = color;
    _statusLabel.textColor = color;
    _statusLabel.text = status;
    NSString *unit = @"¥ ";
    id value = [dic stringForKey:@"beanNumber"];
    NSString *beanNumber = nil;
    if ([value isKindOfClass:[NSNull class]]) {
        beanNumber = @"";
    } else {
        beanNumber = value;
    }
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", unit, beanNumber]];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, unit.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(unit.length, beanNumber.length)];
    _consumeLabel.attributedText = tempStr;

    _titleLabel.text = [dic objectForKey:@"shopName"];
    id tempNum = [dic objectForKey:@"giftNumber"];
    NSString *giftNumber = nil;
    if ([tempNum isKindOfClass:[NSNull class]]) {
        giftNumber = @"";
    } else {
        giftNumber = tempNum;
    }
    _consumeNumLabel.text = giftNumber;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
