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
#import "WSScanNoInStoreViewController.h"
#import "WSInviateFriendViewController.h"
#import "WSAdvertisementDetailViewController.h"

#define TITLE_HEIGHT    20.0   // 标题label高度
#define IMAGE_WIDTH     30.0   // 导航条图片宽度

@interface WSGainPeasViewController ()
{
    NSMutableArray *slideImageArray;
}

@property (strong, nonatomic) NSString *city;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    if (_city.length != 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    [self fitNavigationBar];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
    if (self.city.length > 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    //int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    //if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        DLog(@"定位：%@", city);
   // }
}

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"2"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [slideImageArray removeAllObjects];
            NSArray *photoList = [[result objectForKey:@"data"] objectForKey:@"photoList"];
            [slideImageArray addObjectsFromArray:photoList];
            NSInteger imageCount = slideImageArray.count;
            NSMutableArray *imageDataArray = [NSMutableArray array];
            for (int i = 0; i < imageCount; i++) {
                NSDictionary *dic = [slideImageArray objectAtIndex:i];
                NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"pic_path"]];
                [imageDataArray addObject:imageURL];
            }
            ACImageScrollView *imageScrollView = _imageSlideView.acImageScrollView;
            [imageScrollView setImageData:imageDataArray];
            imageScrollView.callback = ^(int index) {
                DLog(@"广告：%d", index);
                NSDictionary *dic = [slideImageArray objectAtIndex:index];
                WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
                advertisementVC.url = [dic objectForKey:@"third_link"];
                [self.navigationController pushViewController:advertisementVC animated:YES];
            };

        }
    } failCallBack:^(id error) {
        
    }];
}

#pragma mark - 调整导航条标题位置
- (void)fitNavigationBar
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *peaNum = nil;
    if (user) {
        peaNum = user.beanNumber;
    } else {
        int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
       peaNum = [NSString stringWithFormat:@"%d豆", appPeasNum];
    }
    NSString *title = [NSString stringWithFormat:@"%@精明豆", peaNum];
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


#pragma mark - 到店签到
- (IBAction)storeSignupButAction:(id)sender
{
    //  1. GPS定位不在店内跳到 WSNoInStoreViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController

    [self toNoInStoreVC];
   
}

#pragma mark 扫描产品按钮事件
- (IBAction)scanProductButAction:(id)sender
{
    // 1. 在店内跳到 WSStoreDetailViewController
    // 2. 不在店内跳到 WSScanNoInStoreViewController
    [self toScanNoInStore];
}

#pragma mark 邀请好友
- (IBAction)inviateFriendButAction:(id)sender
{
    WSInviateFriendViewController *inviateFriendVC = [[WSInviateFriendViewController alloc] init];
    [self.navigationController pushViewController:inviateFriendVC animated:YES];
}

#pragma mark - 到店签到 不在店内
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

- (void)toScanNoInStore
{
    WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
}

@end
