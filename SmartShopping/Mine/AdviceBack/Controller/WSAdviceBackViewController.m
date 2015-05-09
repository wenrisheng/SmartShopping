//
//  WSAdviceBackViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSAdviceBackViewController.h"

@interface WSAdviceBackViewController ()

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *holderLabel;
@property (weak, nonatomic) IBOutlet UIButton *commitBut;

- (IBAction)commitButAction:(id)sender;

@end

@implementation WSAdviceBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"意见反馈";
    [_textView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.765 green:0.769 blue:0.773 alpha:1.000] cornerRadius:5];
    [_commitBut setBorderCornerWithBorderWidth:1 borderColor:[UIColor clearColor] cornerRadius:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _holderLabel.text = @"亲，您在使用过程中遇到的任何问题或者对我们的产品有任何建议都可以反馈给我们哟！";
    }else{
        _holderLabel.text = @"";
    }
}

- (IBAction)commitButAction:(id)sender
{
    if (_textView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入您的宝贵意见！" duration:TOAST_VIEW_TIME];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在反馈……"];
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeFeedBack] data:@{@"userId": userId, @"content": _textView.text} tag:WSInterfaceTypeFeedBack sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [SVProgressHUD showSuccessWithStatus:@"反馈成功！" duration:TOAST_VIEW_TIME];
            [NSTimer scheduledTimerWithTimeInterval:TOAST_VIEW_TIME target:self selector:@selector(popVC) userInfo:nil repeats:NO];
        }
    } failCallBack:^(id error) {
        [SVProgressHUD dismissWithError:@"反馈失败！" afterDelay:TOAST_VIEW_TIME];
    }];
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
