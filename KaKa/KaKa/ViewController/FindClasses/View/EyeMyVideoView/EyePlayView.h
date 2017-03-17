//
//  EyePlayView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^touchBlock)(void);
@interface EyePlayView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIImageView *showImageView;
/** movieView */
@property (nonatomic, strong) UIView *movieView;
@property (nonatomic, assign) NSInteger playTapCount;
/** 位置标志  */
@property (nonatomic, assign) NSInteger index;

/** 音乐名称 */
@property (nonatomic, strong) NSString *musicName;

/** 点击视频画面的回调Block */
@property (nonatomic, copy) touchBlock touchBlock;


- (void)play;
- (void)pause;
- (void)deleteVideo;

- (CGFloat)durationTime;



- (void)refreshUIWithMovieResouceUrl:(NSURL *)movieResouceUrl showImage:(UIImage *)showImage;

@end
