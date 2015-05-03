//
//  PaopaoView.m
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "PaopaoView.h"

@implementation PaopaoView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc] init];
        _addressLabel = [[UILabel alloc] init];
        NSArray *labelArray = @[_titleLabel, _addressLabel];
        NSArray *colorArray = @[[UIColor colorWithWhite:0.510 alpha:1.000], [UIColor colorWithWhite:0.510 alpha:1.000]];
        NSArray *fontArray = @[[UIFont systemFontOfSize:12], [UIFont systemFontOfSize:10]];
        NSInteger count = labelArray.count;
        for (int i = 0; i < count; i++) {
            UILabel *label = [labelArray objectAtIndex:i];
            label.textColor = [colorArray objectAtIndex:i];
            label.font = [fontArray objectAtIndex:i];
            [self addSubview:label];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            [self addConstraints:@[left, right]];
            switch (i) {
                case 0:
                {
                    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
                    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0 constant:20];
                    [self addConstraints:@[top, height]];
                }
                    break;
                case 1:
                {
                    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1/3 constant:0];
                    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-20];
                    [self addConstraints:@[top, height]];
                }
                    break;
                default:
                    break;
            }
            _titleLabel.numberOfLines = 1;
            _addressLabel.numberOfLines = 0;
        }
    }
    return self;
}

@end
