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
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation WSMineConsumeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"详情";
    
    NSString *statusFlag = [_dic stringForKey:@"giftStatus"];
    UIColor *color = nil;
    if ([statusFlag isEqualToString:@"未使用"]) {
        color = [UIColor colorWithRed:0.784 green:0.576 blue:0.000 alpha:1.000];
    } else {
        color = [UIColor colorWithRed:0.655 green:0.659 blue:0.667 alpha:1.000];
    }
    [_valueView setBorderCornerWithBorderWidth:1 borderColor:color cornerRadius:1];
    
    NSString *unit = @"¥ ";
    id value = [_dic stringForKey:@"beanNumber"];
    NSString *beanNumber = nil;
    if ([value isKindOfClass:[NSNull class]]) {
        beanNumber = @"";
    } else {
        beanNumber = value;
    }
    NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", unit, beanNumber]];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, unit.length)];
    [tempStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(unit.length, beanNumber.length)];
    _valueLabel.attributedText = tempStr;
    _valueLabel.textColor = color;
    
    _titleLabel.text = [_dic objectForKey:@"shopName"];
    _addressLabel.text = [NSString stringWithFormat:@"地址：%@", [_dic objectForKey:@"address"]];
    _numLabel.text = [_dic stringForKey:@"giftNumber"];
    
   _scanImageView.image = [QRCodeGenerator qrImageForString:[_dic stringForKey:@"giftNumber"] imageSize:_scanImageView.bounds.size.width];
    
    UIImage *bgImage = [UIImage imageNamed:@"under"];
    bgImage = [bgImage resizableImageWithModeTile];
    _bgImageView.image = bgImage;
    
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
