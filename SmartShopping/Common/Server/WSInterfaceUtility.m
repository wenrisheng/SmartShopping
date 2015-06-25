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
        case WSInterfaceTypeThirdlogin:
        {
             return [NSString stringWithFormat:@"%@/app/thirdlogin.do", BASE_URL];
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
        case WSInterfaceTypeTouristRegist:
        {
            return [NSString stringWithFormat:@"%@/app/touristRegist.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetBeannumberByKeyWord:
        {
            return [NSString stringWithFormat:@"%@/app/getBeannumberByKeyWord.do", BASE_URL];
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
        case WSInterfaceTypeMyGiftList:
        {
            return [NSString stringWithFormat:@"%@/app/mygiftlist.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeUserAgreeAbout:
        {
            return [NSString stringWithFormat:@"%@/app/userAgreeAbout.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeCollectGoods:
        {
            return [NSString stringWithFormat:@"%@/app/collectGoods.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeMyCollectList:
        {
            return [NSString stringWithFormat:@"%@/app/myCollectList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeDeleteCollect:
        {
            return [NSString stringWithFormat:@"%@/app/deleteCollect.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeSynchroBeanNumber:
        {
            return [NSString stringWithFormat:@"%@/app/synchroBeanNumber.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeFeedBack:
        {
            return [NSString stringWithFormat:@"%@/app/feedBack.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetOneIbeacon:
        {
            return [NSString stringWithFormat:@"%@/app/getOneIbeacon.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetAdsPhoto:
        {
            return [NSString stringWithFormat:@"%@/app/getAdsPhoto.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeClickAdvert:
        {
             return [NSString stringWithFormat:@"%@/app/clickAdvert.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetHomePageGoods:
        {
            return [NSString stringWithFormat:@"%@/app/getHomePageGoods.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeUserMessage:
        {
            return [NSString stringWithFormat:@"%@/app/userMessage.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeUpdateIsNewMessage:
        {
          return [NSString stringWithFormat:@"%@/app/updateIsNewMessage.do", BASE_URL];  
        }
            break;
        case WSInterfaceTypeuUpdateMessage:
        {
            return [NSString stringWithFormat:@"%@/app/updateMessage.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeDelMessage:
        {
            return [NSString stringWithFormat:@"%@/app/delMessage.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetGoodsDetails:
        {
            return [NSString stringWithFormat:@"%@/app/getGoodsDetails.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeSearchShop:
        {
             return [NSString stringWithFormat:@"%@/app/searchShop.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeSelectGoods:
        {
           return [NSString stringWithFormat:@"%@/app/selectGoods.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeMessageGoodsDetails:
        {
            return  [NSString stringWithFormat:@"%@/app/messageGoodsDetails.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeFindMessageDetail:
        {
             return  [NSString stringWithFormat:@"%@/app/findMessageDetail.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetAreaList:
        {
            return [NSString stringWithFormat:@"%@/app/getAreaList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetShopTypeList:
        {
            return [NSString stringWithFormat:@"%@/app/getShopTypeList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetShopCategory:
        {
            return [NSString stringWithFormat:@"%@/app/getShopCategory.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGetShopBrand:
        {
            return [NSString stringWithFormat:@"%@/app/getShopBrand.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeOutShopGoodsList:
        {
            return [NSString stringWithFormat:@"%@/app/outShopGoodsList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeShopSignList:
        {
            return [NSString stringWithFormat:@"%@/app/shopSignList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeEarnSignBean:
        {
            return [NSString stringWithFormat:@"%@/app/earnSignBean.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeGoodsScanList:
        {
             return [NSString stringWithFormat:@"%@/app/goodsScanList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeInShopGoodsScanList:
        {
            return [NSString stringWithFormat:@"%@/app/inShopGoodsScanList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeEarnBeanByScanGoods:
        {
            return [NSString stringWithFormat:@"%@/app/earnBeanByScanGoods.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeCheckMoreGoodsList:
        {
            return [NSString stringWithFormat:@"%@/app/checkMoreGoodsList.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeIsInShopAndIsScans:
        {
            return [NSString stringWithFormat:@"%@/app/isInShopAndIsScan.do", BASE_URL];
        }
            break;
        case WSInterfaceTypeIsInshop:
        {
             return [NSString stringWithFormat:@"%@/app/isInshop.do", BASE_URL];
        }
            break;
//        case WSInterfaceTypeSsInshopBySign:
//        {
//            return [NSString stringWithFormat:@"%@/app/isInshopBySign.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeIsInshopByPromotions:
//        {
//            return [NSString stringWithFormat:@"%@/app/isInshopByPromotions.do", BASE_URL];
//        }
//            break;
//        case WSInterfaceTypeIsInshopByPromotions:
//        {
//            return [NSString stringWithFormat:@"%@/app/isInshopByPromotions.do", BASE_URL];
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
        msg = msg == nil ? @"加载失败！" : msg;
         [SVProgressHUD showErrorWithStatus:msg duration:TOAST_VIEW_TIME];
    }
   
#ifdef DEBUG
    DLog(@"请求错误结果状态描述：%@", statusDesc);
#endif
    return flag;
}

+ (BOOL)validRequestResultNoErrorMsg:(NSDictionary *)dic
{
    BOOL flag = NO;
    NSInteger status = [[dic objectForKey:@"status"] integerValue];
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
    
#ifdef DEBUG
    DLog(@"请求错误结果状态描述：%@", statusDesc);
#endif
    return flag;
}

+ (NSString *)getImageURLWithStr:(NSString *)str
{
    return [NSString stringWithFormat:@"%@/%@", BASE_URL, str];
}

@end
