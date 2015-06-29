//
//  SoundUtil.m
//  picker
//
//  Created by wrs on 15/6/24.
//  Copyright (c) 2015年 Sylar. All rights reserved.
//

#import "WSAudioUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation WSAudioUtil

+ (void)playShortSoundEffectWithResourceName:(NSString *)resourceName type:(NSString *)type
{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

+ (void)playLongSoundEffectWithResourceName:(NSString *)resourceName type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
    NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:path];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    [player prepareToPlay];
    [player play];
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
