//
//  WSStoreDetailCollectionReusableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT     220

@interface WSStoreDetailCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *imageSwitchView;
@property (weak, nonatomic) IBOutlet UIView *signedView;
@property (weak, nonatomic) IBOutlet UIView *noSignupView;
@property (weak, nonatomic) IBOutlet UIButton *noSignupBut;
@property (weak, nonatomic) IBOutlet UIButton *noSignupScanBut;

@end
