//
//  MineViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineViewController.h"
#import "WSMineFirstCell.h"
#import "WSMineSecondCell.h"
#import "WSMineThirdCell.h"
#import "WSMineFourCell.h"
#import "WSLoginViewController.h"
#import "WSMineInfoViewController.h"
#import "WSLoginedView.h"
#import "WSNoLoginView.h"
#import "WSMinePeasViewController.h"
#import "WSMineConverViewController.h"
#import "WSMineCollectViewController.h"
#import "WSMineConsumeViewController.h"
#import "WSLogoutCell.h"
#import "WSMoreGiftViewController.h"
#import "WSGiftDetailViewController.h"
#import "WSUpdateTelViewController.h"
#import "WSResetPasswordViewController.h"
#import "WSAboutViewController.h"
#import "WSAdviceBackViewController.h"
#import "ASIFormDataRequest.h"
#import <ShareSDK/ShareSDK.h>

@interface WSMineViewController () <UITableViewDataSource, UITableViewDelegate, WSMineFirstCellDelegate, UIAlertViewDelegate>
{
    WSMineFirstCell *firstCell;
    WSLoginedView *loginedView;
    WSNoLoginView *noLoginView;
}

@property (strong, nonatomic) NSArray *giftList;
@property (strong, nonatomic) NSString *appURL;
@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation WSMineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    
    [self setLoginStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
    [self requestSearchGift];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestSearchGift
{
#ifdef DEBUG
    
    self.city = @"广州";
#endif
    if (_city.length == 0) {
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在刷新……"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:_city forKey:@"cityName"];
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSearchGift] data:param tag:WSInterfaceTypeSearchGift sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
         BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            self.giftList = [[result objectForKey:@"data"] objectForKey:@"giftList"];
            [_contentTableView reloadData];
        }
    } failCallBack:^(id error) {
         [SVProgressHUD dismissWithError:@"刷新失败!" afterDelay:TOAST_VIEW_TIME];
    }];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
//    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
//    if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        if (_giftList.count == 0) {
            [self requestSearchGift];
        }
//    }
}

