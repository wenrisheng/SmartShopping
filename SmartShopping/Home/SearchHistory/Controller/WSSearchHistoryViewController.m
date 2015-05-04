//
//  WSSearchHistoryViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSSearchHistoryViewController.h"
#import "WSClearHistoryCell.h"
#import "WSSearchHistoryCell.h"

#define SEARCH_HISTORY_KEY        @"SEARCH_HISTORY_KEY"
#define HISTORY_COUNT             3

@interface WSSearchHistoryViewController () <UITableViewDataSource, UITableViewDelegate, WSSearchViewDelegate>

@property (strong, nonatomic)  NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet WSSearchManagerView *searchManagerView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

- (IBAction)cancalButAction:(id)sender;

@end

@implementation WSSearchHistoryViewController
@synthesize dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithArray:[USER_DEFAULT objectForKey:SEARCH_HISTORY_KEY]];
    _searchManagerView.searchView.delegate = self;
    _searchManagerView.searchView.textField.returnKeyType = UIReturnKeySearch;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

#pragma mark - WSSearchViewDelegate
- (void)searchViewDelegateTextFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)searchViewDelegateTextFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObject:textField.text];
    NSInteger beforeCount = dataArray.count;
    for (int i = 0; i < beforeCount; i++) {
        [tempArray addObject:[dataArray objectAtIndex:i]];
    }
    NSInteger count = tempArray.count;
    if (count > HISTORY_COUNT) {
        NSInteger deleteCount = count - HISTORY_COUNT;
        for (int i = 0; i < deleteCount; i++) {
            [tempArray removeObjectAtIndex:tempArray.count - 1];
        }
    }
   [USER_DEFAULT setValue:tempArray forKey:SEARCH_HISTORY_KEY];
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = dataArray.count;
    if (count > 0) {
        return count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row == count) {
        static NSString *identify = @"WSClearHistoryCell";
        WSClearHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = GET_XIB_FIRST_OBJECT(identify);
            [cell.clearHistoryBut addTarget:self action:@selector(clearHistoryButAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    static NSString *identify = @"WSSearchHistoryCell";
    WSSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = GET_XIB_FIRST_OBJECT(identify);
    }
    cell.label.text = [dataArray objectAtIndex:row];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row == count) {
        return WSCLEARHISTORYCELL_HEIGHT;
    }
    return WSSEARCHHISTORYCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger count = dataArray.count;
    if (row != count) {
        _searchManagerView.searchView.textField.text = [dataArray objectAtIndex:row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - clearHistoryButAction
- (void)clearHistoryButAction:(UIButton *)but
{
    [USER_DEFAULT setValue:nil forKey:SEARCH_HISTORY_KEY];
    [dataArray removeAllObjects];
    [_contentTableView reloadData];
}

- (IBAction)cancalButAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
