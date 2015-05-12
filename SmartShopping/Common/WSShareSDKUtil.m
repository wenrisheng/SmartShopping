//
//  WSShareSDKUtil.m
//  SmartShopping
//
//  Created by wrs on 15/5/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSShareSDKUtil.h"

@implementation WSShareSDKUtil

+ (void)shareWithTitle:(NSString *)title content:(NSString *)content description:(NSString *)description url:(NSString *)url imagePath:(NSString *)imagePath thumbImagePath:(NSString *)thumbImagePath result:(SSPublishContentEventHandler)result
{
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:content
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:title
                                                  url:url
                                          description:description
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //以下信息为特定平台需要定义分享内容，如果不需要可省略下面的添加方法
    //定制QQ分享信息
    [publishContent addQQUnitWithType:INHERIT_VALUE
                              content:INHERIT_VALUE
                                title:INHERIT_VALUE
                                  url:INHERIT_VALUE
                                image:INHERIT_VALUE];
    
    //定制QQ空间信息
    [publishContent addQQSpaceUnitWithTitle:INHERIT_VALUE
                                        url:INHERIT_VALUE
                                       site:nil
                                    fromUrl:nil
                                    comment:INHERIT_VALUE
                                    summary:INHERIT_VALUE
                                      image:INHERIT_VALUE
                                       type:INHERIT_VALUE
                                    playUrl:nil
                                       nswb:nil];
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                         content:INHERIT_VALUE
                                           title:INHERIT_VALUE
                                             url:INHERIT_VALUE
                                      thumbImage:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:INHERIT_VALUE
                                          content:INHERIT_VALUE
                                            title:INHERIT_VALUE
                                              url:INHERIT_VALUE
                                       thumbImage:INHERIT_VALUE
                                            image:INHERIT_VALUE
                                     musicFileUrl:INHERIT_VALUE
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    [publishContent addSinaWeiboUnitWithContent:INHERIT_VALUE image:INHERIT_VALUE];
    
    
    
    if ([[UIDevice currentDevice].systemVersion versionStringCompare:@"7.0"] != NSOrderedAscending)
    {
        //7.0以上只允许发文字，定义Line信息
        [publishContent addLineUnitWithContent:INHERIT_VALUE
                                         image:nil];
    }
    
    //结束定制信息
    
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:nil arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (result) {
                                    result(type, state,statusInfo, error, end);
                                }
    }];
}

@end
