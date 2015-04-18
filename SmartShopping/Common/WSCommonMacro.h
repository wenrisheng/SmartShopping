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
#define SHARESDK_APPKEY       @"6c390857513e"

// Parse
#define PARSE_APPLICATIONID   @"CVa6OhurE383B6zkpQKOUv0cMHPUJT7T2NKuIRPj"
#define PARSE_CLIENTKEY       @"lIn9aJkboD3r5ebSvNRKU9BxfsiRSIXwkEI9ZYid"

// 新浪微博
#define SINAWEIBO_APPKEY    @"2278135746"
#define SINAWEIBO_SECRET    @"0229c752b7213bd8cf409ff98896ece4"

// 状态栏颜色
#define STATUSBAR_COLOR    [UIColor colorWithRed:0.898 green:0.380 blue:0.133 alpha:1.000]


/******************服务器地址**********************/
#define SERVER_BASE_URL               @"http://192.168.0.238:8088/jmg"

#define SERVER_LOGIN(base)           [NSString stringWithFormat:@"%@base/app/login.do", base]

#endif
