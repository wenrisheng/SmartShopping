//
//  AppDelegate.m
//  SmartShopping
//
//  Created by wrs on 15/4/7.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "AppDelegate.h"
#import "WSHomeViewController.h"
#import "WSPromotionCouponViewController.h"
#import "WSGainPeasViewController.h"
#import "WSMineViewController.h"
#import <Parse/Parse.h>
#import "WSGuideViewController.h"

#define APP_NOT_FIRST_OPEN         @"APP_NOT_FIRST_OPEN"
#define APP_DAY_PEA                @"APP_DAY_PEA"
#define APP_DAY_PEA_IS_GET         @"APP_DAY_PEA_IS_GET"
#define APP_DAY_PEA_IS_GET_DAY     @"APP_DAY_PEA_IS_GET_DAY"

#define APP_GUIDE                  @"APP_GUIDE"

//#import "IBSDK.h"

@interface AppDelegate () <BMKGeneralDelegate>
{
     BMKMapManager* _mapManager;
//    IBSDK *ibsdk;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor clearColor];

    // 同步用户信息与精明豆
    [self synchronUserDataAndPeaNum];
    
    // 百度地图
    [self initBMK];
    
    // ShareSDK
    [self initShareSDK];
    
    // 首页
    [self initTabbarViewController];
    
    // 引导页
    NSNumber *guideFlag = [USER_DEFAULT objectForKey:APP_GUIDE];
    if (!guideFlag) {
        WSGuideViewController *guideVC = [[WSGuideViewController alloc] init];
        NSArray *guideImage = @[@"guide-01", @"guide-02", @"guide-03"];
        guideVC.imageArray = guideImage;
        guideVC.endCallBack = ^() {
            [_nav popViewControllerAnimated:NO];
        };
        [_nav pushViewController:guideVC animated:NO];
        [USER_DEFAULT setValue:[NSNumber numberWithInt:1] forKey:APP_GUIDE];
    }
    
    [[WSBMKUtil sharedInstance] startUserLocationService];
    
   // [self testIbeaCon];
    

    
    return YES;
}

//- (void)testIbeaCon
//{
//
//    ibsdk = [[IBSDK alloc] init];
//    [ibsdk startLocation];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:YES];
//}
//
//- (void)check
//{
//    NSArray *ibeacons = ibsdk.beaconsArray;
//    for (id beacon in ibeacons) {
//        DLog(@"beacon:%@", beacon);
//    }
//    
//}

- (void)synchronUserDataAndPeaNum
{
    //  安装后第一次启动
    NSNumber *notFirstOpen = [USER_DEFAULT objectForKey:APP_NOT_FIRST_OPEN];
    if (!notFirstOpen) {
        [USER_DEFAULT setValue:[NSNumber numberWithInt:100] forKey:APP_PEAS_NUM];
        [USER_DEFAULT setValue:[NSNumber numberWithBool:NO] forKey:APP_NOT_FIRST_OPEN];
        [USER_DEFAULT setObject:[NSNumber numberWithInt:1] forKey:APP_NOT_FIRST_OPEN];
    }

    NSString *dateStr = [WSCalendarUtil getDateStrWithDate:[NSDate date] format:@"yyyyMMdd"];
    NSDictionary *dayPeaNumDic = [USER_DEFAULT objectForKey:APP_DAY_PEA];
    
    // 首次没有对象说明没有领取精明豆，可以领取精明豆
    if (!dayPeaNumDic) {
        int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
        int allPeaNum = appPeasNum + 2;
        [USER_DEFAULT setObject:[NSNumber numberWithInt:allPeaNum] forKey:APP_PEAS_NUM];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:APP_DAY_PEA_IS_GET];
        [dic setObject:dateStr forKey:APP_DAY_PEA_IS_GET_DAY];
        [USER_DEFAULT setObject:dic forKey:APP_DAY_PEA];
    } else {
        NSString *tempStr = [dayPeaNumDic objectForKey:APP_DAY_PEA_IS_GET_DAY];
        
        // 如果今天没有领取精明豆则领取
        if (![dateStr isEqualToString:tempStr]) {
            int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
            int allPeaNum = appPeasNum + 2;
            [USER_DEFAULT setObject:[NSNumber numberWithInt:allPeaNum] forKey:APP_PEAS_NUM];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:APP_DAY_PEA_IS_GET];
            [dic setObject:dateStr forKey:APP_DAY_PEA_IS_GET_DAY];
            [USER_DEFAULT setObject:dic forKey:APP_DAY_PEA];
        }
    }
    
    

    // 自动登录时同步用户数据
    NSData *beforeData = [USER_DEFAULT objectForKey:USER_KEY];
    if (beforeData) { // 同步是否推送消息
        int appPeasNum = [[USER_DEFAULT objectForKey:APP_PEAS_NUM] intValue];
        
        WSUser *beforeUser = [NSKeyedUnarchiver unarchiveObjectWithData:beforeData];
        WSRunTime *runtime = [WSRunTime sharedWSRunTime];
        runtime.user = beforeUser;
        
        // 领取本机存储的精明豆
        runtime.user.beanNumber = [NSString stringWithFormat:@"%d", [runtime.user.beanNumber intValue] + appPeasNum];
        
        // 领取本机精明豆后清空本机精明豆
        [USER_DEFAULT setValue:[NSNumber numberWithInt:0] forKey:APP_PEAS_NUM];
        DLog(@"本机用户保存的精明豆：%@",beforeUser.beanNumber);
        // 同步服务器精明豆
        WSUser *user = [WSRunTime sharedWSRunTime].user;
        [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber":user.beanNumber} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
            [SVProgressHUD dismiss];
            NSDictionary *userDic = [[result objectForKey:@"data"] objectForKey:@"user"];
            NSMutableDictionary *tempDic = [WSBaseUtil changNumberToStringForDictionary:userDic];
            WSUser *nweUser = [[WSUser alloc] init];

            [nweUser setValuesForKeysWithDictionary:tempDic];
            
            DLog(@"同步服务器用户返回的精明豆：%@",nweUser.beanNumber);
            nweUser.phone = user.phone;
            nweUser.isPushNotification = user.isPushNotification;
            
            [WSRunTime sharedWSRunTime].user = nweUser;
            // 本地存储用户信息
            NSData *userdata = [NSKeyedArchiver archivedDataWithRootObject:[WSRunTime sharedWSRunTime].user];
            [USER_DEFAULT setObject:userdata forKey:USER_KEY];
            
        } failCallBack:^(id error) {
            [SVProgressHUD dismissWithError:@"同步失败！" afterDelay:TOAST_VIEW_TIME];
           
        } showMessage:YES];
        
    }
}

