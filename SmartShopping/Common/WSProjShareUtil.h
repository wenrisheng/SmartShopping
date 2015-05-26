//
//  WSProjShareUtil.h
//  SmartShopping
//
//  Created by wrs on 15/5/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>


#define GOODS_NAME       @"GOODS_NAME"
#define SHOP_NAME        @"SHOP_NAME"
#define GOODS_LOGO       @"GOODS_LOGO"
#define GOODS_URL        @"GOODS_URL"

@interface WSProjShareUtil : NSObject

+ (void)shareGoodsDetails:(NSDictionary *)goodsDetails;

@end
