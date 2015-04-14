//
//  ASIHttpWrap.m
//  CTWeMedia
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "ASIHttpWrap.h"
#import "ASIFormDataRequest.h"

#define ASIHTTPWRAP_TIMEOUT_DEFAULT     10   //默认超时

@interface Service () <ASIHTTPRequestDelegate>

@end

@implementation Service

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
    
#ifdef DEBUG
    NSLog(@"request post url:%@ \n tag:%d", url, tag);
#endif
    
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:nsUrl];
    request.tag = tag;
    [request setTimeOutSeconds:ASIHTTPWRAP_TIMEOUT_DEFAULT];
    [request setDelegate:self];
    for(id key in [dataDic allKeys])
    {
        [request setPostValue:[dataDic objectForKey:key] forKey:(NSString *)key];
    }
    [request buildPostBody];
    
#ifdef DEBUG
    NSString * str = [[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
    NSLog(@"PostBody %@",str);
#endif
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request;

{
    if ([_delegate respondsToSelector:@selector(requestSucess:tag:)]) {
        NSData *responseData = [request responseData];
        NSError *error = [[NSError alloc] init];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
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
    if ([_delegate respondsToSelector:@selector(requestFail:tag:)]) {
        [_delegate requestFail:nil tag:(int)request.tag];
    }
}


@end
