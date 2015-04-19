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

@interface WSMineViewController () <UITableViewDataSource, UITableViewDelegate, WSMineFirstCellDelegate>
{
    WSMineFirstCell *firstCell;
    WSLoginedView *loginedView;
    WSNoLoginView *noLoginView;
}


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
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self setLoginStatus];
}

- (void)setLoginStatus
{
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
            [loginStatusView addSubview:loginedView];
            [loginedView expandToSuperView];
            
        } else {
            if (!noLoginView) {
                noLoginView = [WSNoLoginView getView];
                [noLoginView.logigImmediately addTarget:self action:@selector(loginImmediateButAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            [loginStatusView addSubview:noLoginView];
            [noLoginView expandToSuperView];
            
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
            }
            firstCell.delegate = self;
           // [self setLoginStatus];
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
            }
            [cell.moreBut addTarget:self action:@selector(moreGiftButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.leftBut addTarget:self action:@selector(giftLeftButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.leftBut addTarget:self action:@selector(giftRightButAction:) forControlEvents:UIControlEventTouchUpInside];
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
            }
            cell.firstImageView.image = [UIImage imageNamed:@"05"];
            cell.secondImageView.image = [UIImage imageNamed:@"06"];
            cell.thirdImageView.image = [UIImage imageNamed:@"07"];
            cell.firstLabel.text = @"推送通知";
            cell.secondLabel.text = @"清除缓存";
            cell.thirdLabel.text = @"检查更新";
            [cell.pushSettingSwitch addTarget:self action:@selector(pushSettingSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [cell.clearCacheBut addTarget:self action:@selector(clearCacheButAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.chectUpdateBut addTarget:self action:@selector(checkUpdateButAction:) forControlEvents:UIControlEventTouchUpInside];
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
        default:
            break;
    }
    return 0;
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
    WSLoginViewController *loginVC = [[WSLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma mark 我的精明豆按钮事件
- (void)mineFirstCellMinePeasButAction:(UIButton *)but
{
    WSMinePeasViewController *minePeasVC = [[WSMinePeasViewController alloc] init];
    [self.navigationController pushViewController:minePeasVC animated:YES];
}

#pragma mark 我的兑换按钮事件
- (void)mineFirstCellMineConverButAction:(UIButton *)but
{
    
}

#pragma mark 我的消费卷按钮事件
- (void)mineFirstCellMineConsumeButAction:(UIButton *)but
{
    
}

#pragma mark 我的收藏按钮事件
- (void)mineFirstCellMineCollectButAction:(UIButton *)but
{
    
}

#pragma mark - 更多礼品按钮事件
- (void)moreGiftButAction:(UIButton *)but
{
    
}

#pragma mark  更多礼品左边按钮事件
- (void)giftLeftButAction:(UIButton *)but
{
    
}

#pragma mark 更多礼品右边按钮事件
- (void)giftRightButAction:(UIButton *)but
{
    
}

#pragma mark 更换手机号按钮事件
- (void)changeTelButAction:(UIButton *)but
{
    
}

#pragma mark 密码修改按钮事件
- (void)changePasswordButAction:(UIButton *)but
{
    
}

#pragma mark 关于按钮事件
- (void)aboutButAction:(UIButton *)but
{
    
}

#pragma mark 意见反馈按钮事件
- (void)adviceGiveButAction:(UIButton *)but
{
    
}

#pragma mark 推送设置按钮事件
- (void)pushSettingSwitchAction:(UIButton *)but
{
    
}

#pragma mark 清除缓存按钮事件
- (void)clearCacheButAction:(UIButton *)but
{
    
}

#pragma mark 检查更新按钮事件
- (void)checkUpdateButAction:(UIButton *)but
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
