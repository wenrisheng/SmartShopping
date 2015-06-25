//
//  WSMacroHeader.h
//  SmartShopping
//
//  Created by wrs on 15/4/15.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#ifndef SmartShopping_WSMacroHeader_h
#define SmartShopping_WSMacroHeader_h

#define USER_KEY                      @"USER_KEY"                    // 保存登陆用户信息，用来做自动登录
#define APP_PEAS_NUM                  @"APP_PEAS_NUM"                // 本机保存的精明豆数量
#define WSPAGE_SIZE                   @"15"                          // 每页请求条数
#define TOURIST_KEY                   @"ROURIST_KEY"                //游客
#define FIRST_USED                    @"FIRS_USED"                   // 首次使用app获取精明豆数量
#define OPEN_APP                      @"OPEN_APP"                     //打开app获取精明豆数量

#define APP_NOT_FIRST_OPEN            @"APP_NOT_FIRST_OPEN"         // 应用不是第一次启动
#define APP_DAY_PEA                   @"APP_DAY_PEA"                // 每天领取精明豆
#define APP_DAY_PEA_IS_GET            @"APP_DAY_PEA_IS_GET"         // 今天是否领取了精明豆
#define APP_DAY_PEA_IS_GET_DAY        @"APP_DAY_PEA_IS_GET_DAY"     // 领取了精明豆的日期

#define APP_GUIDE                     @"APP_GUIDE"                   // 引导页是否已经显示
#define PUSH_NOTIFICATION             @"PUSH_NOTIFICATION"         // 推送通知

// ibeacon
#define IBEACON_KEY                   @"IBEACON_KEY"
#define IBEACON_INFO                  @"IBEACON_INFO"
#define IBEACON_IS_VALID              @"IBEACON_IS_VALIE"
#define IBEACON_DISTANCE              @"IBEACON_DISTANCE"

// 百度地区ak
//#define BMK_AK                      @"DN1fArBETwGtWqS5DYz1Oe1n"

#define BMK_AK                        @"uvZy3pgyP8CbBjoIw9Muj2Oc"
#define LOCATION_DISTANCE_FILTER      10.0f   //最小距离更新(米)

// ShareSKD
#define SHARESDK_APPKEY               @"6bb713bd24e4"
#define SHARESKE_APPSECRET            @"973ae7cda390a8137f236f19f23bb78c"

// Parse
#define PARSE_APPLICATIONID           @"CVa6OhurE383B6zkpQKOUv0cMHPUJT7T2NKuIRPj"
#define PARSE_CLIENTKEY               @"lIn9aJkboD3r5ebSvNRKU9BxfsiRSIXwkEI9ZYid"

// 新浪微博  授权回调url需要在开放平台中设置   个人网站http://www.ismartgo.com 填写url schuma
//应用地址：http://app.ismartgo.com
//授权回调页：http://app.ismartgo.com
//取消授权回调页：http://http://app.ismartgo.com
/********* 启汇 的  登录授权出错，初步分析是应用审核被驳回 **********/
#define SINAWEIBO_APPKEY             @"3471108719"
#define SINAWEIBO_SECRET             @"bc4161722e80558f7ec4fb6b06e0b6cf"
#define SINAWEIBO_REDIRECT_URL       @"http://app.ismartgo.com"

/********我的********/
//应用地址：http://www.sharesdk.cn
//授权回调页：http://www.sharesdk.cn
//取消授权回调页：http://www.sharesdk.cn

//#define SINAWEIBO_APPKEY          @"2278135746"
//#define SINAWEIBO_SECRET          @"0229c752b7213bd8cf409ff98896ece4"
//#define SINAWEIBO_REDIRECT_URL    @"http://www.sharesdk.cn"

// QQ    需填写平台信息中的应用开发地址  QQ不支持第三方登陆，要通过QQ空间授权
/********* 启汇 的  登陆已经成功授权**********/
// appid 转十六进制后41D5E170
// url schema QQ41D5E170
// 调试QQ 3162484720  密码： ismartgo66
#define QQ_APPID           @"1104535920"
#define QQ_APPKEY          @"geSmYdACu6VVyzbv"


/***********我的*************/
//#define QQ_APPID            @"1104500325"
//#define QQ_APPKEY           @"TISg54qtNYCFw72h"
//  填写 url schema 、 bundle id 、 appstore id
//#define QQ_APPID           @"1104500343"
//#define QQ_APPKEY          @"s0Q4OJC8pnGVyX58"

// 微信   需要bundle id 、 应用网址 审核通过后才有appkey之类的

// 微信
/*********启汇 登陆授权成功*********/
//应用官网app.ismartgo.com
#define WECHAT_APPID       @"wx9e58ac62f72d9042"
#define WECHAT_APPSECRET   @"9ffbe1acbb8a561ea9d03b3409649e17"


/*************我的**************/
//#define WECHAT_APPID       @"wx9e58ac62f72d9042"
//#define WECHAT_APPSECRET   @"9ffbe1acbb8a561ea9d03b3409649e17"


#define COLLECTION_VIEW_GAP    10

// 状态栏颜色
#define STATUSBAR_COLOR               [UIColor colorWithRed:0.898 green:0.380 blue:0.133 alpha:1.000]

#define  TOAST_VIEW_TIME              2  // 提示时间
#define  APP_URL                      @"http://itunes.apple.com/lookup?id=924413147"  // 暂时用了艾童会 1.11


/******************服务器地址**********************/
#define SERVER_BASE_URL               @"http://192.168.0.238:8088/jmg"

#define SERVER_LOGIN(base)           [NSString stringWithFormat:@"%@base/app/login.do", base]

#endif
