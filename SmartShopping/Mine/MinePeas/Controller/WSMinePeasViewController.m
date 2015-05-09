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

@interface WSMinePeasViewController ()

@property (strong, nonatomic) NSString *city;
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
    if (dataArray.count == 0) {
        if (_city.length != 0) {
            [self requestSearchGift];
        } else {
            
        }
    } else {
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        if (dataArray.count == 0) {
            [self requestSearchGift];
        }
    }
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的精明豆";
    
    // 输入框边界线
    NSArray *array = @[_upView, _leftProductView, _rightProductView, _storeSignupView, _scanProductView, _inviateFriendView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }
    // 设置用户精明豆数量
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *peaNum = nil;
    if (user) {
        peaNum = user.beanNumber;
    } else {
        int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
        peaNum = [NSString stringWithFormat:@"%d", appPeasNum];
    }
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
    _rightLabel.text = leftName;
    _rightLabel.text = leftPeaNum;
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
    giftDetailVC.giftId = [dic objectForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark 左边礼品按钮事件
- (IBAction)leftProductButAction:(id)sender
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    NSDictionary *dic = [dataArray objectAtIndex:0];
    giftDetailVC.giftId = [dic objectForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark － 到店签到按钮事件
- (IBAction)storeSignupButAction:(id)sender
{

}

#pragma mark 扫描按钮事件
- (IBAction)scanProductButAction:(id)sender
{
    
}

#pragma mark 邀请好友按钮事件
- (IBAction)inviateFriendButAction:(id)sender
{
    
}



@end
