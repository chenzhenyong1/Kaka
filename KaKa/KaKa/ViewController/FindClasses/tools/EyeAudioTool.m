//
//  EyeAudioTool.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/31.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAudioTool.h"

@implementation EyeAudioTool
static NSMutableDictionary *_players;

+ (void)initialize
{
    _players = [NSMutableDictionary dictionary];
}

+ (AVAudioPlayer *)playMusicWithMusicName:(NSString *)musicName
{
    assert(musicName);
    
    // 1.定义播放器
    AVAudioPlayer *player = nil;
    
    // 2.从字典中取player,如果取出出来是空,则对应创建对应的播放器
    player = _players[musicName];
    if (player == nil) {
        // 2.1.获取对应音乐资源
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:musicName withExtension:@"m4a"];
        
        if (fileUrl == nil) return nil;
        
        // 2.2.创建对应的播放器
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        
        // 2.3.将player存入字典中
        [_players setObject:player forKey:musicName];
        
        // 2.4.准备播放
        [player prepareToPlay];
        player.numberOfLoops = -1;
    }
    
    // 3.播放音乐
    [player play];
    
    return player;
}

+ (void)pauseMusicWithMusicName:(NSString *)musicName
{
    assert(musicName);
    
    // 1.取出对应的播放
    AVAudioPlayer *player = _players[musicName];
    
    // 2.判断player是否nil
    if (player) {
        [player pause];
    }
}

+ (void)continueMusicWithMusicName:(NSString *)musicName
{
    // 1.取出对应的播放
    AVAudioPlayer *player = _players[musicName];
    player.numberOfLoops = -1;
    // 2.判断player是否nil
    if (player) {
        [player play];
        
    }

}


+ (void)stopMusicWithMusicName:(NSString *)musicName
{
    
    
    assert(musicName);
    
    // 1.取出对应的播放
    AVAudioPlayer *player = _players[musicName];
    
    // 2.判断player是否nil
    if (player) {
        [player stop];
        [_players removeObjectForKey:musicName];
        player = nil;
    }
}
@end
