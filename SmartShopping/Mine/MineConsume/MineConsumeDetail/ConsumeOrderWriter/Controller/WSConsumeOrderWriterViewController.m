//
//  WSOrderWriterViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSConsumeOrderWriterViewController.h"

@interface WSConsumeOrderWriterViewController () <UITextViewDelegate>
{
    NSString *temStr1;
    NSString *temStr2;
    NSString *curNum;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *valueView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *peaNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *subBut;
@property (weak, nonatomic) IBOutlet UIButton *addBut;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainPeaLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountPeaLabel;

- (IBAction)subButAction:(id)sender;
- (IBAction)addButAction:(id)sender;
- (IBAction)commitOrderButAction:(id)sender;

@end

@implementation WSConsumeOrderWriterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    curNum = @"1";
    [self initView];
    // 不可以减
    [self notSub];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"订单填写";
     [_valueView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.784 green:0.576 blue:0.000 alpha:1.000] cornerRadius:1];
    NSString *unit = @"¥ ";
    NSString *value = @"500";
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", unit, value]];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, unit.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(unit.length, value.length)];
    _valueLabel.attributedText = tempStr;
    
    temStr1 = @"兑换后还剩";
    temStr2 = @"个精明豆";
    NSString *remainPea = @"100";
    [self setRemainPeaValueWithRemainValue:remainPea];
}

#pragma mark - 设置兑换后生育精明豆富文本
- (void)setRemainPeaValueWithRemainValue:(NSString *)remianValue
{
    NSMutableAttributedString *temStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", temStr1, remianValue, temStr2]];
    
    UIColor *gray = [UIColor colorWithRed:0.651 green:0.655 blue:0.659 alpha:1.000];
    UIColor *red = [UIColor colorWithRed:0.898 green:0.380 blue:0.125 alpha:1.000];
    [temStr addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(0, temStr1.length)];
    [temStr addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(temStr1.length, remianValue.length)];
    [temStr addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(temStr1.length + remianValue.length, temStr2.length)];
    _remainPeaLabel.attributedText = temStr;
    [_numLabel setBorderCornerWithBorderWidth:0 borderColor:[UIColor colorWithRed:0.906 green:0.910 blue:0.918 alpha:1.000] cornerRadius:5];
    _numLabel.text = curNum;
}

#pragma mark - 加减数量按钮事件
#pragma mark 减精明豆
- (IBAction)subButAction:(id)sender
{
    int curNumInt = [curNum intValue];
    int tem = curNumInt - 1;
    if (tem == 1) { // 不可以减
        [self notSub];
        // 可以加
        [self canAdd];
        curNumInt = tem;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    } else { // 可以减
        curNumInt--;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
        [self canSub];
        // 可以加
        [self canAdd];
    }
}

#pragma mark 加精明豆
- (IBAction)addButAction:(id)sender
{
    int curNumInt = [curNum intValue];
    int tem = curNumInt + 1;
    int maxNum = 5;
    if (tem == maxNum) { // 不可以加
        [self notAdd];
        // 可以减
        [self canSub];
        curNumInt = tem;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    } else { // 可以加
        curNumInt++;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
        [self canAdd];
        [self canSub];
    }
}

- (void)canSub
{
    _subBut.enabled = YES;
    [_subBut setBackgroundImage:[UIImage imageNamed:@"left-"] forState:UIControlStateNormal];
}

- (void)notSub
{
    _subBut.enabled = NO;
    [_subBut setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
}

- (void)canAdd
{
    _addBut.enabled = YES;
    [_addBut setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
}

- (void)notAdd
{
    _addBut.enabled = NO;
    [_addBut setBackgroundImage:[UIImage imageNamed:@"right-"] forState:UIControlStateNormal];
}

- (IBAction)commitOrderButAction:(id)sender
{
 
}

@end
