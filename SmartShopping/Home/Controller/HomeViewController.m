//
//  HomeViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () <NavigationBarButSearchButViewDelegate, SlideSwitchViewDelegate>

@property (weak, nonatomic) IBOutlet NavigationBarManagerView *navBarManagerView;
@property (weak, nonatomic) IBOutlet SlideSwitchManagerView *slideSwitchManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peasLabel;

- (IBAction)shopSignInAction:(id)sender;
- (IBAction)scanProductAction:(id)sender;
- (IBAction)invateFriendAction:(id)sender;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navBarManagerView.navigationBarButSearchButView.delegate = self;

    NSArray *slideImageArray = @[[UIImage imageNamed:@"slideswitch"], [UIImage imageNamed:@"normal"], [UIImage imageNamed:@"selected"], [UIImage imageNamed:@"normal"]];
    [_slideSwitchManagerView.slideSwitchView setImageViewArray:slideImageArray];
    _slideSwitchManagerView.slideSwitchView.delegate = self;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NavigationBarButSearchButViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    DLog(@"navigationBarLeftButClick");
}

- (void)navigationBarRightButClick:(UIButton *)but
{
     DLog(@"navigationBarRightButClick");
}

- (void)navigationBarSearchViewTextFieldDidEndEditing:(UITextField *)textField
{
     DLog(@"navigationBarSearchViewTextFieldDidEndEditing:--%@", textField.text);
}

- (BOOL)navigationBarSearchViewTextFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - SlideSwitchViewDelegate
- (void)slideSwitchViewDidSelectedIndex:(int)index
{
    DLog(@"点击了index:%d", index);
}

#pragma mark - 到店签到
- (IBAction)shopSignInAction:(id)sender
{
    DLog(@"到店签到");
}

#pragma mark 扫描产品
- (IBAction)scanProductAction:(id)sender
{
     DLog(@"扫描产品");
}

#pragma mark 邀请好友
- (IBAction)invateFriendAction:(id)sender
{
    DLog(@"邀请好友");
}
@end
