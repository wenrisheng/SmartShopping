//
//  WSUser.h
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserLoginType) {
    UserLoginTypePhone = 0,   // 手机
    UserLoginTypeWeibo,       // 微博
    UserLoginTypeQQ,          // QQ
    UserLoginTypeWechat       // 微信
};

@interface WSUser : NSObject <NSCoding>

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *nickname;
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

@property (strong, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSString *eState;
@property (strong, nonatomic) NSString *inviteCount;
@property (strong, nonatomic) NSString *modifyTime;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *verifyCode;

@property (strong, nonatomic) NSString *phone;

@property (strong, nonatomic) NSString *thirdid; // 第三方标记

@property (strong, nonatomic) NSString *userType;  // @"1" 登录用户   @"2"游客

// 推送通知
@property (assign, nonatomic) BOOL isPushNotification;
@property (assign, nonatomic) int loginType;

// 第三方登录
@property (assign, nonatomic) NSString *uid;
@property (assign, nonatomic) NSString *profileImage;

@end
