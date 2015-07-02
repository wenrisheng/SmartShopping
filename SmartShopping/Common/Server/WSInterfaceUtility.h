//
//  WSServerUtil.h
//  SmartShopping
//
//  Created by wrs on 15/4/21.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define BASE_URL @"http://121.41.86.29:8888/jmg"

#define BASE_URL    @"http://122.13.87.32:8888/jmg"
//#define BASE_URL    @"http://121.41.86.29:8888"


typedef NS_ENUM(NSInteger, WSInterfaceType)
{
    
    /***************************登录 | 注册**********************************/
    WSInterfaceTypeLogin = 0,                     // 登陆
    WSInterfaceTypeThirdlogin,                    // 第三方登录
    WSInterfaceTypeRegister,                       //注册
    WSInterfaceTypeResetPassword,                 //忘记密码 | 修改密码
    WSInterfaceTypeGetValidCode,                  // 获取验证码
    WSInterfaceTypeUpdatePhone,                   // 修改手机号码
    WSInterfaceTypeGetEmailValidCode,            // 获取邮箱验证码
    WSInterfaceTypeUpdateUser,                   // 用户资料修改
    WSInterfaceTypeTouristRegist,                //游客用户注册
    WSInterfaceTypeGetBeannumberByKeyWord,       // 精明豆后去规则接口
    
    /***************************我的**********************************/
    WSInterfaceTypeMytowGift,                    // 我的页面奖励兑换
    WSInterfaceTypeBeanScope,                    // 奖励兑换-豆子范围接口
    WSInterfaceTypeGiftCategory,                 // 奖励兑换-礼品分类条件接口
    WSInterfaceTypeSearchGift,                    // 奖励兑换-礼品查询
    WSInterfaceTypeGetGiftDetails,                // 礼品详情
    WSInterfaceTypeExchangeGift,                 // 礼品兑换
    WSInterfaceTypeMyGiftList,                   // 我的兑换、消费券
    WSInterfaceTypeUserAgreeAbout,               // 用户协议、关于
    WSInterfaceTypeFeedBack,                     // 用户意见反馈
    WSInterfaceTypeCollectGoods,                 //收藏商品
    WSInterfaceTypeMyCollectList,                // 我的收藏列表
    WSInterfaceTypeDeleteCollect,                //删除收藏
    WSInterfaceTypeDelUserGift,                  //删除用户礼品信息
    WSInterfaceTypeSynchroBeanNumber,            //用户登录时同步精明豆
    
    /***************************首页**********************************/
    WSInterfaceTypeGetOneIbeacon,                // 查询ibeacon推送文本消息
    WSInterfaceTypeGetAdsPhoto,                  // 首页广告轮播图片
    WSInterfaceTypeClickAdvert,                  // 用户每次点击广告
    WSInterfaceTypeGetHomePageGoods,             // 首页附件精选
    WSInterfaceTypeUserMessage,                  // 消息列表
    WSInterfaceTypeUpdateIsNewMessage,           //将新消息列表更新为旧消息
    WSInterfaceTypeuUpdateMessage,               // 更新用户消息是否已读
    WSInterfaceTypeDelMessage,                   // 删除用户消息
    WSInterfaceTypeGetGoodsDetails,              // 查询商品详情
    WSInterfaceTypeSearchShop,                   // 首页商店搜索
    WSInterfaceTypeSelectGoods,                  // 首页商品搜索
    WSInterfaceTypeMessageGoodsDetails,          //消息列表的商品详情
    WSInterfaceTypeFindMessageDetail,            //文本消息查看详情接口
    
    /***************************促销优惠**********************************/
    WSInterfaceTypeGetAreaList,                  //区域筛选条件
    WSInterfaceTypeGetShopTypeList,              //所有商店筛选条件
    WSInterfaceTypeGetShopCategory,              //品类筛选条件
    WSInterfaceTypeGetShopBrand,                 //品牌筛选条件
    WSInterfaceTypeOutShopGoodsList,             // 店外查询接口
    WSInterfaceTypeCheckMoreGoodsList,           // 查看更多
    WSInterfaceTypeIsInShopAndIsScans,         // 判断用户是否在店内，是否可以扫描
    WSInterfaceTypeIsInshop,                   //用户是否在店内(此接口只用来签到，判断是否在店内，是否可以签到)
    
    /***************************到店签到**********************************/
    WSInterfaceTypeShopSignList,                 // 不在店内（列表）
    WSInterfaceTypeEarnSignBean,                 // 签到获取精明豆
 //   WSInterfaceTypeSsInshopBySign,             // 用户是否在店内
    
     /***************************商品扫描活动**********************************/
    WSInterfaceTypeGoodsScanList,                // 扫描首页商品列表
    WSInterfaceTypeInShopGoodsScanList,           // 店内扫描商品列表
    WSInterfaceTypeEarnBeanByScanGoods,          // 扫描商品获得精明豆 
 

//    WSInterfaceTypeShopSignList,                  // 到店签到
//    WSInterfaceType
//    WSInterfaceType
//    WSInterfaceType

};


@interface WSInterfaceUtility : NSObject

+ (NSString *)getURLWithType:(WSInterfaceType)interfaceType;

+ (BOOL)validRequestResult:(NSDictionary *)dic;

+ (BOOL)validRequestResultNoErrorMsg:(NSDictionary *)dic;

+ (NSString *)getImageURLWithStr:(NSString *)str;

@end
