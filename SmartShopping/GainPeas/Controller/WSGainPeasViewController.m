//
//  GainPeasViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGainPeasViewController.h"
#import "WSNoInStoreViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "WSStoreDetailViewController.h"

#define TITLE_HEIGHT    20.0   // 标题label高度
#define IMAGE_WIDTH     30.0   // 导航条图片宽度

@interface WSGainPeasViewController () <BMKLocationServiceDelegate>
{
    BMKLocationService* _locService;
    NSMutableArray *slideImageArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *imageSlideView;
@property (weak, nonatomic) IBOutlet UIView *storeSignupView;
@property (weak, nonatomic) IBOutlet UIView *scanProductView;
@property (weak, nonatomic) IBOutlet UIView *inviateFriendView;

- (IBAction)storeSignupButAction:(id)sender;
- (IBAction)scanProductButAction:(id)sender;
- (IBAction)inviateFriendButAction:(id)sender;

@end

@implementation WSGainPeasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    slideImageArray = [[NSMutableArray alloc] init];
    
    [self initView];
    
    // 启动百度地区定位
    [self initBMK];
    
    [self addTestData];
    ACImageScrollView *imageScrollView = _imageSlideView.acImageScrollView;
    [imageScrollView setImageData:slideImageArray];
    imageScrollView.callback = ^(int index) {
        DLog(@"点击图片");
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //启动LocationService
    [_locService startUserLocationService];
    _locService.delegate = self;
//    _geocodesearch.delegate = self;
    
    [self fitNavigationBar:@"50001111110000精明豆"];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止LocationService
    _locService.delegate = nil;
//    _geocodesearch.delegate = nil;
}

#pragma mark - 测试数据
- (void)addTestData
{
    [slideImageArray addObjectsFromArray: @[@"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/image/h%3D200/sign=0b5e32f9af18972bbc3a07cad6cc7b9d/9f2f070828381f30326c8344ad014c086f06f0e2.jpg", @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/image/h%3D360/sign=c0558e592adda3cc14e4be2631e83905/b03533fa828ba61e23b0dfe94534970a314e599d.jpg", @"https://ss3.baidu.com/9fo3dSag_xI4khGko9WTAnF6hhy/image/h%3D200/sign=f3287c32237f9e2f6f351a082f31e962/d8f9d72a6059252d8689d3d0309b033b5ab5b94c.jpg", @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/image/h%3D360/sign=90cef1c74b4a20a42e1e3ac1a0509847/d1a20cf431adcbefa5d1d7d3a8af2edda2cc9f7a.jpg"]];
}

- (void)initBMK
{
    // 地理位置反编码
   // _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
}

#pragma mark - 调整导航条标题位置
- (void)fitNavigationBar:(NSString *)title
{
    WSNavigationBarCenterImageViewLabelView *barView = _navigationBarManagerView.navigationBarCenterImageViewLabelView;
    UILabel *titleLabel = barView.centerLabel;
    UIView *supView = titleLabel.superview;
    titleLabel.text = title;
    CGSize size = [titleLabel boundingRectWithSize:CGSizeMake(0, TITLE_HEIGHT)];
    size.width += 1;
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat realWidth = 0.0;
    if ((size.width + IMAGE_WIDTH) > screenWidth) {
        realWidth = screenWidth - IMAGE_WIDTH;
    } else {
        realWidth = size.width;
    }
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLabel clearConstrainsToSuperView];
    [titleLabel clearWidthAndHeight];
    NSLayoutConstraint *h = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:TITLE_HEIGHT];
    NSLayoutConstraint *virticalCenter = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:supView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *w = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:realWidth];
    CGFloat relativeCenter = (realWidth + IMAGE_WIDTH) / 2 - realWidth / 2;
    NSLayoutConstraint *horizontalCenter = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:supView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:relativeCenter];
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [supView addConstraints:@[h, virticalCenter, w, horizontalCenter]];
    
    UIImageView *imageView = barView.centerImageView;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView clearConstrainsToSuperView];
    [imageView clearWidthAndHeight];
    imageView.image = [UIImage imageNamed:@"dou"];
    NSLayoutConstraint *imageW = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:IMAGE_WIDTH];
    NSLayoutConstraint *imageH = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:IMAGE_WIDTH];
    NSLayoutConstraint *imageVirticalCenter = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:supView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [supView addConstraints:@[imageW, imageH, imageVirticalCenter, right]];
}

#pragma mark - 初始化 边界
- (void)initView
{
    // 输入框边界线
    NSArray *array = @[_storeSignupView, _scanProductView, _inviateFriendView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    DLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeocodeSearchOption.reverseGeoPoint = pt;
//    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
//    if(flag)
//    {
//        DLog(@"反geo检索发送成功");
//    }
//    else
//    {
//        DLog(@"反地理编码失败");
//    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"定位失败！！！");
}

#pragma mark - 到店签到
- (IBAction)storeSignupButAction:(id)sender
{
    //  1. GPS定位不在店内跳到 WSNoInStoreViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController

    [self toNoInStoreVC];
   
}

#pragma mark - 不在店内
- (void)toNoInStoreVC
{
    WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:noInstoreVC animated:YES];
}

#pragma mark 在店内没签到
- (void)toInStoreNoSign
{
    WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
    [self.navigationController pushViewController:inStoreNoSignVC animated:YES];

}

#pragma mark 在店内已签到
- (void)toStoreDetail
{
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

- (IBAction)scanProductButAction:(id)sender
{
    
}

- (IBAction)inviateFriendButAction:(id)sender
{
    
}
@end
