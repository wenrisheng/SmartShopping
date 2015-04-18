//
//  WSRegisterViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSRegisterViewController.h"
#import "WSUserProtocolViewController.h"
#import "WSRegisterSucView.h"

#define VARIFICATE_TIME            60

@interface WSRegisterViewController () <UITextFieldDelegate, WSNavigationBarButLabelViewDelegate>
{
    NSTimer *timer;
    int varificateTime;
    WSRegisterSucView *registerSucView;
}

@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarView;

@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *inviateView;


@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *varificateTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *inviateTextField;
@property (weak, nonatomic) IBOutlet UIButton *seeUserServerprotocolBut;

- (IBAction)registerButAction:(id)sender;
- (IBAction)seeUserServerProtocolButAction:(id)sender;
- (IBAction)gainVarificateButAction:(id)sender;

@end

@implementation WSRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    varificateTime = VARIFICATE_TIME;
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
    _navigationBarView.navigationBarButLabelView.label.text = @"注册";
    _navigationBarView.navigationBarButLabelView.delegate = self;
    
    // 输入框边界线
    NSArray *array = @[_telView, _varificateView, _passwordView, _inviateView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
    
    // 添加文字颜色和下划线
    NSString *str1 = @"查看";
    NSString *str2 = @"用户服务协议";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.459 green:0.463 blue:0.467 alpha:1.000] range:NSMakeRange(0, str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.871 green:0.369 blue:0.125 alpha:1.000] range:NSMakeRange(str1.length, str2.length)];
    
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, str1.length)];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(str1.length, str2.length)];
    [_seeUserServerprotocolBut setAttributedTitle:str forState:UIControlStateNormal];
}

#define mark - WSNavigationBarButLabelViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)registerButAction:(id)sender
{
    if (!registerSucView) {
        registerSucView = [WSRegisterSucView getView];
    }
    [self.view addSubview:registerSucView];
    [registerSucView expandToSuperView];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeRegisterSucView:) userInfo:nil repeats:NO];
}

- (IBAction)seeUserServerProtocolButAction:(id)sender
{
    WSUserProtocolViewController *userProtocolVC = [[WSUserProtocolViewController alloc] init];
    [self.navigationController pushViewController:userProtocolVC animated:YES];
}

- (IBAction)gainVarificateButAction:(id)sender
{
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

- (void)removeRegisterSucView:(NSTimer *)tim
{
    [registerSucView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
