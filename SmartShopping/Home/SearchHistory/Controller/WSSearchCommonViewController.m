//
//  WSSearchCommonViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/31.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchCommonViewController.h"

@interface WSSearchCommonViewController ()

@end

@implementation WSSearchCommonViewController
@synthesize productVC, storeVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    productVC = [[WSSearchProductViewController alloc]  init];
    storeVC = [[WSSearchStoreViewController alloc] init];
    NSArray *vcs = @[productVC, storeVC];
    NSInteger count = vcs.count;
    for (int i = 0; i < count; i++) {
        UIViewController *vc = [vcs objectAtIndex:i];
        UIView *view = vc.view;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        [view expandToSuperView];
        [self addChildViewController:vc];
    }
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
