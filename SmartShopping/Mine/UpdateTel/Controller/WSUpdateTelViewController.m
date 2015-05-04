//
//  WSResetPasswordViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSUpdateTelViewController.h"

#define VARIFICATE_TIME            60

@interface WSUpdateTelViewController ()
{
    NSTimer *timer;
    int varificateTime;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *varificateTextField;

- (IBAction)gainVarificateButAction:(id)sender;
- (IBAction)resetButAction:(id)sender;

@end

@implementation WSUpdateTelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"更换手机号码";
    
    // 输入框边界线
    NSArray *array = @[_telView, _varificateView];
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
    NSDictionary *dic = @{@"phone" : _telTextField.text, @"type" : @"1"};
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetValidCode] data:dic tag:WSInterfaceTypeGetValidCode];
    UIButton *but = (UIButton *)sender;
    [but setEnabled:NO];
    varificateTime = VARIFICATE_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    but.alpha = 0.7;
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
        [self requestUpdateTel];
    }
}

- (void)requestUpdateTel
{
    NSString *oldPhone = [WSRunTime sharedWSRunTime].user.phone;
    NSDictionary *dic = @{@"phone" : oldPhone, @"newPhon": _telTextField.text, @"validCode" : _varificateTextField.text};
    [SVProgressHUD showWithStatus:@"正在更改……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUpdatePhone] data:dic tag:WSInterfaceTypeUpdatePhone];
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
        return NO;
    }
    if (_varificateTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return NO;
    }
    return flag;
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
                DLog(@"验证码：%@", code);
            }
        }
            break;
        case WSInterfaceTypeUpdatePhone:
        {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [SVProgressHUD showSuccessWithStatus:@"手机号更改成功！" duration:TOAST_VIEW_TIME];
                [NSTimer scheduledTimerWithTimeInterval:TOAST_VIEW_TIME target:self selector:@selector(doSucAfter) userInfo:nil repeats:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (void)doSucAfter
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
        case WSInterfaceTypeUpdatePhone:
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"手机号更改失败！" duration:TOAST_VIEW_TIME];
        }
            break;
        default:
            break;
    }
}


@end
