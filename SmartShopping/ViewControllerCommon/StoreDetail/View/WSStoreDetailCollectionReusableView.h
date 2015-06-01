//
//  WSStoreDetailCollectionReusableView.h
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSSTOREDETAILCOLLECTIONREUSABLEVIEW_HEIGHT                  220

#define WS_STORE_DETAIL_COLLECTION_RESUSABLE_VIEW_BOTTOMVIEW_HEIGHT 120

@interface WSStoreDetailCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *imageScrollManagerView;
@property (weak, nonatomic) IBOutlet UIImageView *signupImageView;
@property (weak, nonatomic) IBOutlet UILabel *signupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;
@property (weak, nonatomic) IBOutlet UILabel *scanLabel;

@property (weak, nonatomic) IBOutlet UILabel *peaLabel;

@end
