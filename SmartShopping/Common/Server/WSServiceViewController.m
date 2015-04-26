//
//  WSProjViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSServiceViewController.h"

@interface WSServiceViewController ()


@end

@implementation WSServiceViewController

- (void)dealloc
{
    _service.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化服务
- (void)initService
{
    _service = [[WSService alloc] init];
    _service.delegate = self;
}

#pragma mark - ServiceDelegate
- (void)requestSucess:(id)result tag:(int)tag
{
    
}

- (void)requestFail:(id)error tag:(int)tag
{
    
}

@end
