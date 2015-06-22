//
//  ASIHttpWrap.h
//  CTWeMedia
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define ASIHTTPWRAP_TIMEOUT_DEFAULT     5   //默认超时

typedef void(^ServiceSucCallBack)(id result);
typedef void(^ServiceFailCallBack)(id error);

@protocol ServiceDelegate <NSObject>

- (void)requestSucess:(id)result tag:(int)tag;

- (void)requestFail:(id)error tag:(int)tag;

@end

@interface WSService : NSObject

@property (assign, nonatomic) id<ServiceDelegate> delegate;
@property (strong, nonatomic) ServiceSucCallBack serviceSucCallBack;
@property (strong, nonatomic) ServiceFailCallBack serviceFailCallBack;

- (void)get:(NSString *)url tag:(int)tag;

- (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag;

- (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag sucCallBack:(void (^)(id result))sucCallBack failCallBack:(void (^)(id error))failCallBack;

+ (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag sucCallBack:(void (^)(id result))sucCallBack failCallBack:(void (^)(id error))failCallBack showMessage:(BOOL)showMessage;

@end
