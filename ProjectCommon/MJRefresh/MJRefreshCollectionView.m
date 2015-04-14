//
//  MJRefreshCollectionView.m
//  BaseStaticLibrary
//
//  Created by wrs on 15/4/13.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "MJRefreshCollectionView.h"

@implementation MJRefreshCollectionView

- (id)init
{
    self = [super  init];
    if (self) {
            [self addRefreshHeaderView];
            [self addRefreshFooterView];
    }
    return self;
}

- (void)awakeFromNib
{
   // [self addRefreshHeaderView];
  //  [self addRefreshFooterView];
}

- (void)addRefreshHeaderView
{
    _refreshHeaderView = [MJRefreshHeaderView header];
    _refreshHeaderView.scrollView = self;
}

- (void)addRefreshFooterView
{
    _refreshFooterView = [MJRefreshFooterView footer];
    _refreshFooterView.scrollView = self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
