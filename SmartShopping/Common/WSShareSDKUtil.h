//
//  WSShareSDKUtil.h
//  SmartShopping
//
//  Created by wrs on 15/5/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSShareSDKUtil : NSObject

+ (void)shareWithTitle:(NSString *)title content:(NSString *)content description:(NSString *)description url:(NSString *)url imagePath:(NSString *)imagePath thumbImagePath:(NSString *)thumbImagePath result:(SSPublishContentEventHandler)result;

@end
