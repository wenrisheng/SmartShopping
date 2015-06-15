//
//  WSNoinStoreCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSNOINSTORECELL_HEIGHT     100

@interface WSNoinStoreCell : UITableViewCell

+ (instancetype)getCell;

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

@property (weak, nonatomic) IBOutlet UIButton *titleBut;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *distanceView;
@property (weak, nonatomic) IBOutlet UIButton *signupBut;
@property (weak, nonatomic) IBOutlet UIButton *distanceBut;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *beanNumLabel;

@end
