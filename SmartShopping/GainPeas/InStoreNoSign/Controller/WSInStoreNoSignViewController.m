//
//  WSInStoreNoSignViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInStoreNoSignViewController.h"
#import "WSSignupSucView.h"
#import "WSStoreDetailViewController.h"

#define SIGNUPSUC_TIME      2

@interface WSInStoreNoSignViewController ()

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end

@implementation WSInStoreNoSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"到店签到";
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionCancelled:motion withEvent:event];
    //摇动取消
}



- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    [super motionEnded:motion withEvent:event];
    //摇动结束
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        [self showSignupSucView];
    }
    
}

- (void)showSignupSucView
{
    WSSignupSucView *sucView = [WSSignupSucView getView];
    [self.view addSubview:sucView];
    [sucView expandToSuperView];
    [NSTimer scheduledTimerWithTimeInterval:SIGNUPSUC_TIME target:self selector:@selector(dismissSucView:) userInfo:nil repeats:NO];
}

- (void)dismissSucView:(NSTimer *)timer
{
    [self.navigationController popViewControllerAnimated:YES];
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
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
