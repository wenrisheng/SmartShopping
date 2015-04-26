//
//  WSServerUtil.m
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSInterfaceUtility.h"

@implementation WSInterfaceUtility

+ (NSString *)getURLWithType:(WSInterfaceType)interfaceType
{
    switch (interfaceType) {
        case WSInterfaceTypeLogin:
        {
            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeRegister:
        {
            return [NSString stringWithFormat:@"%@/app/register.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeResetPassword:
        {
            return [NSString stringWithFormat:@"%@/app/resetPassword.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetValidCode:
        {
            return [NSString stringWithFormat:@"%@/app/getValidCode.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeUpdatePhone:
        {
            return [NSString stringWithFormat:@"%@/app/updatePhone.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetEmailValidCode:
        {
            return [NSString stringWithFormat:@"%@/app/getEmailValidCode.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeUpdateUser:
        {
            return [NSString stringWithFormat:@"%@/app/updateUser.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeMytowGift:
        {
            return [NSString stringWithFormat:@"%@/app/mytowgift.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeBeanScope:
        {
            return [NSString stringWithFormat:@"%@/app/beanScope.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGiftCategory:
        {
            return [NSString stringWithFormat:@"%@/app/giftCategory.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeSearchGift:
        {
            return [NSString stringWithFormat:@"%@/app/searchGift.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetGiftDetails:
        {
            return [NSString stringWithFormat:@"%@/app/getGiftDetails.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeExchangeGift:
        {
            return [NSString stringWithFormat:@"%@/app/exchangeGift.do", BASE_URL];
        }
            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeLogin:
//        {
//            return [NSString stringWithFormat:@"%@/app/login.do", BASE_URL];
//        }
//            break;
        default:
            break;
    }
    return nil;
}

+ (BOOL)validRequestResult:(NSDictionary *)dic
{
    BOOL flag = NO;
    NSInteger status = [[dic objectForKey:@"status"] integerValue];
    NSString *msg = [dic objectForKey:@"msg"];
    NSString *statusDesc = nil;
    if (status == 10001) {
        statusDesc = @"成功";
        flag = YES;
        return flag;
    } else if (status == 2001) {
        statusDesc = @"失败未知错误";
    } else if (status == 20003) {
        statusDesc = @"找不到内容";
    } else if (status == 2004) {
        statusDesc = @"参数错误";
    } else if (status == 2006) {
        statusDesc = @"参数为空";
    } else if (status == 21001) {
        statusDesc = @"身份认证失效，需重新登录";
    } else if (status == 20005) {
        statusDesc = @"其他自定义状态消息";
    }
    if (!flag) {
         [SVProgressHUD showErrorWithStatus:msg duration:TOAST_VIEW_TIME];
    }
   
#ifdef DEBUG
    DLog(@"请求结果状态描述：%@", statusDesc);
#endif
    return flag;
}

@end
