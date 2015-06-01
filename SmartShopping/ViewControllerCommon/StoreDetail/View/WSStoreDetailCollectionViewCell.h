//
//  WSStoreDetailCollectionViewCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSSTOREDETAILCOLLECTIONVIEWCELL_HEIGHT             182
#define WSSTOREDETAILCOLLECTIONVIEWCELL_HEIGHT_SMAIL       152
#define WS_STORE_DETAIL_COLLECTION_VIEW_CELL_IMAGE_HEIGHT  152

@interface WSStoreDetailCollectionViewCell : UICollectionViewCell

@property (copy) void(^downloadImageFinish)(void);

- (void)setModel:(NSDictionary *)dic;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *peaLabel;

@property (weak, nonatomic) IBOutlet UIButton *scanBut;
@end
