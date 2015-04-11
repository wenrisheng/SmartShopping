//
//  ASIHttpWrap.h
//  CTWeMedia
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol ServiceDelegate <NSObject>

- (void)requestSucess:(id)result tag:(int)tag;

- (void)requestFail:(id)error tag:(int)tag;

@end

@interface Service : NSObject

@property (weak, nonatomic) id<ServiceDelegate> delegate;

- (void)get:(NSString *)url tag:(int)tag;

- (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag;

@end
