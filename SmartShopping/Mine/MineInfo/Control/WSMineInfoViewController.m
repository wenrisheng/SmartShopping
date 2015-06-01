//
//  WSMineInfoViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineInfoViewController.h"

#define VARIFICATE_TIME            60

@interface WSMineInfoViewController ()
{
    NSTimer *timer;
    int varificateTime;
    BOOL isLady;
    UIDatePicker *datePicker;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *validCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *birdthDayTextField;
@property (weak, nonatomic) IBOutlet UITextField *inviateTextField;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *nicknameView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIButton *ladyBut;
@property (weak, nonatomic) IBOutlet UIButton *manBut;
@property (weak, nonatomic) IBOutlet UIView *inviateView;
@property (weak, nonatomic) IBOutlet UIView *birdthDayView;
@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;

- (IBAction)ladyButAction:(id)sender;
- (IBAction)manButAction:(id)sender;
- (IBAction)gainVarificateButAction:(id)sender;
- (IBAction)commitButAction:(id)sender;
- (IBAction)birthdayButAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *commitBut;


@end

@implementation WSMineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isLady = YES;
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的资料";
    
    // 输入框边界线
    NSArray *array = @[_nicknameView, _emailView, _varificateView,_birdthDayView, _inviateView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
    [_commitBut setBorderCornerWithBorderWidth:1 borderColor:[UIColor clearColor] cornerRadius:5];
    
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    _nicknameTextField.text = user.nickname;
    _emailTextField.text = user.email;
    _birdthDayTextField.text = user.birthday;
    // 男性
    if ([user.sex isEqualToString:@"1"]) {
        isLady = NO;
        [self manButAction:nil];
    } else {
        isLady = YES;
        [self ladyButAction:nil];
    }
}

- (IBAction)ladyButAction:(id)sender
{
    isLady = YES;
    [_ladyBut setBackgroundImage:[UIImage imageNamed:@"radio_choose-01"] forState:UIControlStateNormal];
    [_manBut setBackgroundImage:[UIImage imageNamed:@"radio_choose-02"] forState:UIControlStateNormal];
}

- (IBAction)manButAction:(id)sender
{
    isLady = NO;
    [_ladyBut setBackgroundImage:[UIImage imageNamed:@"radio_choose-02"] forState:UIControlStateNormal];
    [_manBut setBackgroundImage:[UIImage imageNamed:@"radio_choose-01"] forState:UIControlStateNormal];
}

- (IBAction)gainVarificateButAction:(id)sender
{
    BOOL flag = [self validEmail];
    if (flag) {
        [self requestEmailValidCode];
        UIButton *but = (UIButton *)sender;
        [but setEnabled:NO];
        varificateTime = VARIFICATE_TIME;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
        but.alpha = 0.7;
    }
}

- (void)requestEmailValidCode
{
    NSDictionary *dic = @{@"email" : _emailTextField.text};
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetEmailValidCode] data:dic tag:WSInterfaceTypeGetEmailValidCode];
}

- (BOOL)validEmail
{
    BOOL flag = YES;
    NSString *email = _emailTextField.text;
    if (email.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入邮箱！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidEmail:email]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不对！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    return flag;
}

- (IBAction)commitButAction:(id)sender
{
    BOOL flag = [self valiData];
    if (flag) {
        [self requestUpdateUser];
    }
}

- (IBAction)birthdayButAction:(id)sender
{
    [WSDatePickerUtil showDatePickerWithConfrimCallBack:^(WSDatePickerView *datePickerView) {
        NSDate *date = datePickerView.datePicker.date;
        NSString *dateStr = [WSBaseUtil getDateStrWithDate:date format:@"yyyy-MM"];
        _birdthDayTextField.text = dateStr;
    } cancelCallBack:^(WSDatePickerView *datePickerView) {
        
    }];
}

- (void)requestUpdateUser
{
    NSString *userID = [WSRunTime sharedWSRunTime].user._id;
    int sex = 1;
    // 女
    if (isLady) {
        sex = 0;
    }
    NSString *byInviteCode = _inviateTextField.text.length == 0 ? @"" : _inviateTextField.text;
    NSDictionary *dic = @{@"id" : [NSNumber numberWithInt:[userID intValue]], @"nickname": _nicknameTextField.text, @"Email" : _emailTextField.text, @"byInviteCode": byInviteCode};

    [SVProgressHUD showWithStatus:@"正在提交……"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeUpdateUser] data:dic tag:WSInterfaceTypeUpdateUser sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            WSUser *user = [WSRunTime sharedWSRunTime].user;
            user.nickname = _nicknameTextField.text;
            user.email = _emailTextField.text;
            user.birthday = _birdthDayTextField.text;
            if (isLady) {
                user.sex = @"0";
            } else {
                user.sex = @"1";
            }
            // 本地存储用户信息
            NSData *userdata = [NSKeyedArchiver archivedDataWithRootObject:[WSRunTime sharedWSRunTime].user];
            [USER_DEFAULT setObject:userdata forKey:USER_KEY];
            [SVProgressHUD showSuccessWithStatus:@"修改成功！" duration:TOAST_VIEW_TIME];
            [NSTimer scheduledTimerWithTimeInterval:TOAST_VIEW_TIME target:self selector:@selector(doSucAfter) userInfo:nil repeats:NO];
        }

    } failCallBack:^(id error) {
        
    } showMessage:YES];

}

- (BOOL)valiData
{
    BOOL flag = YES;
    if (_nicknameTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入昵称！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    BOOL emailFlag = [self validEmail];
    if (!emailFlag) {
        flag = NO;
        return flag;
    }
    if (_validCodeTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_birdthDayTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择出生年月！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    return flag;
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

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    [SVProgressHUD dismiss];
    switch (tag) {
        case WSInterfaceTypeGetEmailValidCode:
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
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
               
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
        case WSInterfaceTypeGetEmailValidCode:
        {
            [SVProgressHUD dismiss];
        }
            break;
        case WSInterfaceTypeUpdateUser:
        {
            [SVProgressHUD dismissWithError:@"修改失败！" afterDelay:TOAST_VIEW_TIME];
        }
            break;
        default:
            break;
    }
}


@end
