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
#import <AVFoundation/AVFoundation.h>
#import "IBSDK.h"



@interface WSInStoreNoSignViewController ()
{
    AVAudioPlayer *player;
}

@property (strong, nonatomic) IBSDK *ibeacon;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end

@implementation WSInStoreNoSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"到店签到";
    _addressLabel.text = [_shop objectForKey:@"shopName"];
    _titleLabel.text = [NSString stringWithFormat:@"摇一摇签到，马上赚取%@精明豆", [_shop stringForKey:@"beannumber"]];
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    [self becomeFirstResponder];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shake_sound_male" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestEarnSignBean
{
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    NSString *shopid = [_shop stringForKey:@"shopId"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeEarnSignBean] data:@{@"uid": userId, @"shopid": shopid} tag:WSInterfaceTypeEarnSignBean sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            WSUser *user = [WSRunTime sharedWSRunTime].user;
            int beanNum = [user.beanNumber intValue];
            beanNum += [[_shop stringForKey:@"beannumber"] intValue];
            user.beanNumber = [NSString stringWithFormat:@"%d", beanNum];
            
            NSString *beannumber = [_shop stringForKey:@"beannumber"];
            beannumber = beannumber.length > 0 ? beannumber : @"0";
            [WSProjUtil showGainBeanNumWithBeanNum:beannumber callback:^{
                [self.navigationController popViewControllerAnimated:NO];
                WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                storeDetailVC.shop = _shop;
                [self.navigationController pushViewController:storeDetailVC animated:YES];
            }];
        }
    } failCallBack:^(id error) {
        
    } showMessage:YES];

}

- (void)synchronUserPea
{
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber": @"100"} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
        [SVProgressHUD dismiss];

    } failCallBack:^(id error) {
    

    }];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    [player play];
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
        [self requestEarnSignBean];
    }
    
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
