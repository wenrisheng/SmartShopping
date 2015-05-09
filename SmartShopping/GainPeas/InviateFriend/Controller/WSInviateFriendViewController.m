//
//  WSInviateFriendViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInviateFriendViewController.h"
#import "WSAdvertisementDetailViewController.h"

@interface WSInviateFriendViewController ()
{
     NSMutableArray *slideImageArray;
}

@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet ACImageScrollManagerView *adImageScrollManagerView;

- (IBAction)weixinButAction:(id)sender;
- (IBAction)pengyouquanButAction:(id)sender;
- (IBAction)weiboButAction:(id)sender;
- (IBAction)qqkongjianButAction:(id)sender;
- (IBAction)qqButAction:(id)sender;

@end

@implementation WSInviateFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"邀请好友";
    slideImageArray = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置用户定位位置
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    [self setLocationCity:locationDic];
    if (_city.length != 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdate:)
                                                 name:GEO_CODE_SUCCESS_NOTIFICATION object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 用户位置更新
- (void)locationUpdate:(NSNotification *)notification
{
    NSDictionary *locationDic = [notification object];
    [self setLocationCity:locationDic];
    if (slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
    if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        DLog(@"定位：%@", city);
    }
}

#pragma mark - 请求幻灯片
- (void)requestGetAdsPhoto
{
    [self.service post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeGetAdsPhoto] data:@{@"cityName": _city, @"moduleid" : @"4"} tag:WSInterfaceTypeGetAdsPhoto sucCallBack:^(id result) {
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            [slideImageArray removeAllObjects];
            NSArray *photoList = [[result objectForKey:@"data"] objectForKey:@"photoList"];
            [slideImageArray addObjectsFromArray:photoList];
            NSInteger imageCount = slideImageArray.count;
            NSMutableArray *imageDataArray = [NSMutableArray array];
            for (int i = 0; i < imageCount; i++) {
                NSDictionary *dic = [slideImageArray objectAtIndex:i];
                NSString *imageURL = [WSInterfaceUtility getImageURLWithStr:[dic objectForKey:@"pic_path"]];
                [imageDataArray addObject:imageURL];
            }
            ACImageScrollView *imageScrollView = _adImageScrollManagerView.acImageScrollView;
            [imageScrollView setImageData:imageDataArray];
            imageScrollView.callback = ^(int index) {
                DLog(@"广告：%d", index);
                NSDictionary *dic = [slideImageArray objectAtIndex:index];
                WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
                advertisementVC.url = [dic objectForKey:@"third_link"];
                [self.navigationController pushViewController:advertisementVC animated:YES];
            };
            
        }
    } failCallBack:^(id error) {
        
    }];
}


- (IBAction)weixinButAction:(id)sender {
}

- (IBAction)pengyouquanButAction:(id)sender {
}

- (IBAction)weiboButAction:(id)sender {
}

- (IBAction)qqkongjianButAction:(id)sender {
}

- (IBAction)qqButAction:(id)sender {
}
@end
