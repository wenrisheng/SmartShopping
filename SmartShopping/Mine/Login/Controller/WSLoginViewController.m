//
//  WSLoginViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/17.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSLoginViewController.h"
#import "WSRegisterViewController.h"
#import "WSForgetPasswordViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <Parse/Parse.h>
#import "WSUser.h"

@interface WSLoginViewController () <UITextFieldDelegate, WSNavigationBarButLabelButViewDelegate>

@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBut;

- (IBAction)loginButAction:(id)sender;
- (IBAction)forgetPasswordButAction:(id)sender;
- (IBAction)weixinLoginButAction:(id)sender;
- (IBAction)weiboLoginButAction:(id)sender;
- (IBAction)qqLoginButAction:(id)sender;


@end

@implementation WSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarView.navigationBarButLabelButView.delegate = self;
    _navigationBarView.navigationBarButLabelButView.centerLabel.text = @"登录";
    
    [_loginBut setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:5];
    [_telView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    [_passwordView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}


- (void)setLocationCity:(NSDictionary *)locationDic
{
    //int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    //if (deoCodeFalg == 0) {
    self.city = [locationDic objectForKey:LOCATION_CITY];
}

#pragma mark - WSNavigationBarButLabelButViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationBarRightButClick:(UIButton *)but
{
    WSRegisterViewController *registerVC = [[WSRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    
    if (tag == 0) { // 手机号码
        
    } else { // 密码
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 登陆按钮事件
- (IBAction)loginButAction:(id)sender
{
    BOOL flag = [self validData];
    if (flag) {
        [self requestLogin];
    }
}

#pragma mark 请求登陆
- (void)requestLogin
{
    NSString *pwd = _passwordTextField.text;
    NSString *account = _telTextField.text;
    pwd = [pwd encodeMD5_32_lowercase];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:account forKey:@"phone"];
    [dic setValue:pwd forKey:@"password"];
    [dic setValue:@"1" forKey:@"type"];
    
    [SVProgressHUD showWithStatus:@"正在登录……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeLogin] data:dic tag:WSInterfaceTypeLogin];
}

#pragma mark 验证登陆数据
- (BOOL)validData
{
    BOOL flag = YES;
    if (_telTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidPhone:_telTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确格式的手机号码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    return flag;
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    [SVProgressHUD dismiss];
    BOOL flag = [WSInterfaceUtility validRequestResult:result];
    if (flag) {
        NSDictionary *data = [result valueForKey:@"data"];
        NSDictionary *userDic = [data valueForKey:@"user"];
        
        NSMutableDictionary *tempDic = [WSBaseUtil changNumberToStringForDictionary:userDic];
        WSUser *user = [WSProjUtil convertDicToUser:tempDic];
        [user setValuesForKeysWithDictionary:tempDic];
        user.phone = _telTextField.text;
        user.loginType = UserLoginTypePhone;
        user.userType = @"1";
        [self doAfterLoginSucWithUser:user];
    }
}

- (void)requestFail:(id)error tag:(int)tag
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"登陆失败！" duration:TOAST_VIEW_TIME];
}

- (IBAction)forgetPasswordButAction:(id)sender
{
    WSForgetPasswordViewController *forgetPasswordVC = [[WSForgetPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgetPasswordVC animated:YES];
}

#pragma mark - 第三方登陆
#pragma mark  微信登陆
- (IBAction)weixinLoginButAction:(id)sender
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [self loginWithType:ShareTypeWeixiSession];
    // 注销
    //  [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
}

#pragma mark  微博登陆
- (IBAction)weiboLoginButAction:(id)sender
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [self loginWithType:ShareTypeSinaWeibo];
    // 注销
//    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
}

#pragma mark  qq登陆
- (IBAction)qqLoginButAction:(id)sender
{
    if (!_city) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        return;
    }
    [self loginWithType:ShareTypeQQSpace];
    // 注销
//        [ShareSDK cancelAuthWithType:ShareTypeQQ];
}

- (void)loginWithType:(ShareType)shareType
{
    [ShareSDK getUserInfoWithType:shareType authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
        if (result) {
            //打印输出用户uid：
            NSString *uid = [userInfo uid];
            NSLog(@"uid = %@",[userInfo uid]);
            //打印输出用户昵称：
            NSString *nickname = [userInfo nickname];
            NSLog(@"name = %@",[userInfo nickname]);
            //打印输出用户头像地址：
            NSLog(@"icon = %@",[userInfo profileImage]);
            UserLoginType loginType;
            NSString *type = nil;
            switch (shareType) {
                case ShareTypeWeixiSession:
                {
                    loginType = UserLoginTypeWechat;
                    type = @"4";
                }
                    break;
                case ShareTypeSinaWeibo:
                {
                    loginType = UserLoginTypeWeibo;
                    type = @"5";
                }
                    break;
                case ShareTypeQQSpace:
                {
                    loginType = UserLoginTypeQQ;
                    type = @"3";
                }
                    break;
                default:
                    break;
            }
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:_city forKey:@"cityName"];
            [params setValue:uid forKey:@"thirdid"];
            [params setValue:nickname forKey:@"nickname"];
            [params setValue:type forKey:@"type"];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeThirdlogin] data:params tag:WSInterfaceTypeThirdlogin sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    NSDictionary *data = [result valueForKey:@"data"];
                    NSDictionary *userDic = [data valueForKey:@"user"];
                    
                    NSMutableDictionary *tempDic = [WSBaseUtil changNumberToStringForDictionary:userDic];
                    WSUser *user = [[WSUser alloc] init];
                    [user setValuesForKeysWithDictionary:tempDic];
                    user.phone = _telTextField.text;
                    user.loginType = [NSString stringWithFormat:@"%d", (int)loginType];
                    user.userType = @"1";
                    [self doAfterLoginSucWithUser:user];
                }
            }failCallBack:^(id error) {
                [SVProgressHUD showErrorWithStatus:@"登陆失败！" duration:TOAST_VIEW_TIME];
            }showMessage:YES];
        } else {
           
            DLog(@"error code:%d description:%@ level:%d", (int)error.errorCode, error.errorDescription, error.errorLevel);
        }
    }];
}

#pragma mark - 登录成功后
- (void)doAfterLoginSucWithUser:(WSUser *)user
{
    // 首次打开app
    [WSProjUtil synchronFirstUsedBeanNumWithUser:user callBack:^{
       
    }];
    
    // 每天打开app
    [WSProjUtil synchronOpenAppBeanNumWithUser:user callBack:^{
       
    }];

    // 设置运行时user
    WSRunTime *runTime = [WSRunTime sharedWSRunTime];
    runTime.user = user;
    
    WSUser *beforeTourist = [WSProjUtil unarchiverUserWithKey:TOURIST_KEY];
    if (beforeTourist) {
        int touristBeanNum = [beforeTourist.beanNumber intValue];
        if (touristBeanNum > 0) {
            [WSProjUtil synchronBeanNumWithUser:user offsetBeanNumber:beforeTourist.beanNumber callBack:^(){
                beforeTourist.beanNumber = @"0";
                [WSProjUtil synchronBeanNumWithUser:beforeTourist offsetBeanNumber:beforeTourist.beanNumber callBack:^(){
                }];
            }];
        }
    }
    [WSProjUtil archiverUser:user key:USER_KEY];
    [self popViewController];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:NO];
    if (_callBack) {
        _callBack();
    }
}

@end
