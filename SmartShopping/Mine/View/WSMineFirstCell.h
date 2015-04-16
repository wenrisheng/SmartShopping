//
//  WSMineFirstCell.h
//  SmartShopping
//
//  Created by wrs on 15/4/16.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WSMINEFIRSTCELL_HEIGHT   150

@protocol WSMineFirstCellDelegate <NSObject>

- (void)mineFirstCellLoginedButAction:(UIButton *)but;
- (void)mineFirstCelLoginImmediateButAction:(UIButton *)but;
- (void)mineFirstCellMinePeasButAction:(UIButton *)but;
- (void)mineFirstCellMineConverButAction:(UIButton *)but;
- (void)mineFirstCellMineConsumeButAction:(UIButton *)but;
- (void)mineFirstCellMineCollectButAction:(UIButton *)but;

@end

@interface WSMineFirstCell : UITableViewCell

+ (instancetype)getCell;

@property (weak, nonatomic) id<WSMineFirstCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

// 已登录
@property (weak, nonatomic) IBOutlet UIView *loginedView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
- (IBAction)loginedButAction:(id)sender;

//  未登录
@property (weak, nonatomic) IBOutlet UIView *noLoginView;
- (IBAction)loginImmediateAction:(id)sender;

//我的精明豆
- (IBAction)myPeasButAction:(id)sender;

// 我的兑换、我的消费卷、我的收藏
- (IBAction)mineConverButAction:(id)sender;
- (IBAction)mineConsumeButAction:(id)sender;
- (IBAction)mineCollectButAction:(id)sender;

@end
