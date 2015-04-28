//
//  WSInviateFriendViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInviateFriendViewController.h"

@interface WSInviateFriendViewController ()
{
     NSMutableArray *slideImageArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *adImageScrollManagerView;

- (IBAction)weixinButAction:(id)sender;
- (IBAction)pengyouquanButAction:(id)sender;
- (IBAction)weiboButAction:(id)sender;
- (IBAction)qqkongjianButAction:(id)sender;
- (IBAction)qqButAction:(id)sender;

@end

@implementation WSInviateFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"邀请好友";
    slideImageArray = [[NSMutableArray alloc] init];
    [self addTestData];
    ACImageScrollView *imageScrollView = _adImageScrollManagerView.acImageScrollView;
    [imageScrollView setImageData:slideImageArray];
    imageScrollView.callback = ^(int index) {
        
    };

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 测试数据
- (void)addTestData
{
    
    [slideImageArray addObjectsFromArray: @[@"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg"]];
}
- (IBAction)weixinButAction:(id)sender {
}

- (IBAction)pengyouquanButAction:(id)sender {
}

- (IBAction)weiboButAction:(id)sender {
}

- (IBAction)qqkongjianButAction:(id)sender {
}

- (IBAction)qqButAction:(id)sender {
}
@end
