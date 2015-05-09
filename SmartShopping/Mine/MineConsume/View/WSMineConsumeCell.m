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
    NSString *status = nil;
    NSInteger row = 2;
    if (row % 2 == 0) {
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
    NSString *value = [dic objectForKey:@"beanNumber"];
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", unit, value]];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, unit.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(unit.length, value.length)];
    _consumeLabel.attributedText = tempStr;

    _titleLabel.text = [dic objectForKey:@"shopName"];
    _consumeNumLabel.text = [dic objectForKey:@"giftNumber"];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
