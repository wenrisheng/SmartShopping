//
//  WSMacroHeader.h
//  SmartShopping
//
//  Created by wrs on 15/4/15.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#ifndef SmartShopping_WSMacroHeader_h
#define SmartShopping_WSMacroHeader_h

// 百度地区ak
//#define BMK_AK              @"DN1fArBETwGtWqS5DYz1Oe1n"

#define BMK_AK                 @"SSHUceW4YjE7AinLZUsCtS0U"  // 绑定的bundle identify 是 com.gdcattsoft.$(PRODUCT_NAME:rfc1034identifier)

// ShareSKD
#define SHARESDK_APPKEY       @"6bb713bd24e4"

// Parse
#define PARSE_APPLICATIONID   @"CVa6OhurE383B6zkpQKOUv0cMHPUJT7T2NKuIRPj"
#define PARSE_CLIENTKEY       @"lIn9aJkboD3r5ebSvNRKU9BxfsiRSIXwkEI9ZYid"

// 新浪微博  授权回调url需要在开放平台中设置
#define SINAWEIBO_APPKEY    @"2278135746"
#define SINAWEIBO_SECRET    @"0229c752b7213bd8cf409ff98896ece4"

// QQ    需填写平台信息中的应用开发地址
//#define QQ_APPID            @"1104500325"
//#define QQ_APPKEY           @"TISg54qtNYCFw72h"
//  填写 url schema 、 bundle id 、 appstore id
#define QQ_APPID           @"1104500343"
#define QQ_APPKEY          @"s0Q4OJC8pnGVyX58"

// 微信   需要bundle id 、 应用网址 审核通过后才有appkey之类的

// 状态栏颜色
#define STATUSBAR_COLOR               [UIColor colorWithRed:0.898 green:0.380 blue:0.133 alpha:1.000]

#define  TOAST_VIEW_TIME              3  // 提示时间

/******************服务器地址**********************/
#define SERVER_BASE_URL               @"http://192.168.0.238:8088/jmg"

#define SERVER_LOGIN(base)           [NSString stringWithFormat:@"%@base/app/login.do", base]

#endif
