//
//  WSResetPasswordViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSResetPasswordViewController.h"

#define VARIFICATE_TIME            60

@interface WSResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIView *oldPwdView;
@property (weak, nonatomic) IBOutlet UIView *nwePwdView;
@property (weak, nonatomic) IBOutlet UIView *repetPwdView;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nwePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repetNwePasswordTextField;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBut;

- (IBAction)comfirmButAction:(id)sender;


@end

@implementation WSResetPasswordViewController

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
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"密码修改";
    [_confirmBut setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:5];
    // 输入框边界线
    NSArray *array = @[_oldPwdView, _nwePwdView, _repetPwdView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
}

- (IBAction)comfirmButAction:(id)sender
{
    BOOL flag = [self validData];
    if (flag) {
        [self requestResetPassword];
    }
}

- (BOOL)validData
{
    BOOL flag = YES;
    if (_oldPasswordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入原密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *encodePwd = [_oldPasswordTextField.text encodeMD5_32_lowercase];
    if (![encodePwd isEqualToString:user.password]) {
        [SVProgressHUD showErrorWithStatus:@"原密码不正确！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_nwePasswordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入新密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if ([_oldPasswordTextField.text isEqualToString:_nwePasswordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"新密码与原密码一致，请重新输入！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_repetNwePasswordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请确认新密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidOnlyNumberOrLetter:_repetNwePasswordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"密码由6-20个数字或字母组成！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![_nwePasswordTextField.text isEqualToString:_repetNwePasswordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"新密码不一致！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    return flag;
}

- (void)requestResetPassword
{
    NSString *phone = [WSRunTime sharedWSRunTime].user.phone;
    phone = phone.length > 0 ? phone : [WSRunTime sharedWSRunTime].user._id;
    NSDictionary *dic = @{@"phone" : phone, @"password": [_oldPasswordTextField.text encodeMD5_32_lowercase], @"newPassword" : [_nwePasswordTextField.text encodeMD5_32_lowercase], @"type" : @"2"};
    [SVProgressHUD showWithStatus:@"正在修改……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeResetPassword] data:dic tag:WSInterfaceTypeResetPassword];
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    [SVProgressHUD dismiss];
    BOOL flag = [WSInterfaceUtility validRequestResult:result];
    if (flag) {
        WSUser *user = [WSRunTime sharedWSRunTime].user;
        user.password = [_nwePasswordTextField.text encodeMD5_32_lowercase];
        // 本地存储用户信息
        NSData *userdata = [NSKeyedArchiver archivedDataWithRootObject:user];
        [USER_DEFAULT setObject:userdata forKey:USER_KEY];
        [SVProgressHUD showSuccessWithStatus:@"密码修改成功" duration:TOAST_VIEW_TIME];
        [NSTimer scheduledTimerWithTimeInterval:TOAST_VIEW_TIME target:self selector:@selector(resetPasswordAfter) userInfo:nil repeats:NO];
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
            [SVProgressHUD showErrorWithStatus:@"密码修改失败！" duration:TOAST_VIEW_TIME];
        }
            break;
        default:
            break;
    }
}

@end
