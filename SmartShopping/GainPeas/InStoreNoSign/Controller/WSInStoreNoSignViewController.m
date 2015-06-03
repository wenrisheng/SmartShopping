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
//#import "IBSDK.h"

#define SIGNUPSUC_TIME      2

@interface WSInStoreNoSignViewController ()
{
     AVAudioPlayer *player;
    //IBSDK *ibsdk;
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end

@implementation WSInStoreNoSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"到店签到";
    _addressLabel.text = [_shop objectForKey:@"shopName"];
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    [self becomeFirstResponder];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"glass" ofType:@"wav"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
//    ibsdk = [[IBSDK alloc] init];
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
//    ibsdk.UUID = uuid;
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
            beanNum += 100;
            user.beanNumber = [NSString stringWithFormat:@"%d", beanNum];
            
            //同步数据库精明豆
            [self synchronUserPea];
            
            // 签到成功
             [self showSignupSucView];
        }
    } failCallBack:^(id error) {
        
    } showMessage:YES];

}

- (void)synchronUserPea
{

    WSUser *user = [WSRunTime sharedWSRunTime].user;
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber":user.beanNumber} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
        [SVProgressHUD dismiss];

    } failCallBack:^(id error) {
    

    }];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    [player play];
//    [ibsdk startLocation];
//   timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(listenIBSDK) userInfo:nil repeats:YES];
    [self requestEarnSignBean];
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionCancelled:motion withEvent:event];
    //摇动取消
}

- (void)listenIBSDK
{
//    NSArray *ibeaconArray = ibsdk.beaconsArray;
//    if (ibeaconArray.count != 0) {
//        [timer invalidate];
//        for (id becon in ibeaconArray) {
//            DLog(@"becon:%@", becon);
//        }
//    }
}


- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    [super motionEnded:motion withEvent:event];
    //摇动结束
    
    if (event.subtype == UIEventSubtypeMotionShake) {
       
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
    storeDetailVC.shop = _shop;
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
