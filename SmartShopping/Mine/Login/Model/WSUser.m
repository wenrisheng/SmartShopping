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
        self.cityId = [coder decodeObjectForKey:@"cityId"];
        self.cityName = [coder decodeObjectForKey:@"cityName"];
        self.eState = [coder decodeObjectForKey:@"eState"];
        self.provinceId = [coder decodeObjectForKey:@"provinceId"];
        self.provinceName = [coder decodeObjectForKey:@"provinceName"];
        self.roleid = [coder decodeObjectForKey:@"roleid"];
        self.sysRole = [coder decodeObjectForKey:@"sysRole"];
        self.createTime = [coder decodeObjectForKey:@"createTime"];
        self.inviteCount = [coder decodeObjectForKey:@"inviteCount"];
        self.modifyTime = [coder decodeObjectForKey:@"modifyTime"];
        self.status = [coder decodeObjectForKey:@"status"];
        self.verifyCode = [coder decodeObjectForKey:@"verifyCode"];
        self.phone = [coder decodeObjectForKey:@"phone"];
        self.thirdid = [coder decodeObjectForKey:@"thirdid"];
        self.userType = [coder decodeObjectForKey:@"userType"];
        self.loginType = [coder decodeObjectForKey:@"loginType"];
        self.uid = [coder decodeObjectForKey:@"uid"];
        self.profileImage = [coder decodeObjectForKey:@"profileImage"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:__id forKey:@"_id"];
    [coder encodeObject:_username forKey:@"username"];
    [coder encodeObject:_password forKey:@"password"];
    [coder encodeObject:_nickname forKey:@"nickname"];
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
    [coder encodeObject:_cityId forKey:@"cityId"];
    [coder encodeObject:_cityName forKey:@"cityName"];
    [coder encodeObject:_eState forKey:@"eState"];
    [coder encodeObject:_provinceId forKey:@"provinceId"];
    [coder encodeObject:_provinceName forKey:@"provinceName"];
    [coder encodeObject:_roleid forKey:@"roleid"];
    [coder encodeObject:_sysRole forKey:@"sysRole"];
    [coder encodeObject:_createTime forKey:@"createTime"];
    [coder encodeObject:_inviteCount forKey:@"inviteCount"];
    [coder encodeObject:_modifyTime forKey:@"modifyTime"];
    [coder encodeObject:_status forKey:@"status"];
    [coder encodeObject:_verifyCode forKey:@"verifyCode"];
    [coder encodeObject:_phone forKey:@"phone"];
    [coder encodeObject:_thirdid forKey:@"thirdid"];
    [coder encodeObject:_userType forKey:@"userType"];
    [coder encodeObject:_loginType forKey:@"loginType"];
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
