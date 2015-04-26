//
//  WSUser.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSUser : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *Nickname;
@property (strong, nonatomic) NSString *inviteCode;
@property (strong, nonatomic) NSString *byInviteCode;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *beanNumber;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *logoPath;

// 推送通知
@property (assign, nonatomic) BOOL isPushNotification;

@end
