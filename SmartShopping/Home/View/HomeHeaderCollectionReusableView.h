//
//  HomeHeaderCollectionReusableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOMEHEADERCOLLECTIONREUSABLEVIEW_HEIGHT                     250

#define HOMEHEADER_COLLECTION_REUSABLE_VIEW_IMAGESCROLLVIEW_HEIGHT  100

@interface HomeHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *imageScrollManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peasLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeSignInBut;
@property (weak, nonatomic) IBOutlet UIButton *scanProductBut;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendBut;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
