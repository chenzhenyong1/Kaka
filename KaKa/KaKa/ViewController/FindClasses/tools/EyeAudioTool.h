//
//  EyeAudioTool.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/31.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface EyeAudioTool : NSObject

// 播放音乐 musicName : 音乐的名称
+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName;
// 暂停音乐 musicName : 音乐的名称
+ (void)pauseMusicWithMusicName:(NSString *)musicName;
// 停止音乐 musicName : 音乐的名称
+ (void)stopMusicWithMusicName:(NSString *)musicName;
+ (void)continueMusicWithMusicName:(NSString *)musicName;
@end
