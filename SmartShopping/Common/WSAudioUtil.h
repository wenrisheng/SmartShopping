//
//  SoundUtil.h
//  picker
//
//  Created by wrs on 15/6/24.
//  Copyright (c) 2015年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAudioUtil : NSObject

/**
 *  ■ 声音长度要小于 30 秒
 ■ In linear PCM 或者 IMA4 (IMA/ADPCM) 格式的
 ■ 打包成 .caf, .aif,mp3, 或者 .wav 的文件
 ■ 不能控制播放的进度
 ■ 调用方法后立即播放声音
 ■ 没有循环播放和立体声控制
 *
 *  @param resourceName resourceName description
 *  @param type         type description
 */
+ (void)playShortSoundEffectWithResourceName:(NSString *)resourceName type:(NSString *)type;

+ (void)playLongSoundEffectWithResourceName:(NSString *)resourceName type:(NSString *)type;

@end
