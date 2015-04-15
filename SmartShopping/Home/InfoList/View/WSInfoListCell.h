//
//  InfoListCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/14.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#define INFOLISTCELL_HEIGHT    80

@interface WSInfoListCell : UITableViewCell

+ (instancetype)getCelll;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
