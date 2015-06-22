//
//  WSOrderWriterViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/25.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSGiftOrderWriterViewController.h"
#import "WSOrderSucView.h"
#import "WSOrderFailView.h"

@interface WSGiftOrderWriterViewController () <UITextViewDelegate, UITextFieldDelegate>
{
    NSString *temStr1;
    NSString *temStr2;
    NSString *curNum;
    int maxNum;
    int unitNum;
    WSOrderSucView *sucView;
    WSOrderFailView *failView;
    BOOL canBuy;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *peaNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *subBut;
@property (weak, nonatomic) IBOutlet UIButton *addBut;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainPeaLabel;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UILabel *detailPlaceHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountPeaLabel;
@property (weak, nonatomic) IBOutlet UIView *addressInfoView;

- (IBAction)subButAction:(id)sender;
- (IBAction)addButAction:(id)sender;
- (IBAction)commitOrderButAction:(id)sender;

@end

@implementation WSGiftOrderWriterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    canBuy = YES;
    curNum = @"1";
    [self initView];
    NSString *giftType = [_gift stringForKey:@"giftType"];
    // 虚拟物品
    if ([giftType isEqualToString:@"2"]) {
        _addressInfoView.hidden = YES;
    }
    // 不可以减
    [self notSub];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"订单填写";
    
