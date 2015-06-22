//
//  WSInviateFriendViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/28.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInviateFriendViewController.h"
#import "WSAdvertisementDetailViewController.h"

#define BOTTOMVIEW_HEIGHT 285

@interface WSInviateFriendViewController ()
{
     NSMutableArray *slideImageArray;
}
@property (weak, nonatomic) IBOutlet UIScrollView *contntScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acimageHeightCon;
@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet UILabel *inviateCodeLabel;
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
    NSString *inviateCode = [WSRunTime sharedWSRunTime].user.inviteCode;
    _inviateCodeLabel.text = inviateCode;
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
    if (_city.length > 0 && slideImageArray.count == 0) {
        [self requestGetAdsPhoto];
    }
}

- (void)setLocationCity:(NSDictionary *)locationDic
{
    //int deoCodeFalg = [[locationDic objectForKey:DEO_CODE_FLAG] intValue];
   // if (deoCodeFalg == 0) {
        NSString *city = [locationDic objectForKey:LOCATION_CITY];
        self.city = city;
        DLog(@"定位：%@", city);
   // }
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
             __weak ACImageScrollView *weekImageScrollView = imageScrollView;
            imageScrollView.downloadImageFinish = ^(NSInteger index, UIImage *image) {
                float width = weekImageScrollView.bounds.size.width;
                float height = width * image.size.height / image.size.width;
                _acimageHeightCon.constant = height;
                CGSize size = _contntScrollView.contentSize;
                size.height = height + BOTTOMVIEW_HEIGHT;
             
                _contntScrollView.contentSize = size;
            };
            imageScrollView.callback = ^(int index) {
                DLog(@"广告：%d", index);
                NSDictionary *dic = [slideImageArray objectAtIndex:index];
                WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
                advertisementVC.dic = dic;
                [self.navigationController pushViewController:advertisementVC animated:YES];
            };
            
        }
    } failCallBack:^(id error) {
        
    }];
}


- (IBAction)weixinButAction:(id)sender
{
    [self inviateFriendWithType:ShareTypeWeixiSession];
}

- (IBAction)pengyouquanButAction:(id)sender
{
      [self inviateFriendWithType:ShareTypeWeixiTimeline];
}

- (IBAction)weiboButAction:(id)sender
{
      [self inviateFriendWithType:ShareTypeSinaWeibo];
}

- (IBAction)qqkongjianButAction:(id)sender
{
      [self inviateFriendWithType:ShareTypeQQSpace];
}

- (IBAction)qqButAction:(id)sender
{
      [self inviateFriendWithType:ShareTypeQQ];
}

- (void)inviateFriendWithType:(ShareType)shareType
{
    NSString *title = @"亲，快来下载精明购";
    NSString *content = [NSString stringWithFormat:@"好友邀请码：%@", [WSRunTime sharedWSRunTime].user.inviteCode];
    NSString *appURL = APP_URL;
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:title
                                                  url:appURL
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:shareType
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"邀请成功!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                     [alert show];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"邀请失败!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                     [alert show];
                                 }
                             }];

}

@end