#pragma mark - 更新用户有没有登陆视图
- (void)setLoginStatus
{
    if (firstCell) {
        UIView *loginStatusView = firstCell.loginStatusView;
        if (loginStatusView) {
            WSUser *user = [WSRunTime sharedWSRunTime].user;
            [loginStatusView clearSubviews];
            if (user) {
                if (!loginedView) {
                    loginedView = [WSLoginedView getView];
                    [loginedView.rightBut addTarget:self action:@selector(loginedRightButAction:) forControlEvents:UIControlEventTouchUpInside];
                    [loginedView.rightBut setEnlargeEdgeWithTop:20 right:20 bottom:20 left:50];
                }
                if (user.logoPath.length > 0) {
                    loginedView.loginedHeadImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.logoPath]]];
                }
                loginedView.nickNameLabel.text = user.nickname.length == 0 ? @"你还没有设置昵称哦！" : user.nickname;
                loginedView.telLabel.text = user.phone;
                [loginStatusView addSubview:loginedView];
                [loginedView expandToSuperView];

                firstCell.peaNumLabel.text = [NSString stringWithFormat:@"%@豆", user.beanNumber];
                
            } else {
                if (!noLoginView) {
                    noLoginView = [WSNoLoginView getView];
                    [noLoginView.logigImmediately addTarget:self action:@selector(loginImmediateButAction:) forControlEvents:UIControlEventTouchUpInside];
                }
                [loginStatusView addSubview:noLoginView];
                [noLoginView expandToSuperView];
                int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
                firstCell.peaNumLabel.text = [NSString stringWithFormat:@"%d豆", appPeasNum];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        return 6;
    } else {
       return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch (row) {
        // 头部 头像、我的精明豆
        case 0:
        {
            static NSString *identify = @"WSMineFirstCell";
            firstCell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!firstCell) {
                firstCell = [WSMineFirstCell getCell];
                firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
                firstCell.delegate = self;
            }
            [self setLoginStatus];
            return firstCell;
        }
            break;
        // 奖励兑换
        case 1:
        {
            static NSString *identify = @"WSMineSecondCell";
            WSMineSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = [WSMineSecondCell getCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.moreBut addTarget:self action:@selector(moreGiftButAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.leftBut addTarget:self action:@selector(giftLeftButAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.rightBut addTarget:self action:@selector(giftRightButAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.leftBut.enabled = NO;
            NSString *leftImageURL = @"";
            NSString *leftName = @"--";
            NSString *leftPeaNum = @"";
            if (_giftList.count > 0) {
                NSDictionary *firstDic = [_giftList objectAtIndex:0];
                leftImageURL = [WSInterfaceUtility getImageURLWithStr:[firstDic objectForKey:@"giftLogo"]];
                leftName = [firstDic objectForKey:@"giftName"];
                leftPeaNum = [firstDic stringForKey:@"requiredBean"];
                cell.leftBut.enabled = YES;
            }
            [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
            cell.leftLabel.text = leftName;
            cell.leftPeasLabel.text = leftPeaNum;
            
            cell.rightBut.enabled = NO;
            NSString *rightImageURL = @"";
            NSString *rightName = @"--";
            NSString *rightPeaNum = @"";
            if (_giftList.count > 1) {
                NSDictionary *secondDic = [_giftList objectAtIndex:1];
                rightImageURL = [WSInterfaceUtility getImageURLWithStr:[secondDic objectForKey:@"giftLogo"]];
                rightName = [secondDic objectForKey:@"giftName"];
                rightPeaNum = [secondDic stringForKey:@"requiredBean"];
                cell.rightBut.enabled = YES;
            }
            [cell.rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
            cell.rightLabel.text = leftName;
            cell.rightPeasLabel.text = leftPeaNum;
            
            return cell;
        }
            break;
        // 更换手机号、密码修改
        case 2:
        {
            static NSString *identify = @"WSMineThirdCell";
            WSMineThirdCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = [WSMineThirdCell getCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.upImageView.image = [UIImage imageNamed:@"01"];
            cell.downImageView.image = [UIImage imageNamed:@"02"];
            cell.upLabel.text = @"更换手机号";
            cell.downLabel.text = @"密码修改";
            [cell.upBut addTarget:self action:@selector(changeTelButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.downBut addTarget:self action:@selector(changePasswordButAction:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
            break;
        // 关于、意见反馈
        case 3:
        {
            static NSString *identify = @"WSMineThirdCell";
            WSMineThirdCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = [WSMineThirdCell getCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.upImageView.image = [UIImage imageNamed:@"03"];
            cell.downImageView.image = [UIImage imageNamed:@"04"];
            cell.upLabel.text = @"关于";
            cell.downLabel.text = @"意见反馈";
            [cell.upBut addTarget:self action:@selector(aboutButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.downBut addTarget:self action:@selector(adviceGiveButAction:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
            break;
        // 推送设置、清除缓存、检查更新
        case 4:
        {
            static NSString *identify = @"WSMineFourCell";
            WSMineFourCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = [WSMineFourCell getCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.firstImageView.image = [UIImage imageNamed:@"05"];
                cell.secondImageView.image = [UIImage imageNamed:@"06"];
                cell.thirdImageView.image = [UIImage imageNamed:@"07"];
                cell.firstLabel.text = @"推送通知";
                cell.secondLabel.text = @"清除缓存";
                cell.thirdLabel.text = @"检查更新";
                [cell.pushSettingSwitch addTarget:self action:@selector(pushSettingSwitchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.clearCacheBut addTarget:self action:@selector(clearCacheButAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.chectUpdateBut addTarget:self action:@selector(checkUpdateButAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            BOOL isPush = [WSRunTime sharedWSRunTime].user.isPushNotification;
            if (isPush) {
                [cell.pushSettingSwitch setOn:YES animated:YES];
            } else {
                [cell.pushSettingSwitch setOn:NO animated:YES];
            }
            return cell;
        }
            break;
        case 5:
        {
            static NSString *identify = @"WSLogoutCell";
            WSLogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (!cell) {
                cell = GET_XIB_FIRST_OBJECT(identify);
                [cell.logoutBut addTarget:self action:@selector(logoutButAction) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
        {
            return WSMINEFIRSTCELL_HEIGHT;
        }
            break;
        case 1:
        {
            return WSMINESECONDCELL_HEIGHT;
        }
            break;
        case 2:
        {
            return WSMINETHIRDCELL_HEIGHT;
        }
            break;
        case 3:
        {
            return WSMINETHIRDCELL_HEIGHT;
        }
            break;
        case 4:
        {
            return WSMINEFOURCELL_HEIGHT;
        }
            break;
        case 5:
        {
            return WSLOGOUTCELL_HEIGHT;
        }
            break;
        default:
            break;
    }
    return 0;
}

#pragma mark - 注销按钮事件
- (void)logoutButAction
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    switch (user.loginType) {
        case UserLoginTypePhone:
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_KEY];
            [WSRunTime sharedWSRunTime].user = nil;
            
        }
            break;
        case UserLoginTypeWechat:
        {
            [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
        }
            break;
        case UserLoginTypeWeibo:
        {
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
        }
            break;
        case UserLoginTypeQQ:
        {
           [ShareSDK cancelAuthWithType:ShareTypeQQ]; 
        }
            break;
        default:
            break;
    }
    [WSRunTime sharedWSRunTime].user = nil;
}

#pragma mark - WSMineFirstCellDelegate
#pragma mark 已经登录右边按钮事件
- (void)loginedRightButAction:(UIButton *)but
{
    WSMineInfoViewController *mineInfoVC = [[WSMineInfoViewController alloc] init];
    [self.navigationController pushViewController:mineInfoVC animated:YES];
}

#pragma mark 马上登录按钮事件
- (void)loginImmediateButAction:(UIButton *)but
{
    [WSUserUtil actionAfterLogin:^{
        
    }];
}

#pragma mark 我的精明豆按钮事件
- (void)mineFirstCellMinePeasButAction:(UIButton *)but
{
    WSMinePeasViewController *minePeasVC = [[WSMinePeasViewController alloc] init];
    minePeasVC.dataArray = [NSMutableArray arrayWithArray:_giftList];
    [self.navigationController pushViewController:minePeasVC animated:YES];
}

#pragma mark 我的兑换按钮事件
- (void)mineFirstCellMineConverButAction:(UIButton *)but
{
    [WSUserUtil actionAfterLogin:^{
        WSMineConverViewController *mineConverVC = [[WSMineConverViewController alloc] init];
        [self.navigationController pushViewController:mineConverVC animated:YES];
    }];
}

#pragma mark 我的消费卷按钮事件
- (void)mineFirstCellMineConsumeButAction:(UIButton *)but
{
    [WSUserUtil actionAfterLogin:^{
        WSMineConsumeViewController *mineConsumeVC = [[WSMineConsumeViewController alloc] init];
        [self.navigationController pushViewController:mineConsumeVC animated:YES];
    }];
}

#pragma mark 我的收藏按钮事件
- (void)mineFirstCellMineCollectButAction:(UIButton *)but
{
    [WSUserUtil actionAfterLogin:^{
        WSMineCollectViewController *mineCollectVC = [[WSMineCollectViewController alloc] init];
        [self.navigationController pushViewController:mineCollectVC animated:YES];
    }];
}

#pragma mark - 更多礼品按钮事件
- (void)moreGiftButAction:(UIButton *)but
{
    WSMoreGiftViewController *moreGiftVC = [[WSMoreGiftViewController alloc] init];
    if (_giftList) {
        NSMutableArray *temArray = [NSMutableArray arrayWithArray:_giftList];
        moreGiftVC.dataArray = temArray;
    }
    [self.navigationController pushViewController:moreGiftVC animated:YES];
}

#pragma mark  礼品兑换左边礼品按钮事件
- (void)giftLeftButAction:(UIButton *)but
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    NSDictionary *dic = [_giftList objectAtIndex:0];
    giftDetailVC.giftId = [dic objectForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark 礼品兑换右边礼品按钮事件
- (void)giftRightButAction:(UIButton *)but
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    NSDictionary *dic = [_giftList objectAtIndex:1];
    giftDetailVC.giftId = [dic objectForKey:@"giftId"];
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

#pragma mark 更换手机号按钮事件
- (void)changeTelButAction:(UIButton *)but
{
     [WSUserUtil actionAfterLogin:^{
        WSUpdateTelViewController *updateTelVC = [[WSUpdateTelViewController alloc] init];
        [self.navigationController pushViewController:updateTelVC animated:YES];
     }];
}

#pragma mark 密码修改按钮事件
- (void)changePasswordButAction:(UIButton *)but
{
     [WSUserUtil actionAfterLogin:^{
        WSResetPasswordViewController *resetPasswordVC = [[WSResetPasswordViewController alloc] init];
        [self.navigationController pushViewController:resetPasswordVC animated:YES];
     }];
}

#pragma mark 关于按钮事件
- (void)aboutButAction:(UIButton *)but
{
    WSAboutViewController *aboutVC = [[WSAboutViewController alloc] init];
    aboutVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:aboutVC animated:YES];
}

#pragma mark 意见反馈按钮事件
- (void)adviceGiveButAction:(UIButton *)but
{
     [WSUserUtil actionAfterLogin:^{
        WSAdviceBackViewController *adviceBackVC = [[WSAdviceBackViewController alloc] init];
        [self.navigationController pushViewController:adviceBackVC animated:YES];
     }];
}

#pragma mark 推送设置按钮事件
- (void)pushSettingSwitchAction:(UISwitch *)pushSwitch
{
    BOOL isPush = pushSwitch.on;
    [WSRunTime sharedWSRunTime].user.isPushNotification = isPush;
}

#pragma mark 清除缓存按钮事件
- (void)clearCacheButAction:(UIButton *)but
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要清除缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    [alert show];
}

#pragma mark 检查更新按钮事件
- (void)checkUpdateButAction:(UIButton *)but
{
    [SVProgressHUD showWithStatus:@"检查更新中……"];
    NSURL *url = [NSURL URLWithString:APP_URL];
   __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSData *responseData = [request responseData];
         NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *infoArray = [jsonData objectForKey:@"results"];
        if ([infoArray count]) {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            NSString *latestVersion = [releaseInfo objectForKey:@"version"];
            float latesVersionInt = [latestVersion floatValue];
            float currentVersionInt = [APP_VERSION floatValue];
            if (latesVersionInt > currentVersionInt) {
                self.appURL = [releaseInfo objectForKey:@"trackViewUrl"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                alert.tag = 100;
                [alert show];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"当前已是最新版本！" duration:TOAST_VIEW_TIME];
            }
           
        } else {
             [SVProgressHUD showErrorWithStatus:@"检查更新失败！" duration:TOAST_VIEW_TIME];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"检查更新失败！" duration:TOAST_VIEW_TIME];
    }];
    [request startAsynchronous];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    // 更新应用
    if (tag == 100) {
        if (buttonIndex==1) {
            NSURL *url = [NSURL URLWithString:self.appURL];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
    // 清除缓存
    if (tag == 101) {
        if (buttonIndex == 1) {
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [SVProgressHUD showSuccessWithStatus:@"缓存已清除完！" duration:TOAST_VIEW_TIME];
            }];
            
        }
    }
}

@end
