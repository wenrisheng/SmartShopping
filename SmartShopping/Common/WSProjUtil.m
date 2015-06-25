//
//  WSProjUtil.m
//  SmartShopping
//
//  Created by wrs on 15/4/29.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProjUtil.h"
#import "IBSDK.h"
#import "WSSignupSucView.h"

#define GAIN_BEANNUM_SUC      5

@implementation WSProjUtil

+ (int)gerRandomColor
{
    return [WSBaseUtil getRandomNumber:1 to:4];
}

+ (UINavigationController *)getRootNav
{
    AppDelegate *appDelegate = APP_DELEGATE;
    return appDelegate.nav;
}

+ (void)showGainBeanNumWithBeanNum:(NSString *)beanNumber callback:(void (^)(void))callback
{
    WSSignupSucView *sucView = [WSSignupSucView getView];
    sucView.label.text = [NSString stringWithFormat:@"获得%@精明豆", beanNumber];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:sucView];
    [sucView expandToSuperView];
    // 延迟5秒执行：
    double delayInSeconds = GAIN_BEANNUM_SUC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sucView removeFromSuperview];
        if (callback) {
            callback();
        }
    });
  
}

+ (NSString *)converDateWithDateStr:(NSString *)dateStr
{
    if (!dateStr) {
        return @"有效日期未知";
    }
    NSArray *array = [dateStr componentsSeparatedByString:@"-"];
    if (array.count < 3) {
        return  @"有效日期未知";
    }
    NSString *month = [array objectAtIndex:1];
    int monthInt = [month intValue];
    NSString *day = [array objectAtIndex:2];
    int dayInt = [day intValue];
    NSString *result = [NSString stringWithFormat:@"%d月%d日前有效", monthInt, dayInt];
    return result;
}

+ (NSString *)converDistanceWithDistanceStr:(NSString *)distance
{
    float distanceFloat = [distance floatValue];
    NSString *resultStr = [NSString stringWithFormat:@"%.1fkm", distanceFloat];
    return resultStr;
}

+ (void)isInStoreWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ibeacon) {
        NSString *beaconUUID = [ibeacon.proximityUUID UUIDString];
        [param setValue:beaconUUID forKey:@"uuid"];
        [param setValue:ibeacon.major forKey:@"major"];
        [param setValue:ibeacon.minor forKey:@"minor"];
    }
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    double longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    double latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [param setValue:user._id forKey:@"uid"];
    } else {
        [param setValue:@"" forKey:@"uid"];
    }
    [param setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    [param setValue:[NSString stringWithFormat:@"%f", longtide] forKey:@"lon"];
   
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeIsInshop] data:param tag:WSInterfaceTypeIsInshop sucCallBack:^(id result) {
    
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *isInShopDic = [[result objectForKey:@"data"] objectForKey:@"isInShop"];
            NSString *isinshop = [isInShopDic stringForKey:@"isinshop"];
            // 在店内
            if ([isinshop isEqualToString:@"Y"]) {
                [resultDic setValue:[NSNumber numberWithBool:YES] forKey:IS_IN_SHOP_FLAG];
                //不在店内
            } else {
                [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
            }
            [resultDic setValue:isInShopDic forKey:IS_IN_SHOP_DATA];
            // 校验数据有错也表示不在店内
        } else {
            [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        }
        
        // 回调
        if (callback) {
            callback(resultDic);
        }
        
    } failCallBack:^(id error) {
        [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        if (callback) {
            callback(resultDic);
        }
        [SVProgressHUD dismiss];
    } showMessage:YES];
}

+ (void)isInShopAndIsScanWithIBeacon:(CLBeacon *)ibeacon callback:(void (^)(id result))callback
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ibeacon) {
        NSString *beaconUUID = [ibeacon.proximityUUID UUIDString];
        [param setValue:beaconUUID forKey:@"uuid"];
        [param setValue:ibeacon.major forKey:@"major"];
        [param setValue:ibeacon.minor forKey:@"minor"];
    }
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    double longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    double latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
   
    [param setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    [param setValue:[NSString stringWithFormat:@"%f", longtide] forKey:@"lon"];
    
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeIsInShopAndIsScans] data:param tag:WSInterfaceTypeIsInShopAndIsScans sucCallBack:^(id result) {
        
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            NSDictionary *isInShopDic = [[result objectForKey:@"data"] objectForKey:@"isInShop"];
            NSString *isinshop = [isInShopDic stringForKey:@"isinshop"];
            // 在店内
            if ([isinshop isEqualToString:@"Y"]) {
                [resultDic setValue:[NSNumber numberWithBool:YES] forKey:IS_IN_SHOP_FLAG];
                //不在店内
            } else {
                [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
            }
            [resultDic setValue:isInShopDic forKey:IS_IN_SHOP_DATA];
            // 校验数据有错也表示不在店内
        } else {
            [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        }
        
        // 回调
        if (callback) {
            callback(resultDic);
        }
        
    } failCallBack:^(id error) {
        [resultDic setValue:[NSNumber numberWithBool:NO] forKey:IS_IN_SHOP_FLAG];
        if (callback) {
            callback(resultDic);
        }
        [SVProgressHUD dismiss];
    } showMessage:YES];
}

