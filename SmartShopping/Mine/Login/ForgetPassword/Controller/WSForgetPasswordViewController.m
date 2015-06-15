//
//  WSForgetPasswordViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/5.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSForgetPasswordViewController.h"

#define VARIFICATE_TIME            60

@interface WSForgetPasswordViewController ()
{
    NSTimer *timer;
    int varificateTime;
}

@property (strong, nonatomic) NSString *code;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *varificateTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwodTestField;
@property (weak, nonatomic) IBOutlet UIButton *resetPwdBut;

@end

@implementation WSForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"重设密码";
    [_resetPwdBut setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:5];
    // 输入框边界线
    NSArray *array = @[_telView, _varificateView, _passwordView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
}


- (IBAction)gainVarificateButAction:(id)sender
{
    NSString *tel = _telTextField.text;
    if (tel.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号！" duration:TOAST_VIEW_TIME];
        return;
    }
    if (![WSIdentifierValidator isValidPhone:tel]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不正确！" duration:TOAST_VIEW_TIME];
        return;
    }
    UIButton *but = (UIButton *)sender;
    [but setEnabled:NO];
    varificateTime = VARIFICATE_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    but.alpha = 0.7;
    [self requestValidCode];
}

#pragma mark 请求验证吗
- (void)requestValidCode
{
    NSDictionary *dic = @{@"phone" : _telTextField.text, @"type" : @"2"};
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetValidCode] data:dic tag:WSInterfaceTypeGetValidCode];
}

- (void)timeAction:(NSTimer *)time
{
    if (varificateTime >= 0) {
        _gainVarificateBut.titleLabel.text = [NSString stringWithFormat:@"(%d)重新获取", varificateTime];
        [_gainVarificateBut setTitle:[NSString stringWithFormat:@"(%d)重新获取", varificateTime] forState:UIControlStateNormal];
        varificateTime--;
    } else {
        _gainVarificateBut.alpha = 1;
        [timer invalidate];
        [_gainVarificateBut setEnabled:YES];
        [_gainVarificateBut setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    
}

- (IBAction)resetButAction:(id)sender
{
    BOOL flag = [self validData];
    if (flag) {
        [self requestForgetPassword];
    }
}

- (BOOL)validData
{
    BOOL flag = YES;
    NSString *tel = _telTextField.text;
    if (tel.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidPhone:tel]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不正确！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_varificateTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_code) {
        if (![_varificateTextField.text isEqualToString:_code]) {
            [SVProgressHUD showErrorWithStatus:@"验证码不正确！" duration:TOAST_VIEW_TIME];
            flag = NO;
            return flag;
        }
    }
    if (_passwodTestField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidOnlyNumberOrLetter:_passwodTestField.text]) {
        [SVProgressHUD showErrorWithStatus:@"密码由6-20个数字或字母组成！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (!(_passwodTestField.text.length >= 6 && _passwodTestField.text.length <= 20)) {
        [SVProgressHUD showErrorWithStatus:@"密码由6-20个数字或字母组成！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }

    return flag;
}

- (void)requestForgetPassword
{
    NSDictionary *dic = @{@"phone" : _telTextField.text, @"password": [_passwodTestField.text encodeMD5_32_lowercase], @"validCode" : _varificateTextField.text, @"type" : @"1"};
    [SVProgressHUD showWithStatus:@"正在重设……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeResetPassword] data:dic tag:WSInterfaceTypeResetPassword];
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    switch (tag) {
        case WSInterfaceTypeGetValidCode:
        {
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                NSDictionary *data = [result valueForKey:@"data"];
                NSString *code = [data valueForKey:@"code"];
                self.code = code;
                DLog(@"验证码：%@", code);
            }
        }
            break;
        case WSInterfaceTypeResetPassword:
        {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [SVProgressHUD showSuccessWithStatus:@"密码重设成功" duration:TOAST_VIEW_TIME];
                [NSTimer scheduledTimerWithTimeInterval:TOAST_VIEW_TIME target:self selector:@selector(resetPasswordAfter) userInfo:nil repeats:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (void)resetPasswordAfter
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestFail:(id)error tag:(int)tag
{
    switch (tag) {
        case WSInterfaceTypeGetValidCode:
        {
            
        }
            break;
        case WSInterfaceTypeResetPassword:
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"密码重设失败！" duration:TOAST_VIEW_TIME];
        }
            break;
        default:
            break;
    }
}


@end
