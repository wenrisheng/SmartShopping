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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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
    if (_passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码！" duration:TOAST_VIEW_TIME];
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
        WSUser *user = [[WSUser alloc] init];
        [user setValuesForKeysWithDictionary:tempDic];
        user.phone = _telTextField.text;
        user.loginType = UserLoginTypePhone;
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
    [self loginWithType:ShareTypeWeixiSession];
    // 注销
    //  [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
}

#pragma mark  微博登陆
- (IBAction)weiboLoginButAction:(id)sender
{
    [self loginWithType:ShareTypeSinaWeibo];
    // 注销
//    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
}

#pragma mark  qq登陆
- (IBAction)qqLoginButAction:(id)sender
{
    [self loginWithType:ShareTypeQQ];
    // 注销
//        [ShareSDK cancelAuthWithType:ShareTypeQQ];
}

- (void)loginWithType:(ShareType)shareType
{
    [ShareSDK getUserInfoWithType:shareType authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
        if (result) {
            //打印输出用户uid：
            NSLog(@"uid = %@",[userInfo uid]);
            //打印输出用户昵称：
            NSLog(@"name = %@",[userInfo nickname]);
            //打印输出用户头像地址：
            NSLog(@"icon = %@",[userInfo profileImage]);
            UserLoginType loginType;
            switch (shareType) {
                case ShareTypeWeixiSession:
                {
                    loginType = UserLoginTypeWechat;
                }
                    break;
                case ShareTypeSinaWeibo:
                {
                    loginType = UserLoginTypeWeibo;
                }
                    break;
                case ShareTypeQQ:
                {
                    loginType = UserLoginTypeQQ;
                }
                    break;
                default:
                    break;
            }
            WSUser *user = [[WSUser alloc] init];
            user.loginType = loginType;
            user.uid = [userInfo uid];
            user.nickname = [userInfo nickname];
            user.profileImage = [userInfo profileImage];
            
            [self doAfterLoginSucWithUser:user];
            
            //            PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
            //            [query whereKey:@"uid" equalTo:[userInfo uid]];
            //            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //                if ([objects count] == 0)
            //                {
            //                    PFObject *newUser = [PFObject objectWithClassName:@"UserInfo"];
            //                    [newUser setObject:[userInfo uid] forKey:@"uid"];
            //                    [newUser setObject:[userInfo nickname] forKey:@"name"];
            //                    [newUser setObject:[userInfo profileImage] forKey:@"icon"];
            //                    [newUser saveInBackground];
            //                    // 欢迎注册
            //
            //                } else {
            //                    // 欢迎回来
            //
            //                }
            //            }];
        } else {
            DLog(@"error code:%d description:%@ level:%d", (int)error.errorCode, error.errorDescription, error.errorLevel);
        }
    }];
}

#pragma mark - 登录成功后
- (void)doAfterLoginSucWithUser:(WSUser *)user
{
    // 同步本地用户信息
    [self synchromUserData:user];
    
    [self.navigationController popViewControllerAnimated:NO];
    if (_callBack) {
        _callBack();
    }
}

#pragma mark 同步用户数据
- (void)synchromUserData:(WSUser *)user
{
    //
    NSData *beforeData = [USER_DEFAULT objectForKey:USER_KEY];
    if (beforeData) { // 同步是否推动消息
        WSUser *beforeUser = [NSKeyedUnarchiver unarchiveObjectWithData:beforeData];
        user.isPushNotification = beforeUser.isPushNotification;
    }
    
    // 设置运行时user
    WSRunTime *runTime = [WSRunTime sharedWSRunTime];
    runTime.user = user;
    
    // 从本机器取出积累的精明豆给用户
    int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
    if (user.beanNumber.length > 0) {
        user.beanNumber = [NSString stringWithFormat:@"%d", [user.beanNumber intValue] + appPeasNum];
    } else {
        user.beanNumber = [NSString stringWithFormat:@"%d", appPeasNum];
    }
    
    // 本机精明豆重新清零
    [USER_DEFAULT setValue:[NSNumber numberWithInt:0] forKey:APP_PEAS_NUM];
    
    // 本地存储用户信息
    NSData *userdata = [NSKeyedArchiver archivedDataWithRootObject:user];
    [USER_DEFAULT setObject:userdata forKey:USER_KEY];

}

@end
