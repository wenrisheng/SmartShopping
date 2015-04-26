//
//  ASIHttpWrap.m
//  CTWeMedia
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSService.h"
#import "ASIFormDataRequest.h"

@interface WSService () <ASIHTTPRequestDelegate>

@end

@implementation WSService

-(void)get:(NSString *)url tag:(int)tag
{
    
#ifdef DEBUG
    NSLog(@"request GET url:%@ \n tag:%d", url, tag);
#endif
    
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIHTTPRequest *request = nil;
    request = [ASIHTTPRequest requestWithURL:nsUrl];
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    request.delegate = self;
    request.tag = tag;
    [request startAsynchronous];
}


- (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag
{
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsUrl];
    request.tag = tag;
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    [request setDelegate:self];
    NSArray *allKeys = [dataDic allKeys];
    for(id key in allKeys)
    {
        id value = [dataDic valueForKey:key];
        value = value == nil ? @"" : value;
        [request setPostValue:value forKey:(NSString *)key];
    }
    [request buildPostBody];
    
#ifdef DEBUG
    NSString * str = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
    DLog(@"request \n { \n  url:%@, \n  tag:%d,\n  postbody:%@\n }", url, tag, str);
#endif
    [request startAsynchronous];

}

- (void)requestFinished:(ASIHTTPRequest *)request;

{
    NSData *responseData = [request responseData];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    
    // 调试打印响应数据
#ifdef DEBUG
    NSArray *allKeys = [resultDic allKeys];
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    [resultStr appendString:@"*********request result:\n"];
    [resultStr appendString:@"{\n"];
    for (id key in allKeys) {
        [resultStr appendString:[NSString stringWithFormat:@"%@:%@,\n", key, [resultDic objectForKey:key]]];
    }
    [resultStr appendString:@"}\n"];
    [resultStr appendString:@"*********************\n"];
    DLog(@"%@", resultStr);
#endif
    
    // 块回调
    if (_serviceSucCallBack) {
        _serviceSucCallBack(resultDic);
    }
    
    // 代理回调
    if ([_delegate respondsToSelector:@selector(requestSucess:tag:)]) {
        NSError *error = [request error];
        if (!error) {
            [_delegate requestSucess:resultDic tag:(int)request.tag];
        } else {
#ifdef DEBUG
            NSLog(@"response result Error! url:%@ \n tag:%d result:%@\n", [NSString stringWithContentsOfURL:request.url encoding:NSUTF8StringEncoding error:nil], (int)request.tag, request.responseString);
#endif
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request;
{
    // 块回调
    if (_serviceFailCallBack) {
        _serviceFailCallBack(nil);
    }
    
    // 代理回调
    if ([_delegate respondsToSelector:@selector(requestFail:tag:)]) {
        [_delegate requestFail:nil tag:(int)request.tag];
    }
}


@end
