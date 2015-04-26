//
//  WSOrderWriterViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGiftOrderWriterViewController.h"
#import "WSOrderSucView.h"
#import "WSOrderFailView.h"

@interface WSGiftOrderWriterViewController () <UITextViewDelegate>
{
    NSString *temStr1;
    NSString *temStr2;
    NSString *curNum;
    WSOrderSucView *sucView;
    WSOrderFailView *failView;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *peaNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *subBut;
@property (weak, nonatomic) IBOutlet UIButton *addBut;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainPeaLabel;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UILabel *detailPlaceHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountPeaLabel;

- (IBAction)subButAction:(id)sender;
- (IBAction)addButAction:(id)sender;
- (IBAction)commitOrderButAction:(id)sender;

@end

@implementation WSGiftOrderWriterViewController

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
    temStr1 = @"兑换后还剩";
    temStr2 = @"个精明豆";
    NSString *remainPea = @"100";
    [self setRemainPeaValueWithRemainValue:remainPea];
    _telTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _telTextField.textAlignment = NSTextAlignmentRight;
    _addressTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _addressTextField.textAlignment = NSTextAlignmentRight;
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

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _detailPlaceHolderLabel.text = @"请输入详细地址";
    }else{
        _detailPlaceHolderLabel.text = @"";
    }
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
        if (!failView) {
            failView = GET_XIB_FIRST_OBJECT(@"WSOrderFailView");
            [failView.confirmBut addTarget:self action:@selector(dismissFailView) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:failView];
        [failView expandToSuperView];
        
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

- (void)dismissFailView
{
    [failView removeFromSuperview];
}

#pragma mark - 提交订单按钮事件
- (IBAction)commitOrderButAction:(id)sender
{
    BOOL flag = [self validateData];
    if (flag) {
        [self commitOrderSuc];
    }
}

- (void)commitOrderSuc
{
    if (!sucView) {
        sucView = GET_XIB_FIRST_OBJECT(@"WSOrderSucView");
        [sucView.confirmBut addTarget:self action:@selector(dismissSucView) forControlEvents:UIControlEventTouchUpInside];
    }
    sucView.remainPeaLavel.text = @"您还有10个精明豆";
    [self.view addSubview:sucView];
    [sucView expandToSuperView];
}

- (void)dismissSucView
{
    [sucView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateData
{
    float flag = YES;
    if (_telTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidPhone:_telTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不正确！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (_addressTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入配送地址！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (_detailAddressTextView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入详细地址！" duration:2.0];
        flag = NO;
        return flag;
    }
    return flag;
}

@end
