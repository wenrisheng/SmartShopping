//
//  WSMineConsumeDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMineConsumeDetailViewController.h"

@interface WSMineConsumeDetailViewController ()
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScorllView;
@property (weak, nonatomic) IBOutlet UIView *valueView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@end

@implementation WSMineConsumeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"详情";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
