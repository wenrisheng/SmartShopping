//
//  WSUser.m
//  SmartShopping
//
//  Created by wrs on 15/4/18.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSUser.h"

@implementation WSUser

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self._id = [coder decodeObjectForKey:@"_id"];
        self.username = [coder decodeObjectForKey:@"username"];
        self.password = [coder decodeObjectForKey:@"password"];
        self.nickname = [coder decodeObjectForKey:@"nickname"];
        self.inviteCode = [coder decodeObjectForKey:@"inviteCode"];
        self.byInviteCode = [coder decodeObjectForKey:@"byInviteCode"];
        self.email = [coder decodeObjectForKey:@"email"];
        self.sex = [coder decodeObjectForKey:@"sex"];
        self.age = [coder decodeObjectForKey:@"age"];
        self.beanNumber = [coder decodeObjectForKey:@"beanNumber"];
        self.longitude = [coder decodeObjectForKey:@"longitude"];
        self.latitude = [coder decodeObjectForKey:@"latitude"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.logoPath = [coder decodeObjectForKey:@"logoPath"];
        self.createTime = [coder decodeObjectForKey:@"createTime"];
        self.eState = [coder decodeObjectForKey:@"eState"];
        self.inviteCount = [coder decodeObjectForKey:@"inviteCount"];
        self.status = [coder decodeObjectForKey:@"status"];
        self.verifyCode = [coder decodeObjectForKey:@"verifyCode"];
        self.phone = [coder decodeObjectForKey:@"phone"];
        
        self.userType = [coder decodeObjectForKey:@"userType"];
        
        self.isPushNotification = [[coder decodeObjectForKey:@"isPushNotification"] boolValue];
        self.loginType = [[coder decodeObjectForKey:@"logniType"] intValue];
        self.uid = [coder decodeObjectForKey:@"loginType"];
        self.profileImage = [coder decodeObjectForKey:@"profileImage"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:__id forKey:@"_id"];
    [coder encodeObject:_username forKey:@"username"];
    [coder encodeObject:_password forKey:@"password"];
    [coder encodeObject:_nickname forKey:@"Nickname"];
    [coder encodeObject:_inviteCode forKey:@"inviteCode"];
    [coder encodeObject:_byInviteCode forKey:@"byInviteCode"];
    [coder encodeObject:_email forKey:@"email"];
    [coder encodeObject:_sex forKey:@"sex"];
    [coder encodeObject:_age forKey:@"age"];
    [coder encodeObject:_beanNumber forKey:@"beanNumber"];
    [coder encodeObject:_longitude forKey:@"longitude"];
    [coder encodeObject:_latitude forKey:@"latitude"];
    [coder encodeObject:_birthday forKey:@"birthday"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_logoPath forKey:@"logoPath"];
    [coder encodeObject:_createTime forKey:@"createTime"];
    [coder encodeObject:_eState forKey:@"eState"];
    [coder encodeObject:_inviteCount forKey:@"inviteCount"];
    [coder encodeObject:_status forKey:@"status"];
    [coder encodeObject:_verifyCode forKey:@"verifyCode"];
    [coder encodeObject:_phone forKey:@"phone"];
    
    [coder encodeObject:_userType forKey:@"userType"];
    
    [coder encodeObject:[NSNumber numberWithBool:_isPushNotification] forKey:@"isPushNotification"];
    
    [coder encodeObject:[NSNumber numberWithInt:_loginType] forKey:@"loginType"];
    [coder encodeObject:_uid forKey:@"uid"];
    [coder encodeObject:_profileImage forKey:@"profileImage"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self._id = value;
    }
}

@end
