//
//  WSMoreGiftViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/24.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSMoreGiftViewController.h"
#import "WSMoreGiftCell.h"
#import "WSGiftDetailViewController.h"

@interface WSMoreGiftViewController ()
{
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UILabel *peaLabel;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet WSTabSlideManagerView *tabSlideManagerView;

@end

@implementation WSMoreGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"奖励兑换";
    _peaLabel.text = @"－－个精明豆";
    _tabSlideManagerView.tabSlideGapTextView.normalImage = @"arrow-down";
    _tabSlideManagerView.tabSlideGapTextView.selectedImage = @"arrow-click";
    [_tabSlideManagerView.tabSlideGapTextView setDataArray:@[@"豆子范围", @"全部分类"]];
    _tabSlideManagerView.tabSlideGapTextView.callBack = ^(int index) {
        
    };
    dataArray= [[NSMutableArray alloc] init];
    [dataArray addObjectsFromArray:@[@"", @"", @"", @""]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"WSMoreGiftCell";
    WSMoreGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WSMOREGIFTCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - leftButAction
- (void)leftButAction:(UIButton *)but
{
    [self toGiftDetailVC:nil];
}

#pragma mark leftButAction
- (void)rightButAction:(UIButton *)but
{
    [self toGiftDetailVC:nil];
}

- (void)toGiftDetailVC:(id)param
{
    WSGiftDetailViewController *giftDetailVC = [[WSGiftDetailViewController alloc] init];
    giftDetailVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:giftDetailVC animated:YES];
}

@end
