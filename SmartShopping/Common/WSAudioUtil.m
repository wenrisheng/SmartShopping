//
//  WSAudioUtil.m
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSAudioUtil.h"
#import <AVFoundation/AVFoundation.h>

@implementation WSAudioUtil

+ (void)playWithFileName:(NSString *)fileName type:(NSString *)type
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    [player play];
}

@end
