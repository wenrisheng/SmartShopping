//
//  WSServerUtil.h
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URL    @"http://121.41.86.29:8080/jmg"
//#define BASE_URL    @"http://121.41.86.29:8080"


typedef NS_ENUM(NSInteger, WSInterfaceType) {
    WSInterfaceTypeLogin = 0,                     // 登陆
    WSInterfaceTypeRegister,                       //注册
    WSInterfaceTypeResetPassword,                 //忘记密码 | 修改密码
    WSInterfaceTypeGetValidCode,                  // 获取验证码
    WSInterfaceTypeUpdatePhone,                   // 修改手机号码
    WSInterfaceTypeGetEmailValidCode,            // 获取邮箱验证码
    WSInterfaceTypeUpdateUser,                   // 用户资料修改
    WSInterfaceTypeMytowGift,                    // 我的页面奖励兑换
    WSInterfaceTypeBeanScope,                    // 奖励兑换-豆子范围接口
    WSInterfaceTypeGiftCategory,                 // 奖励兑换-礼品分类条件接口
    WSInterfaceTypeSearchGift,                    // 奖励兑换-礼品查询
    WSInterfaceTypeGetGiftDetails,                // 礼品详情
    WSInterfaceTypeExchangeGift,                 // 礼品兑换
    
    WSInterfaceTypeMyGiftList,                   // 我的兑换、消费券
    WSInterfaceTypeUserAgreeAbout,               // 用户协议、关于
    WSInterfaceTypeFeedBack,                     // 用户意见反馈
    WSInterfaceTypeGetAdsPhoto,                  // 首页广告轮播图片
    WSInterfaceTypeGetHomePageGoods,             // 首页附件精选
};


@interface WSInterfaceUtility : NSObject

+ (NSString *)getURLWithType:(WSInterfaceType)interfaceType;

+ (BOOL)validRequestResult:(NSDictionary *)dic;

@end
