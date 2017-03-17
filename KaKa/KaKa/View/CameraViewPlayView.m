//
//  CameraViewPlayView.m
//  KaKa
//
//  Created by Change_pan on 16/8/16.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraViewPlayView.h"

@interface CameraViewPlayView ()

@end

@implementation CameraViewPlayView
{
//    UIImageView *playView;
    UIView *toolView;
    BOOL isShowToolView;
    AVPlayer *player;
    AVPlayerItem *playerItem;
    UIButton *play_btn;
    UISlider *progressSlider;
    UILabel *duration_lab;//总时间
    UILabel *currentTime_lab;//当前播放时间
    NSTimer *progressTimer;//定时器
    BOOL isPlaying;//是否播放
    
}


- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        _video_path = videoPath;
        [self initUI];
    }
    return self;
}

- (void)initUI
{
//    playView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 424*PSDSCALE_Y)];
//    playView.backgroundColor = [UIColor blackColor];
//    playView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//    [playView addGestureRecognizer:tap];
//    [self addSubview:playView];
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
    
    
    //
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:_video_path];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
 
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.layer addSublayer:_playerLayer];
    
    toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 359*PSDSCALE_Y, SCREEN_WIDTH, 65*PSDSCALE_Y)];
    toolView.backgroundColor = RGBSTRING(@"666666");
    toolView.alpha = 0.8;
    isShowToolView = YES;
    [self addSubview:toolView];
    
    play_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 61*PSDSCALE_X, 65*PSDSCALE_Y)];
    [play_btn setImage:GETYCIMAGE(@"camera_play_nor") forState:UIControlStateNormal];
    [play_btn setImage:GETYCIMAGE(@"camera_play_sel") forState:UIControlStateSelected];
    
    [toolView addSubview:play_btn];
    [play_btn addTarget:self action:@selector(play_btn_click:) forControlEvents:UIControlEventTouchUpInside];
    
    currentTime_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(play_btn), 22*PSDSCALE_Y, 80*PSDSCALE_X, 32*PSDSCALE_Y)];
    currentTime_lab.text = @"00:00";
    currentTime_lab.textAlignment = NSTextAlignmentLeft;
    currentTime_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    currentTime_lab.textColor = RGBSTRING(@"e0e0e0");
    [toolView addSubview:currentTime_lab];
    
    //左右轨的图片
    UIImage *stetchLeftTrack= GETNCIMAGE(@"camera_progress_line");
    UIImage *stetchRightTrack = GETNCIMAGE(@"camera_Progress_bg");
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"camera_progress_ round"];
    
    progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(VIEW_W_X(currentTime_lab)+8*PSDSCALE_X, 34*PSDSCALE_Y, 450*PSDSCALE_X, stetchLeftTrack.size.height)];
    [toolView addSubview:progressSlider];
    progressSlider.backgroundColor = [UIColor clearColor];
    
    progressSlider.value = 0;
    
    [progressSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [progressSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    
    [progressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    //滑块拖动时的事件
    [progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [progressSlider addTarget:self action:@selector(sliderUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [progressSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    duration_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(progressSlider)+12*PSDSCALE_X, 22*PSDSCALE_Y, 80*PSDSCALE_X, 32*PSDSCALE_Y)];
    duration_lab.text = @"00:00";
    duration_lab.textAlignment = NSTextAlignmentLeft;
    duration_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    duration_lab.textColor = RGBSTRING(@"e0e0e0");
    [toolView addSubview:duration_lab];
    
    //    添加 消息observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle) name:@"ON_RESIGN_ACTIVE" object:nil];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        progressSlider.value = 0;
//        player = nil;
        play_btn.selected = NO;
        isPlaying = NO;
        [weakSelf removeProgressTimer];
        currentTime_lab.text = @"00:00";
        NSTimeInterval duration = CMTimeGetSeconds(player.currentItem.duration);
        NSInteger dMin = duration / 60;
        NSInteger dSec = (NSInteger)duration % 60;
        NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
        duration_lab.text = durationString;
    }];
}

//进入
- (void)onApplicationDidBecomeActiveHandle
{
    if (!isPlaying) {
        [player play];
        isPlaying = YES;
    }
}

//退出
- (void)onApplicationWillResignActiveHandle
{
    if (isPlaying) {
        [player pause];
        isPlaying = NO;
    }
}

#pragma mark - 定时器操作
- (void)addProgressTimer
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
}



- (void)removeProgressTimer
{
    [progressTimer invalidate];
    progressTimer = nil;
}

- (void)tap
{
    if (isShowToolView)
    {
        [UIView animateWithDuration:0.3 animations:^{
            toolView.hidden = YES;
        } completion:^(BOOL finished) {
            isShowToolView = NO;
        }];
        
        
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            toolView.hidden = NO;
        } completion:^(BOOL finished) {
            isShowToolView = YES;
        }];
    }
    
    if (_delegate &&[_delegate respondsToSelector:@selector(aaaaa)]) {
        [_delegate aaaaa];
    }
    
}

-(void)play_btn_click:(UIButton *)sender
{
    sender.selected = !sender.selected;

    if (sender.selected)
    {
        [player play];
        isPlaying = YES;
        NSTimeInterval duration = CMTimeGetSeconds(player.currentItem.duration);
        NSInteger dMin = duration / 60;
        NSInteger dSec = (NSInteger)duration % 60;
        NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
        duration_lab.text = durationString;
        [self addProgressTimer];

    }
    else
    {
        [player pause];
        isPlaying = NO;
        [self removeProgressTimer];
    }
}

- (void)updateProgressInfo
{
    // 1.更新时间
    [self timeString];
    progressSlider.value = CMTimeGetSeconds(player.currentTime) / CMTimeGetSeconds(player.currentItem.duration);
    
    if(progressSlider.value == 1)
    {
        return;
    }
    
}

- (void)timeString
{
    NSTimeInterval duration = CMTimeGetSeconds(player.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(player.currentTime);
    
    NSInteger dMin = duration / 60;
    NSInteger dSec = (NSInteger)duration % 60;
    
    NSInteger cMin = currentTime / 60;
    NSInteger cSec = (NSInteger)currentTime % 60;
    
    NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
    NSString *currentString = [NSString stringWithFormat:@"%02ld:%02ld", cMin, cSec];
    
    duration_lab.text = durationString;
    currentTime_lab.text = currentString;
}



- (void)sliderValueChanged:(UISlider *)sender
{
    [self removeProgressTimer];
    if (progressSlider.value == 1) {
        progressSlider.value = 0;
    }
    NSTimeInterval currentTime = CMTimeGetSeconds(player.currentItem.duration) * progressSlider.value;
    NSTimeInterval duration = CMTimeGetSeconds(player.currentItem.duration);
    
    NSInteger dMin = duration / 60;
    NSInteger dSec = (NSInteger)duration % 60;
    
    NSInteger cMin = currentTime / 60;
    NSInteger cSec = (NSInteger)currentTime % 60;
    
    NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
    NSString *currentString = [NSString stringWithFormat:@"%02ld:%02ld", cMin, cSec];
    
    duration_lab.text = durationString;
    currentTime_lab.text = currentString;
    
    [self addProgressTimer];
}

- (void)sliderUpInside:(UISlider *)sender
{
    NSTimeInterval currentTime = CMTimeGetSeconds(player.currentItem.duration) * progressSlider.value;
    [player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)sliderTouchDown:(UISlider *)sender
{
    [self removeProgressTimer];
}


@end