#pragma mark - 初始化百度地图 BMK
- (void)initBMK
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:BMK_AK generalDelegate:self];
    if (!ret) {
        DLog(@"百度地图启动错误！");
    }
}

#pragma mark - 初始化ShareSDK
- (void)initShareSDK
{
    //字符串api20为您的ShareSDK的AppKey
    [ShareSDK registerApp:SHARESDK_APPKEY];
    
    [Parse setApplicationId:PARSE_APPLICATIONID
                  clientKey:PARSE_CLIENTKEY];
    
    //添加新浪微博应用 注册网址 http://open.weibo.com
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                            redirectUri:@"http://www.sharesdk.cn"];
    
    // 登陆已成功
    [ShareSDK connectSinaWeiboWithAppKey:SINAWEIBO_APPKEY
                               appSecret:SINAWEIBO_SECRET
                             redirectUri:SINAWEIBO_REDIRECT_URL];
    
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
    [ShareSDK  connectSinaWeiboWithAppKey:SINAWEIBO_APPKEY
                                appSecret:SINAWEIBO_SECRET
                              redirectUri:SINAWEIBO_REDIRECT_URL
                              weiboSDKCls:[WeiboSDK class]];
    
//    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
//    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
//                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
//                                redirectUri:@"http://www.sharesdk.cn"
//                                   wbApiCls:[WeiboApi class]];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:QQ_APPID
                           appSecret:QQ_APPKEY
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://open.qq.com/
    [ShareSDK connectQQWithQZoneAppKey:QQ_APPID
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加微信应用 注册网址 http://open.weixin.qq.com
    // 加上以下代码微信登陆收授权失败
   // [ShareSDK connectWeChatWithAppId:WECHAT_APPID
        //                   wechatCls:[WXApi class]];
    //微信好友
    [ShareSDK connectWeChatSessionWithAppId: WECHAT_APPID
                                  appSecret: WECHAT_APPSECRET
                                  wechatCls: [WXApi class]];
    //微信朋友圈
    [ShareSDK connectWeChatTimelineWithAppId: WECHAT_APPID
                                   appSecret: WECHAT_APPSECRET
                                   wechatCls: [WXApi class]];
    
    // 如果用下面这个总的方法默认会有微信收藏
    //[ShareSDK connectWeChatWithAppId:WECHAT_APPID
//                           appSecret:WECHAT_APPSECRET
//                           wechatCls:[WXApi class]];
    
    //开启QQ空间网页授权开关(optional)
    id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [app setIsAllowWebAuthorize:YES];
}

#pragma mark - 初始化TabbarViewController
- (void)initTabbarViewController
{
    WSHomeViewController *homeVC = [[WSHomeViewController alloc] init];
    WSPromotionCouponViewController *promotionCouponVC = [[WSPromotionCouponViewController alloc] init];
    WSGainPeasViewController *gainPeasVC = [[WSGainPeasViewController alloc] init];
    WSMineViewController *miniVC = [[WSMineViewController alloc] init];
    WSTabbarViewController *tabbarVC = [[WSTabbarViewController alloc] init];
    NSArray *VCs = @[homeVC, promotionCouponVC, gainPeasVC, miniVC];
    NSArray *titles = @[@"首页", @"促销优惠", @"赚精明豆", @"我的"];
    NSArray *normalImages = @[@"a_normal", @"b_normal", @"c_normal", @"d_normal"];
    NSArray *selectedImages = @[@"a_selected", @"b_selected", @"c_selected", @"d_selected"];;
    NSUInteger VCCount = VCs.count;
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i < VCCount; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[VCs objectAtIndex:i] forKey:TABBARITEM_VIEWCONTROLLER];
        [dic setValue:[titles objectAtIndex:i] forKey:TABBARITEM_TITLE];
        [dic setValue:[normalImages objectAtIndex:i] forKey:TABBARITEM_IMAGE_NORMAL];
        [dic setValue:[selectedImages objectAtIndex:i] forKey:TABBARITEM_IMAGE_SELECTED];
        [dataArray addObject:dic];
    }
    tabbarVC.dataArray = dataArray;
    _nav = [[WSBaseNavigationController alloc] initWithRootViewController:tabbarVC];
    _nav.navigationBarHidden = YES;
    self.window.rootViewController = _nav;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:nil];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        // 本地存储用户信息
        NSData *userdata = [NSKeyedArchiver archivedDataWithRootObject:[WSRunTime sharedWSRunTime].user];
        [USER_DEFAULT setObject:userdata forKey:USER_KEY];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.wrs.qihui.SmartShopping" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmartShopping" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SmartShopping.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
   
}


- (void)onGetPermissionState:(int)iError
{
    
}


@end
