//
//  WSMoreGiftCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSMOREGIFTCELL_HEIGHT  172

@interface WSMoreGiftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *conView;
@property (weak, nonatomic) IBOutlet UIView *leftProduct;
@property (weak, nonatomic) IBOutlet UIView *rightProduct;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreGiftBut;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftPeaLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightPeaLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;

@end
