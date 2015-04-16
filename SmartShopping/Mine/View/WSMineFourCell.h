//
//  WSMineFourCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/16.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSMINEFOURCELL_HEIGHT    130

@interface WSMineFourCell : UITableViewCell

+ (instancetype)getCell;

@property (weak, nonatomic) IBOutlet UIView *conView;
@property (weak, nonatomic) IBOutlet UISwitch *pushSettingSwitch;
@property (weak, nonatomic) IBOutlet UIButton *clearCacheBut;
@property (weak, nonatomic) IBOutlet UIButton *chectUpdateBut;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@end
