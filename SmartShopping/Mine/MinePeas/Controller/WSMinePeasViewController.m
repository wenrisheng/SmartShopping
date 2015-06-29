//
//  WSMinePeasViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMinePeasViewController.h"
#import "WSGiftDetailViewController.h"
#import "WSMoreGiftViewController.h"
#import "WSNoInStoreViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSScanInStoreViewController.h"
#import "WSScanNoInStoreViewController.h"
#import "WSInviateFriendViewController.h"

@interface WSMinePeasViewController ()

@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) double longtide;
@property (assign, nonatomic) double latitude;
@property (strong, nonatomic) NSMutableArray *converDataArray;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peasLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftlabel;
@property (weak, nonatomic) IBOutlet UILabel *leftPeasNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightPeasNumLabel;
@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet UIView *leftProductView;
@property (weak, nonatomic) IBOutlet UIView *rightProductView;
@property (weak, nonatomic) IBOutlet UIView *storeSignupView;
@property (weak, nonatomic) IBOutlet UIView *scanProductView;
@property (weak, nonatomic) IBOutlet UIView *inviateFriendView;
@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;

- (IBAction)rightButAction:(id)sender;
- (IBAction)leftProductButAction:(id)sender;
- (IBAction)storeSignupButAction:(id)sender;
- (IBAction)scanProductButAction:(id)sender;
- (IBAction)inviateFriendButAction:(id)sender;
- (IBAction)moreGiftButAction:(id)sender;

@end

@implementation WSMinePeasViewController
@synthesize dataArray, converDataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
   [self setModelData];
    
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
     [self requestSearchGift];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 更新用户精明豆通知
- (void)updateUserBeanNumber:(NSNotification *)notification
{
    [super updateUserBeanNumber:notification];
    [self setBeanNumber];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        self.longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
        self.latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的精明豆";
    
    // 输入框边界线
    NSArray *array = @[_upView, _leftProductView, _rightProductView, _storeSignupView, _scanProductView, _inviateFriendView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
    [self setBeanNumber];

}

- (void)setBeanNumber
{
    // 设置用户精明豆数量
    NSString *peaNum = [WSUserUtil getUserPeasNum];
    
    NSString *str = @"个精明豆";
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", peaNum, str]];
    [tempStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.890 green:0.380 blue:0.090 alpha:1.000] range:NSMakeRange(0, peaNum.length)];
    [tempStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.204 green:0.208 blue:0.212 alpha:1.000] range:NSMakeRange(peaNum.length, str.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, peaNum.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(peaNum.length, str.length)];
    _peasLabel.attributedText = tempStr;
}

#pragma mark 请求礼物
- (void)requestSearchGift
{
    [SVProgressHUD showWithStatus:@"正在刷新……"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:_city forKey:@"cityName"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSearchGift] data:param tag:WSInterfaceTypeSearchGift sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            self.dataArray = [[result objectForKey:@"data"] objectForKey:@"giftList"];
            [self setModelData];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"刷新失败!" afterDelay:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 设置数据
- (void)setModelData
{
    _leftBut.enabled = NO;
    NSString *leftImageURL = @"";
    NSString *leftName = @"--";
    NSString *leftPeaNum = @"";
    if (dataArray.count > 0) {
        NSDictionary *firstDic = [dataArray objectAtIndex:0];
        leftImageURL = [WSInterfaceUtility getImageURLWithStr:[firstDic objectForKey:@"giftLogo"]];
        leftName = [firstDic objectForKey:@"giftName"];
        leftPeaNum = [firstDic stringForKey:@"requiredBean"];
        _leftBut.enabled = YES;
    }
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _leftlabel.text = leftName;
    _leftPeasNumLabel.text = leftPeaNum;
    
    _rightBut.enabled = NO;
    NSString *rightImageURL = @"";
    NSString *rightName = @"--";
    NSString *rightPeaNum = @"";
    if (dataArray.count > 1) {
        NSDictionary *secondDic = [dataArray objectAtIndex:1];
        rightImageURL = [WSInterfaceUtility getImageURLWithStr:[secondDic objectForKey:@"giftLogo"]];
        rightName = [secondDic objectForKey:@"giftName"];
        rightPeaNum = [secondDic stringForKey:@"requiredBean"];
        _rightBut.enabled = YES;
    }
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _rightLabel.text = rightName;
    _rightLabel.text = rightPeaNum;
}

#pragma mark - 更多礼品按钮事件 奖励兑换
- (IBAction)moreGiftButAction:(id)sender
{
    WSMoreGiftViewController *moreGiftVC = [[WSMoreGiftViewController alloc] init];
    moreGiftVC.dataArray = dataArray;
    [self.navigationController pushViewController:moreGiftVC animated:YES];
}

#pragma mark 右边礼品按钮事件
- (IBAction)rightButAction:(id)sender
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    NSDictionary *dic = [dataArray objectAtIndex:1];
    giftDetailVC.giftId = [dic stringForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark 左边礼品按钮事件
- (IBAction)leftProductButAction:(id)sender
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    NSDictionary *dic = [dataArray objectAtIndex:0];
    giftDetailVC.giftId = [dic stringForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark － 到店签到按钮事件
- (IBAction)storeSignupButAction:(id)sender
{
    //  1. GPS定位不在店内跳到 WSNoInStoreViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController
    CLBeacon *beacon = [WSRunTime sharedWSRunTime].validBeacon;
    
    [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
        BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
        // 在店内
        if (isInStore) {
            NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
            NSString *isSign = [shop stringForKey:@"isSign"];
            //  没签到
            if ([isSign isEqualToString:@"Y"]) {
                WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
                inStoreNoSignVC.shop = shop;
                [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
            } else {
                WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                storeDetailVC.shop = shop;
                [self.navigationController pushViewController:storeDetailVC animated:YES];
            }
            // 不在店内
        } else {
            WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
            [self.navigationController pushViewController:noInstoreVC animated:YES];
        }
    }];
}

#pragma mark 扫描按钮事件
- (IBAction)scanProductButAction:(id)sender
{
    // 1. 在店内跳到 WSStoreDetailViewController
    // 2. 不在店内跳到 WSScanInStoreViewController
    CLBeacon *beacon = [WSRunTime sharedWSRunTime].validBeacon;
    
    [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
        BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
        // 在店内
        if (isInStore) {
            // [WSUserUtil actionAfterLogin:^{
            NSDictionary *dic = [result objectForKey:IS_IN_SHOP_DATA];
            NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
            NSString *shopId = [dic stringForKey:@"shopId"];
            NSString *shopName = [shop objectForKey:@"shopName"];
            WSScanInStoreViewController *scanInStoreVC = [[WSScanInStoreViewController alloc] init];
            scanInStoreVC.shopName = shopName;
            scanInStoreVC.shopid = shopId;
            [self.navigationController pushViewController:scanInStoreVC animated:YES];
            // }];
            
            // 不在店内
        } else {
            WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
            [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
        }
    }];

}

#pragma mark 邀请好友按钮事件
- (IBAction)inviateFriendButAction:(id)sender
{
    WSInviateFriendViewController *inviateFriendVC = [[WSInviateFriendViewController alloc] init];
    [self.navigationController pushViewController:inviateFriendVC animated:YES];
}

#pragma mark - 到店签到 不在店内
- (void)toNoInStoreVC
{
    [WSUserUtil actionAfterLogin:^{
        WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
        [self.navigationController pushViewController:noInstoreVC animated:YES];
    }];
}

@end
