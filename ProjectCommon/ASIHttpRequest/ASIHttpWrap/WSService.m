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

- (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag sucCallBack:(void (^)(id))sucCallBack failCallBack:(void (^)(id))failCallBack
{
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsUrl];
    request.tag = tag;
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    NSArray *allKeys = [dataDic allKeys];
    
    // 当入参value为nil时改为@""
    for(id key in allKeys)
    {
        id value = [dataDic valueForKey:key];
        value = value == nil ? @"" : value;
        [request setPostValue:value forKey:(NSString *)key];
    }
    [request buildPostBody];
    
    // 调试 打印请求url及入参
#ifdef DEBUG
    NSString * str = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
    DLog(@"request \n { \n  url:%@, \n  tag:%d,\n  postbody:%@\n }", url, tag, str);
    DLog(@"request URL:%@", [NSString stringWithFormat:@"%@?%@", url, str])

#endif
    __weak ASIFormDataRequest *weakRequest = request;
    // 请求完成
    [request setCompletionBlock:^{
        
        NSData *responseData = [weakRequest responseData];
        NSError *jsonError = nil;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
        
        // 调试打印响应数据
#ifdef DEBUG
        NSString * str = [[NSString alloc] initWithData:[weakRequest postBody] encoding:NSUTF8StringEncoding];
        DLog(@"request \n { \n  url:%@, \n  tag:%d,\n  postbody:%@\n }", url, tag, str);
        DLog(@"request URL:%@", [NSString stringWithFormat:@"%@?%@", url, str])
        NSError *requestError = weakRequest.error;
        if (requestError) {
            DLog(@"requstError:%@", requestError);
        }
        if (jsonError) {
            DLog(@"JSON 解析失败:%@", jsonError);
        }
        NSArray *allKeys = [resultDic allKeys];
        NSMutableString *resultStr = [[NSMutableString alloc] init];
        [resultStr appendString:[NSString stringWithFormat:@"*********request  %d result:\n", (int)weakRequest.tag]];
        [resultStr appendString:@"{\n"];
        for (id key in allKeys) {
            [resultStr appendString:[NSString stringWithFormat:@"%@:%@,\n", key, [resultDic objectForKey:key]]];
        }
        [resultStr appendString:@"}\n"];
        [resultStr appendString:@"*********************\n"];
        DLog(@"%@", resultStr);
#endif
        
        // 成功回调
        if (sucCallBack) {
            sucCallBack(resultDic);
        }
    }];
    
    // 请求失败
    [request setFailedBlock:^{
        
    // 调试 打印请求错误
#ifdef  DEBUG
        NSLog(@"request result Error! url:%@ \n tag:%d error:%@\n", [NSString stringWithContentsOfURL:weakRequest.url encoding:NSUTF8StringEncoding error:nil], (int)weakRequest.tag, weakRequest.error);
#endif
        
        // 请求错误回调
        if (failCallBack) {
            failCallBack(weakRequest.error);
        }
    }];
    
    // 开始异步请求
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
#ifdef  DEBUG
     NSLog(@"request result Error! url:%@ \n tag:%d error:%@\n", [NSString stringWithContentsOfURL:request.url encoding:NSUTF8StringEncoding error:nil], (int)request.tag, request.error);
#endif
    // 块回调
    if (_serviceFailCallBack) {
        _serviceFailCallBack(request.error);
    }
    
    // 代理回调
    if ([_delegate respondsToSelector:@selector(requestFail:tag:)]) {
        [_delegate requestFail:request.error tag:(int)request.tag];
    }
}

+ (void)post:(NSString *)url data:(NSDictionary *)dataDic tag:(int)tag sucCallBack:(void (^)(id result))sucCallBack failCallBack:(void (^)(id error))failCallBack showMessage:(BOOL)showMessage;
{
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsUrl];
    request.tag = tag;
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    NSArray *allKeys = [dataDic allKeys];
    
    // 当入参value为nil时改为@""
    for(id key in allKeys)
    {
        id value = [dataDic valueForKey:key];
        value = value == nil ? @"" : value;
        [request setPostValue:value forKey:(NSString *)key];
    }
    [request buildPostBody];
    
    // 调试 打印请求url及入参
#ifdef DEBUG
    NSString * str = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
    DLog(@"request \n { \n  url:%@, \n  tag:%d,\n  postbody:%@\n }", url, tag, str);
    DLog(@"request URL:%@", [NSString stringWithFormat:@"%@?%@", url, str])
#endif
    __weak ASIFormDataRequest *respRequest = request;
    // 请求完成
    [request setCompletionBlock:^{
        if (showMessage) {
            [SVProgressHUD dismiss];
        }
        NSData *responseData = [respRequest responseData];
        NSError *jsonError = nil;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
        
        // 调试打印响应数据
#ifdef DEBUG
        NSString * str = [[NSString alloc] initWithData:[respRequest postBody] encoding:NSUTF8StringEncoding];
        DLog(@"request \n { \n  url:%@, \n  tag:%d,\n  postbody:%@\n }", url, tag, str);
        DLog(@"request URL:%@", [NSString stringWithFormat:@"%@?%@", url, str])
        NSError *requestError = respRequest.error;
        if (requestError) {
            DLog(@"requstError:%@", requestError);
        }
        if (jsonError) {
            DLog(@"JSON 解析失败:%@", jsonError);
        }
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
        
        // 成功回调
        if (sucCallBack) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 sucCallBack(resultDic);
            });
           
        }
    }];
    
    // 请求失败
    [request setFailedBlock:^{
        if (showMessage) {
            [SVProgressHUD dismissWithError:@"加载失败！" afterDelay:TOAST_VIEW_TIME];
            //[SVProgressHUD dismiss];
        }
       
        // 调试 打印请求错误
#ifdef  DEBUG
        NSLog(@"request result Error! url:%@ \n tag:%d error:%@\n", [NSString stringWithContentsOfURL:respRequest.url encoding:NSUTF8StringEncoding error:nil], (int)respRequest.tag, respRequest.error);
#endif
        
        // 请求错误回调
        if (failCallBack) {
            failCallBack(respRequest.error);
        }
    }];
    if (showMessage) {
        [SVProgressHUD showWithStatus:@"加载中……"];
    }
    // 开始异步请求
    [request startAsynchronous];
}


@end