+ (void)synchronBeanNumWithUser:(WSUser *)user beanNumber:(NSString *)beanNumber callBack:(void (^)())callback
{
    NSString *userType = user.userType;
    beanNumber = beanNumber.length > 0 ? beanNumber : @"0";
    // 登录用户
    if ([userType isEqualToString:@"1"]) {
        [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"uid": user._id, @"beanNumber": beanNumber, @"touristid": @""} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
            BOOL flag = [WSInterfaceUtility validRequestResultNoErrorMsg:result];
            if (flag) {
                NSDictionary *userDic = [[result objectForKey:@"data"] objectForKey:@"user"];
                NSMutableDictionary *tempDic = [WSBaseUtil changNumberToStringForDictionary:userDic];
                WSUser *nweUser = [WSProjUtil convertDicToUser:tempDic];
                
                nweUser.phone = user.phone;
                nweUser.loginType = user.loginType;
                nweUser.userType = user.userType;
                
                [WSRunTime sharedWSRunTime].user = nweUser;
                
                // 本地存储用户信息
                [WSProjUtil archiverUser:nweUser key:USER_KEY];
            }
           
            if (callback) {
                callback();
            }
        } failCallBack:^(id error) {
            if (callback) {
                callback();
            }
        } showMessage:NO];
        
    // 游客
    } else {
        [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeSynchroBeanNumber] data:@{@"touristid": user._id, @"beanNumber": beanNumber, @"uid": @""} tag:WSInterfaceTypeSynchroBeanNumber sucCallBack:^(id result) {
            BOOL flag = [WSInterfaceUtility validRequestResultNoErrorMsg:result];
            if (flag) {
                NSDictionary *userDic = [[result objectForKey:@"data"] objectForKey:@"user"];
                NSMutableDictionary *tempDic = [WSBaseUtil changNumberToStringForDictionary:userDic];
                WSUser *nweTourist = [WSProjUtil convertDicToUser:tempDic];
                WSUser *currentUser = [WSRunTime sharedWSRunTime].user;
                if ([currentUser.userType isEqualToString:@"2"]) {
                    [WSRunTime sharedWSRunTime].user = nweTourist;
                }
                [WSProjUtil archiverUser:nweTourist key:TOURIST_KEY];
            }

            if (callback) {
                callback();
            }
            
        } failCallBack:^(id error) {
            if (callback) {
                callback();
            }
        } showMessage:NO];
    }
}

+ (void)synchronOpenAppBeanNumWithUser:(WSUser *)user callBack:(void (^)())callback
{
    if (!user) {
        return;
    }
    NSString *dateStr = [WSCalendarUtil getDateStrWithDate:[NSDate date] format:@"yyyyMMdd"];
    NSDictionary *dayPeaNumDic = [USER_DEFAULT objectForKey:APP_DAY_PEA];
    
    // 首次没有对象说明没有领取精明豆，可以领取精明豆
    if (!dayPeaNumDic) {
        int appPeasNum = [[USER_DEFAULT objectForKey:OPEN_APP] intValue];
        NSString *userBeanNumber = user.beanNumber;
        int beanNum = [userBeanNumber intValue] + appPeasNum;
        user.beanNumber = [NSString stringWithFormat:@"%d", beanNum];
        [WSProjUtil synchronBeanNumWithUser:user beanNumber:[NSString stringWithFormat:@"%d", appPeasNum] callBack:callback];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:APP_DAY_PEA_IS_GET];
        [dic setObject:dateStr forKey:APP_DAY_PEA_IS_GET_DAY];
        [USER_DEFAULT setObject:dic forKey:APP_DAY_PEA];
    
    } else {
        NSString *tempStr = [dayPeaNumDic objectForKey:APP_DAY_PEA_IS_GET_DAY];
        
        // 如果今天没有领取精明豆则领取
        if (![dateStr isEqualToString:tempStr]) {
            int appPeasNum = [[USER_DEFAULT objectForKey:OPEN_APP] intValue];
            NSString *userBeanNumber = user.beanNumber;
            int beanNum = [userBeanNumber intValue] + appPeasNum;
            user.beanNumber = [NSString stringWithFormat:@"%d", beanNum];
            [WSProjUtil synchronBeanNumWithUser:user beanNumber:[NSString stringWithFormat:@"%d", appPeasNum] callBack:callback];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:APP_DAY_PEA_IS_GET];
            [dic setObject:dateStr forKey:APP_DAY_PEA_IS_GET_DAY];
            [USER_DEFAULT setObject:dic forKey:APP_DAY_PEA];
        }
    }
    if (callback) {
        callback();
    }
}

