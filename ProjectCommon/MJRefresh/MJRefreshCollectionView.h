//
//  MJRefreshCollectionView.h
//  BaseStaticLibrary
//
//  Created by wrs on 15/4/13.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"

@interface MJRefreshCollectionView : UICollectionView

@property (strong, nonatomic) MJRefreshHeaderView *refreshHeaderView;
@property (strong, nonatomic) MJRefreshFooterView *refreshFooterView;

@end
