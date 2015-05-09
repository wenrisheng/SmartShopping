//
//  WSUserUtil.h
//  SmartShopping
//
//  Created by wrs on 15/5/5.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSUserUtil : NSObject

+ (void)actionAfterLogin:(void(^)(void))action;

@end
