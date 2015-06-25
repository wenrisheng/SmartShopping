//
//  WSScanProductViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSScanProductViewController.h"
#import "ZBarSDK.h"
#import "WSScanAfterViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WSScanProductViewController () <ZBarReaderViewDelegate>
{
    int num;
    BOOL isUp;
    NSTimer * timer;
    AVAudioPlayer *player;
    BOOL lampOn;

}

@property (strong, nonatomic) NSString *scanStr;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet UIImageView *tiaoImageView;
@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)lampButAction:(id)sender;

- (IBAction)shanButAction:(id)sender;

@end

@implementation WSScanProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"扫描产品";
    _readerView.readerDelegate = self;
    _readerView.allowsPinchZoom = NO;
    lampOn = NO;
    //闪光灯
     _readerView.torchMode = 0;
    _readerView.scanCrop = [self getScanCrop:_readerView.bounds readerViewBounds:self.readerView.bounds];
    _readerView.trackingColor = [UIColor clearColor];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];

    
    [_textField setBorderCornerWithBorderWidth:0 borderColor:[UIColor clearColor] cornerRadius:_textField.bounds.size.height * 0.5];
    UIView *leftView = [[UIView alloc] init];
    leftView.frame = CGRectMake(0, 0, 10, 50);
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    _textField.leftView = leftView;
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = _readerView;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shake_match" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
   player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_readerView start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    _readerView.readerDelegate = nil;
    [_readerView stop];
}

-(void)animation
{
    CGRect rect = _tiaoImageView.frame;
    CGRect supRect = _tiaoImageView.superview.frame;
    if (isUp == NO) {
        rect.origin.y ++;
        _tiaoImageView.frame = rect;
        if ((rect.origin.y + rect.size.height) >= supRect.size.height) {
            isUp = YES;
        }
    } else {
        rect.origin.y --;
        _tiaoImageView.frame = rect;
        if (rect.origin.y <= 0) {
            isUp = NO;
        }
    }
}

#pragma mark - ZBarReaderViewDelegate
- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    NSString *str = nil;
    for (ZBarSymbol *symbol in symbols) {
        DLog(@"%@", symbol.data);
        str=symbol.data;
        break;
    }
    [player play];
    [_readerView stop];
    [timer invalidate];
    self.scanStr = str;
    CLBeacon *beacon = [WSRunTime sharedWSRunTime].validBeacon;
            [WSProjUtil isInShopAndIsScanWithIBeacon:beacon callback:^(id result) {
                NSDictionary *isInShopDic = [result objectForKey:IS_IN_SHOP_DATA];
                BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
                if (isInStore) {
                    NSString *isScan = [isInShopDic stringForKey:@"isScan"];
                    if ([isScan isEqualToString:@"Y"]) {
                        [self requestEarnBeanByScanGoodsWithBarcode:str];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"亲，您不满足扫描条件哦！" duration:TOAST_VIEW_TIME];
                        double delayInSeconds = TOAST_VIEW_TIME;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self.navigationController popViewControllerAnimated:YES];
                        });

                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"亲，您没在%@店哦！", [isInShopDic objectForKey:@"shopName"]] duration:TOAST_VIEW_TIME];
                    double delayInSeconds = TOAST_VIEW_TIME;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.navigationController popViewControllerAnimated:YES];
                    });

                }
            }];
    
}

- (void) readerViewDidStart: (ZBarReaderView*) readerView
{
    
}

- (void) readerView: (ZBarReaderView*) readerView
   didStopWithError: (NSError*) error
{
   
}

- (void)requestEarnBeanByScanGoodsWithBarcode:(NSString *)barcode
{
    barcode = barcode == nil ? @"" : barcode;
    _shopid = _shopid.length == 0 ? @"" : _shopid;
    NSString *userId = [WSRunTime sharedWSRunTime].user._id;
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeEarnBeanByScanGoods] data:@{@"uid": userId, @"barcode": barcode, @"shopid": _shopid} tag:WSInterfaceTypeEarnBeanByScanGoods sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
            if (_scanSucCallBack) {
               NSDictionary *data = [result objectForKey:@"data"];
                _scanSucCallBack(data);
            }
        } else {
             [_readerView start];
            timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
        }
    } failCallBack:^(id error) {
        [_readerView start];
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    } showMessage:YES];
}

- (IBAction)lampButAction:(id)sender {
    if (lampOn) {
        //闪光灯
        _readerView.torchMode = 0;
        lampOn = !lampOn;
    } else {
        //闪光灯
        _readerView.torchMode = 1;
        lampOn = !lampOn;

    }
}

- (IBAction)shanButAction:(id)sender
{
    [_textField resignFirstResponder];
    NSString *barcode = _textField.text;
    if (barcode.length > 0) {
        [self requestEarnBeanByScanGoodsWithBarcode:barcode];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请输入条形码！" duration:TOAST_VIEW_TIME];
    }
}


-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;
    
    return CGRectMake(x, y, width, height);
}

@end
