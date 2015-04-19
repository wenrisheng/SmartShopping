//
//  WSMinePeasViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/19.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMinePeasViewController.h"

@interface WSMinePeasViewController ()

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peasLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreGiftButAction;
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

- (IBAction)rightButAction:(id)sender;
- (IBAction)leftProductButAction:(id)sender;
- (IBAction)storeSignupButAction:(id)sender;
- (IBAction)scanProductButAction:(id)sender;
- (IBAction)inviateFriendButAction:(id)sender;

@end

@implementation WSMinePeasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"我的精明豆";
    
    // 输入框边界线
    NSArray *array = @[_upView, _leftProductView, _rightProductView, _storeSignupView, _scanProductView, _inviateFriendView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    }

}

- (IBAction)rightButAction:(id)sender {
}

- (IBAction)leftProductButAction:(id)sender {
}
- (IBAction)storeSignupButAction:(id)sender {
}

- (IBAction)scanProductButAction:(id)sender {
}

- (IBAction)inviateFriendButAction:(id)sender {
}
@end
