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
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIView *nicknameView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIButton *ladyBut;
@property (weak, nonatomic) IBOutlet UIButton *manBut;
@property (weak, nonatomic) IBOutlet UIView *inviateView;
@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;

- (IBAction)ladyButAction:(id)sender;
- (IBAction)manButAction:(id)sender;
- (IBAction)gainVarificateButAction:(id)sender;
- (IBAction)commitButAction:(id)sender;

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
    NSArray *array = @[_nicknameView, _emailView, _varificateView, _inviateView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    UIButton *but = (UIButton *)sender;
    [but setEnabled:NO];
    varificateTime = VARIFICATE_TIME;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    but.alpha = 0.7;
}

- (IBAction)commitButAction:(id)sender {
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

@end
