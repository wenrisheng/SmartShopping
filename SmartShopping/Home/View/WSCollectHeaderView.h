//
//  WSCollectHeaderView.h
//  SmartShopping
//
//  Created by wrs on 15/5/13.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSCollectHeaderView : UIView

@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *imageScrollManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peasLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeSignInBut;
@property (weak, nonatomic) IBOutlet UIButton *scanProductBut;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendBut;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