+ (void)synchronFirstUsedBeanNumWithUser:(WSUser *)user callBack:(void (^)())callback
{
    if (!user) {
        return;
    }
    //  安装后第一次启动
    NSNumber *notFirstOpen = [USER_DEFAULT objectForKey:APP_NOT_FIRST_OPEN];
    if (!notFirstOpen) {
        NSNumber *firstUserPea = [USER_DEFAULT objectForKey:FIRST_USED];
        if (firstUserPea) {
            int appPeasNum = [[USER_DEFAULT objectForKey:FIRST_USED] intValue];
            NSString *userBeanNumber = user.beanNumber;
            int beanNum = [userBeanNumber intValue] + appPeasNum;
            user.beanNumber = [NSString stringWithFormat:@"%d", beanNum];
            [WSProjUtil synchronBeanNumWithUser:user beanNumber:[NSString stringWithFormat:@"%d", appPeasNum] callBack:nil];
            [USER_DEFAULT setValue:[NSNumber numberWithBool:NO] forKey:APP_NOT_FIRST_OPEN];
        }
    }
    if (callback) {
        callback();
    }
}

+ (WSUser *)convertDicToUser:(NSDictionary *)dic
{
    WSUser *user = [[WSUser alloc] init];
    user.age = [dic stringForKey:@"age"];
    user.beanNumber = [dic stringForKey:@"beanNumber"];
    user.birthday = [dic stringForKey:@"birthday"];
    user.byInviteCode = [dic stringForKey:@"byInviteCode"];
    user.cityId = [dic stringForKey:@"cityId"];
    user.cityName = [dic stringForKey:@"cityName"];
    user.createTime = [dic stringForKey:@"createTime"];
    user.eState = [dic stringForKey:@"eState"];
    user.email = [dic stringForKey:@"email"];
    user._id = [dic stringForKey:@"id"];
    user.inviteCode = [dic stringForKey:@"inviteCode"];
    user.inviteCount = [dic stringForKey:@"inviteCount"];
    user.logoPath = [dic stringForKey:@"logoPath"];
    user.modifyTime = [dic stringForKey:@"modifyTime"];
    user.nickname = [dic stringForKey:@"nickname"];
    user.password = [dic stringForKey:@"password"];
    user.provinceId = [dic stringForKey:@"provinceId"];
    user.provinceName = [dic stringForKey:@"provinceName"];
    user.roleid = [dic stringForKey:@"roleid"];
    user.sex = [dic stringForKey:@"sex"];
    user.status = [dic stringForKey:@"status"];
    user.sysRole = [dic stringForKey:@"sysRole"];
    user.thirdid = [dic stringForKey:@"thirdid"];
    user.type = [dic stringForKey:@"type"];
    user.username = [dic stringForKey:@"username"];
    user.verifyCode = [dic stringForKey:@"verifyCode"];
    return user;
}

+ (void)archiverUser:(id)obj key:(NSString *)key
{
    if (!obj) {
        return;
    }
    NSMutableData *aadatA = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:aadatA];
    [archiver encodeObject:obj forKey:key];
    [archiver finishEncoding];
    [USER_DEFAULT setObject:aadatA forKey:key];
}

+ (id)unarchiverUserWithKey:(NSString *)key
{
    NSData *endata = [USER_DEFAULT objectForKey:key];
    if (!endata) {
        return nil;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:endata];
    
    //解档出数据模型Student
    id obj = [unarchiver decodeObjectForKey:key];
    return obj;
}

@end
