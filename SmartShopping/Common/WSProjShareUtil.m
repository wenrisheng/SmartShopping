//
//  WSProjShareUtil.m
//  SmartShopping
//
//  Created by wrs on 15/5/26.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSProjShareUtil.h"
#import "WSShareSDKUtil.h"

@implementation WSProjShareUtil

+ (void)shareGoodsDetails:(NSDictionary *)goodsDetails
{
    NSString *title = [goodsDetails objectForKey:GOODS_NAME];
    NSString *conent = [goodsDetails objectForKey:SHOP_NAME];
    NSString *url = [goodsDetails objectForKey:GOODS_URL];
    NSString *imagePath = [goodsDetails objectForKey:GOODS_LOGO];
    NSString *description = title;

    [WSShareSDKUtil shareWithTitle:title content:conent description:description url:url imagePath:imagePath thumbImagePath:imagePath mediaType:SSPublishContentMediaTypeImage result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        //如果分享成功
        if (state == SSResponseStateSuccess) {
            NSLog(@"分享成功");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"分享成功!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        //如果分享失败
        if (state == SSResponseStateFail) {
            NSLog(@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"分享失败!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];

}

@end
