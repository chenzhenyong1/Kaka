//
//  EyePlayView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyePlayView.h"
#import "EyeAudioTool.h"

@interface EyePlayView ()

/** 视频等待菊花 */
@property (nonatomic, strong)  UIActivityIndicatorView* activityIndicatorView;


@end

@implementation EyePlayView


- (void)dealloc
{
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    if (self.musicName) {
        
        [EyeAudioTool stopMusicWithMusicName:self.musicName];
    }
    ZYLog(@"EyePlayView  dealloc");
}


#pragma mark -- inherit
- (void)layoutSubviews{
    [super layoutSubviews];
    
   self.playerLayer.frame = self.movieView.bounds;
}
#pragma mark -- life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        
        [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);

        }];
        
        [self.movieView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self);
            
        }];
        
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self.movieView);
            
        }];
        
    }
    return self;
}

#pragma mark -- public
- (void)refreshUIWithMovieResouceUrl:(NSURL *)movieResouceUrl showImage:(UIImage *)showImage{
    
    if (self.musicName) {
        
        [EyeAudioTool stopMusicWithMusicName:self.musicName];
    }
    
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    self.player = [AVPlayer playerWithURL:movieResouceUrl];
    self.playerLayer.player = self.player;
    [self.movieView.layer addSublayer:self.playerLayer];
    
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
//    //添加视频异常中断通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
//    //进入后台
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBcakground:) name:UIApplicationWillResignActiveNotification object:self.player.currentItem];
//    //返回前台
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterPlayGround:) name:UIApplicationWillResignActiveNotification object:self.player.currentItem];
    
    
    self.showImageView.image = showImage;
    [self.showImageView sizeToFit];
    [self bringSubviewToFront:self.showImageView];
}
//视频播放结束通知
- (void)moviePlayDidEnd:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        weakSelf.playTapCount ++;
        if (self.musicName) {
            
            [EyeAudioTool stopMusicWithMusicName:self.musicName];
            [EyeAudioTool playMusicWithMusicName:self.musicName];
            [EyeAudioTool pauseMusicWithMusicName:self.musicName];
        }
    }];
}
//添加视频异常中断通知
- (void)moviePlayPlaybackStalled:(NSNotification *)notification{

    ZYLog(@"视频异常中断通知");
    
}
//进入后台
- (void)enterBcakground:(NSNotification *)notification{
    ZYLog(@"进入后台");
    [self pause];
    
}
//返回前台
- (void)enterPlayGround:(NSNotification *)notification{
    
    [self play];
    ZYLog(@"返回前台");
    
}


- (void)play{
    [self.player play];
    self.showImageView.hidden = YES;
     [self.activityIndicatorView startAnimating];
    if (self.player.status == AVPlayerStatusReadyToPlay && self.musicName) {
        [self.activityIndicatorView stopAnimating];
        if (self.musicName) {
            
            [EyeAudioTool playMusicWithMusicName:self.musicName];
        }
    }
}

- (void)pause{
    [self.player pause];
    
    self.showImageView.hidden = NO;
    if (self.musicName) {
        [EyeAudioTool pauseMusicWithMusicName:self.musicName];
    }
    
}

-(void)deleteVideo
{
    [self removeFromSuperview];
    if (self.musicName) {
        
       [EyeAudioTool stopMusicWithMusicName:self.musicName];
    }
}

-(CGFloat)durationTime
{
    return  (self.player.currentItem.duration.value + 0.0) /self.player.currentItem.duration.timescale;
    
}

#pragma mark - 观察者对应的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
       
        
        if (AVPlayerItemStatusReadyToPlay == status) {
            
            [self.activityIndicatorView stopAnimating];
            
            if (self.showImageView.hidden == YES) {
                
                //播放音乐
                [EyeAudioTool playMusicWithMusicName:self.musicName];
                
            }
            ZYLog(@"observeValueForKeyPath AVPlayerItemStatusReadyToPlay");
            
        }else if (AVPlayerItemStatusUnknown == status){
            
        
        }else if (AVPlayerItemStatusFailed == status){
            
        
        }
    }
}


#pragma mark -- events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 这里就自己判断什么情况暂停了，我这里就根据点击次数来判断了
    if (self.touchBlock) {
         self.touchBlock();
    }
//    self.touchBlock();
    
    if ([self.activityIndicatorView isAnimating]) {
        return;
    }
    
    self.playTapCount++;
    
}

-(void)setPlayTapCount:(NSInteger)playTapCount
{
    _playTapCount = playTapCount;
    if (self.showImageView.hidden == YES){
        
        [self pause];
    }else{

        [self play];
        
    }
//    ZYLog(@"%@",@(self.playTapCount));
}



#pragma mark -- properties
-(void)setMusicName:(NSString *)musicName
{
    self.playTapCount ++;
    
    if (_musicName) {
        
        [EyeAudioTool stopMusicWithMusicName:_musicName];
    }

    _musicName = musicName;
    ZYLog(@"musicName = %@",musicName);
    
    [self play];
    
}

-(UIImageView *)showImageView
{
    if (!_showImageView){
        UIImageView *showImageView = [[UIImageView alloc] init];
        showImageView.contentMode = UIViewContentModeCenter;
        showImageView.clipsToBounds = YES;
        
        [self addSubview:showImageView];
        _showImageView = showImageView;
    }
    return _showImageView;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer){
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

-(UIView *)movieView
{
    if (!_movieView){
        UIView *movieView = [[UIView alloc] init];
        movieView.backgroundColor = [UIColor blackColor];
        movieView.frame = self.bounds;
        [self addSubview:movieView];
        
        _movieView = movieView;
        
    }
    return _movieView;

}

-(UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
        _activityIndicatorView.hidesWhenStopped= NO;
        
        [self.movieView addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}


@end
