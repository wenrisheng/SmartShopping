//
//  WSUser.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSUser.h"

@implementation WSUser


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self._id = value;
    }
}

@end
