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

@interface WSRegisterViewController () <UITextFieldDelegate, WSNavigationBarButLabelViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    NSTimer *timer;
    int varificateTime;
    WSRegisterSucView *registerSucView;
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geocodesearch;
}

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (weak, nonatomic) IBOutlet UIButton *gainVarificateBut;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarView;

@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UIView *varificateView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *inviateView;
@property (weak, nonatomic) IBOutlet UIButton *registerBut;


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
    // 启动百度地区定位
   // [self initBMK];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //启动LocationService
    [_locService startUserLocationService];
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止LocationService
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}


- (void)initBMK
{
    // 地理位置反编码
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:LOCATION_DISTANCE_FILTER];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    DLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    _latitude = pt.latitude;
    _longitude = pt.longitude;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        DLog(@"反geo检索发送成功");
    } else {
        DLog(@"反地理编码失败");
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"定位失败！！！");
    // [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:3];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        BMKAddressComponent *addressCom = result.addressDetail;
        self.city = addressCom.city;
        DLog(@"%@%@%@%@%@", addressCom.province, addressCom.city, addressCom.district, addressCom.streetName, addressCom.streetNumber);
    } else {
        DLog(@"反地理编码失败");
    }
}

#pragma mark - 初始化视图
- (void)initView
{
    _navigationBarView.navigationBarButLabelView.label.text = @"注册";
    _navigationBarView.navigationBarButLabelView.delegate = self;
    [_registerBut setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:5];
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

#pragma mark - 注册
#pragma mark 注册按钮事件
- (IBAction)registerButAction:(id)sender
{
    BOOL flag = [self validData];
    if (flag) {
        [self requestRegister];
    }
}

#pragma mark 请求注册
- (void)requestRegister
{
    NSString *latitude = _city.length == 0 ? @"" : [NSString stringWithFormat:@"%f", _latitude];
    NSString *longitude = _city.length == 0 ? @"" : [NSString stringWithFormat:@"%f", _longitude];
    NSDictionary *dic = @{@"phone" : _telTextField.text, @"password" : [_passwordTextField.text encodeMD5_32_lowercase], @"byInviteCode" : _inviateTextField.text, @"validCode" : _varificateTextField.text, @"lon" : longitude, @"lat" : latitude, @"cityName" : _city};
     [SVProgressHUD showWithStatus:@"正在注册……"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeRegister] data:dic tag:WSInterfaceTypeRegister];

}

#pragma mark 验证注册数据
- (BOOL)validData
{
    BOOL flag = YES;
    if (_telTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidPhone:_telTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不正确！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_varificateTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_passwordTextField.text.length == 0) {
         [SVProgressHUD showErrorWithStatus:@"请输入密码！" duration:TOAST_VIEW_TIME];
        flag = NO;
        return flag;
    }
    if (_city.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
        flag = NO;
#if DEBUG
      self.city = @"广州";
        flag = YES;
#endif
        return flag;
    }
       return flag;
}

#pragma mark 注册成功
- (void)registerSuc
{
    //  注册成功后的弹框
    if (!registerSucView) {
        registerSucView = [WSRegisterSucView getView];
    }
    [self.view addSubview:registerSucView];
    [registerSucView expandToSuperView];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(removeRegisterSucView:) userInfo:nil repeats:NO];
}

#pragma mark － 查看用户服务协议
- (IBAction)seeUserServerProtocolButAction:(id)sender
{
    WSUserProtocolViewController *userProtocolVC = [[WSUserProtocolViewController alloc] init];
    [self.navigationController pushViewController:userProtocolVC animated:YES];
}

#pragma mark － 获取验证码
- (IBAction)gainVarificateButAction:(id)sender
{
    if (_telTextField.text.length > 0) {
        UIButton *but = (UIButton *)sender;
        [but setEnabled:NO];
        varificateTime = VARIFICATE_TIME;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
        but.alpha = 0.7;
        [self requestValidCode];
    } else {
        
    }
}

#pragma mark 请求验证吗
- (void)requestValidCode
{
    NSDictionary *dic = @{@"phone" : _telTextField.text, @"type" : @"1"};
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

- (void)removeRegisterSucView:(NSTimer *)tim
{
    [registerSucView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
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
        case WSInterfaceTypeRegister:
        {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                [self registerSuc];
            }
        }
            break;
        default:
            break;
    }
}

- (void)requestFail:(id)error tag:(int)tag
{
    switch (tag) {
        case WSInterfaceTypeGetValidCode:
        {
            
        }
            break;
        case WSInterfaceTypeRegister:
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"注册失败！" duration:TOAST_VIEW_TIME];
        }
            break;
        default:
            break;
    }
}

@end