    [_subBut setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
    [_addBut setEnlargeEdge:20];
    
    NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[_gift objectForKey:@"logoPath"]];;
    [_productImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    _titleLabel.text = [_gift objectForKey:@"giftName"];
    
    // 礼品所需的精明豆
    unitNum = [[_gift stringForKey:@"requiredBean"] intValue];
    _peaNumLabel.text = [NSString stringWithFormat:@"%d个精明豆", unitNum];

    // 当前用户的精明豆
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    int currentPeaNum = [user.beanNumber intValue];
    
    // 精明豆足够
    if (currentPeaNum >= unitNum) {
        if (currentPeaNum >= 2 * unitNum) {
            [self canAdd];
        } else {
            [self notAdd];
        }
       
        temStr1 = @"兑换后还剩";
        temStr2 = @"个精明豆";
        maxNum = currentPeaNum / unitNum;
        NSString *remainPea = [NSString stringWithFormat:@"%d", currentPeaNum - unitNum];
        [self setRemainPeaValueWithRemainValue:remainPea];
    
    // 精明豆不够
    } else {
        canBuy = NO;
        [self notAdd];
        _remainPeaLabel.text = [NSString stringWithFormat:@"主人您的精明豆还差%d个", unitNum - currentPeaNum];
        _remainPeaLabel.textColor = [UIColor colorWithRed:0.902 green:0.376 blue:0.129 alpha:1.000];
        [self showFailView];
    }
    _totalAmountPeaLabel.text = [NSString stringWithFormat:@"%d个精明豆", unitNum];
   
    _telTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _telTextField.textAlignment = NSTextAlignmentRight;
    _addressTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _addressTextField.textAlignment = NSTextAlignmentRight;
}

#pragma mark - 设置兑换后生育精明豆富文本
- (void)setRemainPeaValueWithRemainValue:(NSString *)remianValue
{
    NSMutableAttributedString *temStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", temStr1, remianValue, temStr2]];
    
    UIColor *gray = [UIColor colorWithRed:0.651 green:0.655 blue:0.659 alpha:1.000];
    UIColor *red = [UIColor colorWithRed:0.898 green:0.380 blue:0.125 alpha:1.000];
    [temStr addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(0, temStr1.length)];
    [temStr addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(temStr1.length, remianValue.length)];
    [temStr addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(temStr1.length + remianValue.length, temStr2.length)];
    _remainPeaLabel.attributedText = temStr;
    [_numLabel setBorderCornerWithBorderWidth:0 borderColor:[UIColor colorWithRed:0.906 green:0.910 blue:0.918 alpha:1.000] cornerRadius:5];
    _numLabel.text = curNum;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    // 配送地址
    if (tag == 1) {
        [WSPickerViewUtil showChinaAreaPickerWithConfrimCallBack:^(WSChinaAreaPickerView *datePickerView) {
            textField.text = datePickerView.address;
        } cancelCallBack:^(WSChinaAreaPickerView *datePickerView) {
            
        }];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _detailPlaceHolderLabel.text = @"请输入详细地址";
    }else{
        _detailPlaceHolderLabel.text = @"";
    }
}

#pragma mark - 加减数量按钮事件
#pragma mark 减精明豆
- (IBAction)subButAction:(id)sender
{
    int curNumInt = [curNum intValue];
    int tem = curNumInt - 1;
    if (tem <= 0) {
        return;
    }
    if (tem == 1) { // 不可以减
        [self notSub];
        // 可以加
        curNumInt = tem;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    } else { // 可以减
        curNumInt--;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    }
    if (curNumInt < maxNum) {
        [self canAdd];
    } else {
        [self notAdd];
    }
    int totalConsume = [curNum intValue] * unitNum;
    _totalAmountPeaLabel.text = [NSString stringWithFormat:@"%d个精明豆", totalConsume];
    // 当前用户的精明豆
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    int currentPeaNum = [user.beanNumber intValue];
    int remainPeaNum = currentPeaNum - totalConsume;
    
    [self setRemainPeaValueWithRemainValue:[NSString stringWithFormat:@"%d", remainPeaNum]];
}

#pragma mark 加精明豆
- (IBAction)addButAction:(id)sender
{
    int curNumInt = [curNum intValue];
    int tem = curNumInt + 1;
    if (tem > maxNum) {
        [self showFailView];
        return;
    }
    int surpluscount = [[_gift stringForKey:@"surpluscount"] intValue];
    if (surpluscount <= 0) {
        
        return;
    }
    if (tem == maxNum || tem == [[_gift stringForKey:@"surpluscount"] intValue]) { // 不可以加
        [self notAdd];
        curNumInt = tem;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    } else { // 可以加
        curNumInt++;
        curNum = [NSString stringWithFormat:@"%d", curNumInt];
        _numLabel.text = curNum;
    }
    if (curNumInt >= 2) {
        [self canSub];
    } else {
          [self canSub];
    }
    int totalConsume = [curNum intValue] * unitNum;
    _totalAmountPeaLabel.text = [NSString stringWithFormat:@"%d个精明豆", totalConsume];
    // 当前用户的精明豆
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    int currentPeaNum = [user.beanNumber intValue];
    int remainPeaNum = currentPeaNum - totalConsume;

    [self setRemainPeaValueWithRemainValue:[NSString stringWithFormat:@"%d", remainPeaNum]];
}

- (void)canSub
{
    [_subBut setBackgroundImage:[UIImage imageNamed:@"left-"] forState:UIControlStateNormal];
}

- (void)notSub
{
    [_subBut setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
}

- (void)canAdd
{
    [_addBut setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
}

- (void)notAdd
{
    [_addBut setBackgroundImage:[UIImage imageNamed:@"right-"] forState:UIControlStateNormal];
}

#pragma mark - 显示精明豆不够视图
- (void)showFailView
{
    if (!failView) {
        failView = GET_XIB_FIRST_OBJECT(@"WSOrderFailView");
        [failView.confirmBut addTarget:self action:@selector(dismissFailView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:failView];
        [failView expandToSuperView];
    }
    failView.hidden = NO;
}

- (void)dismissFailView
{
    
    failView.hidden  = YES;
}

#pragma mark - 提交订单按钮事件
- (IBAction)commitOrderButAction:(id)sender
{
    if (!canBuy) {
        [SVProgressHUD showErrorWithStatus:@"亲，您的精明豆好像不够哦！" duration:TOAST_VIEW_TIME];
        return;
    }
    BOOL flag = [self validateData];
    if (flag) {
        NSString *userId = [WSRunTime sharedWSRunTime].user._id;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:[_gift objectForKey:@"id"] forKey:@"giftId"];
        [params setValue:[_gift objectForKey:@"giftType"] forKey:@"giftType"];
        [params setValue:_telTextField.text forKey:@"contactNumber"];
        [params setValue:_addressTextField.text forKey:@"deliveryAddress"];
        [params setValue:_detailAddressTextView.text forKey:@"address"];
        [params setValue:userId forKey:@"userId"];
        [params setValue:_numLabel.text forKey:@"buyNumber"];
        [SVProgressHUD showWithStatus:@"正在提交……"];
        [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeExchangeGift] data:params tag:WSInterfaceTypeExchangeGift sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            BOOL flag = [WSInterfaceUtility validRequestResult:result];
            if (flag) {
                WSUser *user = [WSRunTime sharedWSRunTime].user;
                int currentPeaNum = [user.beanNumber intValue];
                int remainPeaNum = currentPeaNum - ([curNum intValue] * unitNum);
                user.beanNumber = [NSString stringWithFormat:@"%d", remainPeaNum];
                [self commitOrderSuc];
            }
        } failCallBack:^(id error) {
            [SVProgressHUD dismissWithError:@"提交失败！" afterDelay:TOAST_VIEW_TIME];
        }];
    }
}

- (void)commitOrderSuc
{
    if (!sucView) {
        sucView = GET_XIB_FIRST_OBJECT(@"WSOrderSucView");
        [sucView.confirmBut addTarget:self action:@selector(dismissSucView) forControlEvents:UIControlEventTouchUpInside];
    }
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    int currentPeaNum = [user.beanNumber intValue];
    sucView.remainPeaLavel.text = [NSString stringWithFormat:@"您还有%d个精明豆", currentPeaNum];
    [self.view addSubview:sucView];
    [sucView expandToSuperView];
}

- (void)dismissSucView
{
    [sucView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateData
{
    float flag = YES;
    [self initView];
    NSString *giftType = [_gift stringForKey:@"giftType"];
    // 虚拟物品
    if ([giftType isEqualToString:@"2"]) {
        return YES;
    }
    if (_telTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (![WSIdentifierValidator isValidPhone:_telTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不正确！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (_addressTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入配送地址！" duration:2.0];
        flag = NO;
        return flag;
    }
    if (_detailAddressTextView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入详细地址！" duration:2.0];
        flag = NO;
        return flag;
    }

    return flag;
}

@end
