//
//  CameraVideoPlayer.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/15.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraVideoPlayer.h"
#import "CameraListModel.h"
#import "ZipArchive.h"
#import "MyTools.h"
#import "iCarousel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define kPollingInterval 1.0/30

@interface  CameraVideoPlayer ()<iCarouselDataSource, iCarouselDelegate, XKFFmpegPlayerDelegate>
{
    
    BOOL isPlaying;
    
    UIButton *_startPlayBtn;
    NSTimer *progressTimer;//定时器
}
// 是否是直播
@property (nonatomic, assign) BOOL isLive;

@property (nonatomic, strong) UIButton *back_LiveShow_btn;

@property (nonatomic, strong) iCarousel *carousel;

@property (nonatomic, strong) UIImageView *valueBg;
@property (nonatomic, strong) UILabel *valueLabel;

// 开始时间
@property (nonatomic, strong) NSString *startTime;
// 结束时间
@property (nonatomic, strong) NSString *endTime;

@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;

@property (nonatomic, strong) NSMutableArray *allZip_Array;

@end

@implementation CameraVideoPlayer
{
    NSString *_mac_address;
    NSMutableArray *download_arr;
}

- (void)dealloc {
    if (_ffmpegPlayer) {
        _ffmpegPlayer = nil;
    }
    
}

-(iCarousel *)carousel
{
    if (_carousel == nil) {
        _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0,NAVIGATIONBARHEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-TABBARHEIGHT)];
        _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _carousel.type = iCarouselTypeCoverFlow2;
        _carousel.delegate = self;
        _carousel.dataSource = self;
    }
    return _carousel;
}
- (id)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _isLive = YES;
        _videoURLStr = videoURLStr;
        
        self.userInteractionEnabled = YES;
        
        [self createUI];
//
//        // 获取可播放视频列表
        [self getVideoList];
    }
    
    return self;
    
}

- (XKFFmpegPlayer *)ffmpegPlayer {
    if (!_ffmpegPlayer) {
        _ffmpegPlayer = [[XKFFmpegPlayer alloc] init];
        _ffmpegPlayer.outputWidth = VIEW_W(self);
        _ffmpegPlayer.outputHeight = VIEW_H(self);
    }
    
    return _ffmpegPlayer;
}

- (void)initPlayer {
    
    if ([self.subviews indexOfObject:_startPlayBtn] != NSNotFound) {
        return;
    }

    if (_ffmpegPlayer) {
        _ffmpegPlayer = nil;
    }
    
    NSString *path = _videoURLStr;
    if (!_isLive) {
        path = _videoLiveRecUrlStr;
    }
    [self.videoIndicatorView startAnimating];
    [self.ffmpegPlayer load:path delegate:self];
}

- (void)setImage:(UIImage *)image {
    
    if (image) {
        [self.videoIndicatorView stopAnimating];
        [super setImage:image];
    }
}

// 获取可播放视频列表
- (void)getVideoList {
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"03";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
    
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
        
        NSString *url = [NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url, msg.msgBody];
        [RequestManager getRequestWithUrlString:url params:nil succeed:^(id responseObject) {
            
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            MMLog(@"dic = %@", dic);

            NSArray *mp4Array = VALUEFORKEY(VALUEFORKEY(dic, @"cdrIndex"), @"jpg");
            if ([mp4Array isKindOfClass:[NSArray class]])
            {
                // 对数据进行从大到小排序
                mp4Array = [mp4Array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                    
                    NSString *fileName1 = [[FORMATSTRING(VALUEFORKEY(obj1, @"fileName")) componentsSeparatedByString:@"."] firstObject];
                    NSNumber *number1 = [NSNumber numberWithLongLong:[fileName1 longLongValue]];
                    
                    NSString *fileName2 = [[FORMATSTRING(VALUEFORKEY(obj2, @"fileName")) componentsSeparatedByString:@"."] firstObject];
                    NSNumber *number2 = [NSNumber numberWithLongLong:[fileName2 longLongValue]];
                    
                    NSComparisonResult result = [number1 compare:number2];
                    
                    return (result == NSOrderedDescending); // 升序
                }];
                
                weakSelf.allZip_Array = [mp4Array mutableCopy];
                weakSelf.startTime = FORMATSTRING(VALUEFORKEY([weakSelf.allZip_Array firstObject], @"fileName"));
                weakSelf.startTime = [[weakSelf.startTime componentsSeparatedByString:@"."] firstObject];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyyMMddHHmmss"];
                NSDate *startDate = [formatter dateFromString:weakSelf.startTime];
                // 转时间戳
                NSTimeInterval startTimeInterval = (long)[startDate timeIntervalSince1970];
                weakSelf.startTime = [NSString stringWithFormat:@"%.0f", startTimeInterval];
                
                weakSelf.endTime = FORMATSTRING(VALUEFORKEY([mp4Array lastObject], @"fileName"));
                weakSelf.endTime = [[weakSelf.endTime componentsSeparatedByString:@"."] firstObject];
                NSDate *endDate = [formatter dateFromString:weakSelf.endTime];
                NSTimeInterval endTimeInterval = (long)[endDate timeIntervalSince1970];
                // 时长
                // 每张图片表示时长20s
                NSTimeInterval timeLast = 20;
                endTimeInterval = [weakSelf.startTime longLongValue] + timeLast*([weakSelf.allZip_Array count]-1);
                weakSelf.endTime = [NSString stringWithFormat:@"%.0f", endTimeInterval];
            }
           
            
//            NSString *bgImage = FORMATSTRING(VALUEFORKEY([mp4Array lastObject], @"fileName"));
//            [SettingConfig shareInstance].currentCameraModel.bgImage = bgImage;
//            [CacheTool updateCameraListWithCameraListModel:[SettingConfig shareInstance].currentCameraModel];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{ // 2
//                [NotificationCenter postNotificationName:@"CameraListNeedToReloadDataNoti" object:nil];
//            });
//            
            
            
        } andFailed:^(NSError *error) {
            
        }];

    }];
}

- (void)createUI {
    
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.userInteractionEnabled = YES;
    _allZip_Array = [NSMutableArray array];
    CameraListModel *model = [SettingConfig shareInstance].currentCameraModel;
    _mac_address = model.macAddress;
    
    download_arr = [NSMutableArray array];
    
    
    // 菊花
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _videoIndicatorView = indicatorView;
    // 添加视频菊花
    [self addSubview:self.videoIndicatorView];
    [self.videoIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(-5);
    }];
    
    // 顶部的视图
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.topView.userInteractionEnabled = YES;
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(NAVIGATIONBARHEIGHT);
        make.top.equalTo(self).with.offset(0);
    }];
    
    // 返回按钮
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.showsTouchWhenHighlighted = YES;
    [_backButton addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImage:[UIImage imageNamed:@"me_back"] forState:UIControlStateNormal];
    [self.topView addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self).with.offset(STATUSBARHEIGHT + 5);
        make.width.mas_equalTo(30);
    }];
    
    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"咔咔";
    [self.topView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView.mas_left).with.offset(100);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.topView.mas_top).with.offset(STATUSBARHEIGHT);
        make.right.mas_equalTo(self.topView.mas_right).with.offset(-100);
    }];
    
    //返回直播按钮
    _back_LiveShow_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _back_LiveShow_btn.adjustsImageWhenHighlighted = NO;
    _back_LiveShow_btn.hidden = YES;
    [_back_LiveShow_btn addTarget:self action:@selector(back_LiveShow_click) forControlEvents:UIControlEventTouchUpInside];
    [_back_LiveShow_btn setTitle:@"回到直播" forState:UIControlStateNormal];
    _back_LiveShow_btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_back_LiveShow_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topView addSubview:_back_LiveShow_btn];
    [_back_LiveShow_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self).with.offset(STATUSBARHEIGHT + 5);
        make.width.mas_equalTo(130);
    }];
    
    // 开始播放按钮
    UIImage *startPlayImage = GETNCIMAGE(@"camera_play.png");
    _startPlayBtn = [[UIButton alloc] init];
    [_startPlayBtn setImage:startPlayImage forState:UIControlStateNormal];
    [_startPlayBtn addTarget:self action:@selector(startPlayBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_startPlayBtn];
    [_startPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(-5);
        make.width.mas_equalTo(startPlayImage.size.width);
        make.height.mas_equalTo(startPlayImage.size.height);
    }];
    
    // 底部视图
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.bottomView.userInteractionEnabled = YES;
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self).with.offset(0);
    }];
    
    //_playOrPauseBtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:GETNCIMAGE(@"video_play.png") forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:GETNCIMAGE(@"video_play.png") forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    //autoLayout _playOrPauseBtn
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(10);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomView.mas_bottom).with.offset(-2);
        make.width.mas_equalTo(40);
        
    }];
    
    // 开始时间label
    _startTimeLabel = [[UILabel alloc] init];
    _startTimeLabel.textAlignment = NSTextAlignmentCenter;
    _startTimeLabel.textColor = [UIColor whiteColor];
    _startTimeLabel.font = [UIFont systemFontOfSize:20 * FONTCALE_Y];
    _startTimeLabel.text = @"00:00";
    [self.bottomView addSubview:_startTimeLabel];
    [_startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(42);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(45);
    }];
    
    // 结束时间label
    _endTimeLabel = [[UILabel alloc] init];
    _endTimeLabel.textColor = [UIColor whiteColor];
    _endTimeLabel.font = [UIFont systemFontOfSize:20 * FONTCALE_Y];
    _endTimeLabel.text = @"00:00";
    [self.bottomView addSubview:_endTimeLabel];
    [_endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_right).with.offset(-90);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(55);
    }];
    
    //slider
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:GETNCIMAGE(@"video_slider_dot.png") forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor whiteColor];
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    self.progressSlider.value = 1.0;
    self.progressSlider.continuous = YES ;
    [self.bottomView addSubview:self.progressSlider];
    

    

//    [self.bottomView addSubview:_valueLabel];
//    _valueLabel.hidden = YES;

    
    //autoLayout slider
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(89);
        make.right.equalTo(self.bottomView).with.offset(-96);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.bottomView).with.offset(0);
    }];
    
    //_fullScreenBtn
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:GETNCIMAGE(@"video_fullscreen.png") forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:GETNCIMAGE(@"video_fullscreen.png") forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    //autoLayout fullScreenBtn
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(-10);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(44);
        
    }];
    
    // 单击的 Recognizer
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.enabled = NO;
    [self addGestureRecognizer:singleTap];
    self.singleTap = singleTap;
    
}


/**
 点击回到直播
 */
- (void)back_LiveShow_click
{
    if (self.carousel) {
        
        [self.carousel removeFromSuperview];
        self.carousel = nil;
        
    }
    
    _isLive = YES;
    _valueLabel.hidden = YES;
    [_ffmpegPlayer pause];
    [_ffmpegPlayer stop];
    _ffmpegPlayer = nil;
    self.image = nil;
    [self.videoIndicatorView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 重新加载播放器
        [self removeProgressTimer];
        [self.ffmpegPlayer load:_videoURLStr delegate:self];
        _back_LiveShow_btn.hidden = YES;
        self.progressSlider.value = 1.0f;
    });

}

- (void)setShowControlView:(BOOL)showControlView {
    
    _back_LiveShow_btn.hidden = _isLive;
    
    _showControlView = showControlView;
    
    self.topView.hidden = !_showControlView;
    self.bottomView.hidden = !_showControlView;
    self.singleTap.enabled = _showControlView;
    
    if (_showControlView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOrShowVideoControl) object:nil];
        [self performSelector:@selector(hideOrShowVideoControl) withObject:nil afterDelay:5];
    }
}


#pragma mark - 定时器操作
- (void)addProgressTimer
{
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.15 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
}

- (void)updateProgressInfo
{
    // 1.更新时间
    
    NSArray *time_arr = [self.startTimeLabel.text componentsSeparatedByString:@":"];
    int hour = [time_arr.firstObject intValue];
    int minute = [[time_arr objectAtIndex:1] intValue];
    int secord = [time_arr.lastObject intValue];
    secord +=1;
    if (secord == 60)
    {
        secord = 0;
        minute +=1;
    }
    
    if (minute == 60) {
        minute = 0;
        hour +=1;
    }
    self.startTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secord];
    
    
//    _valueLabel.text =self.startTimeLabel.text;
    NSTimeInterval allTimeInterval = [self.endTime longLongValue] - [self.startTime longLongValue];
    NSTimeInterval selectedTimeInterval = hour *3600 + minute *60 +secord;
    self.progressSlider.value = selectedTimeInterval/allTimeInterval;
    if(self.progressSlider.value == 1)
    {
        return;
    }
    
}



- (void)removeProgressTimer
{
    [progressTimer invalidate];
    progressTimer = nil;
}

#pragma mark - PlayOrPause
- (void)PlayOrPause:(UIButton *)sender{
   
    sender.selected = !sender.selected;
}

#pragma mark - fullScreenAction
-(void)fullScreenAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self.carousel removeAllSubViews];
    self.carousel.delegate = nil;
    self.carousel.dataSource = nil;
    self.carousel = nil;
    if (_valueLabel) {
        _valueLabel.hidden = YES;
    }
    //用通知的形式把点击全屏的时间发送到app的任何地方，方便处理其他逻辑
    if ([self.subviews indexOfObject:_startPlayBtn] == NSNotFound) {
        // 点击了小屏按钮，判断如果不是直接，加载直播
        if (!_isLive) {
            _isLive = YES;
            [self.videoIndicatorView startAnimating];
            self.image = nil;
            [_ffmpegPlayer pause];
            [_ffmpegPlayer stop];
            _ffmpegPlayer = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([progressTimer isValid]) {
                    [self removeProgressTimer];
                }
                [self.ffmpegPlayer load:_videoURLStr delegate:self];
            });
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fullScreenBtnClickNotice" object:sender];
}

#pragma mark - 播放进度
- (void)updateProgress:(UISlider *)slider
{
    if (self.topView.alpha == 1.0) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOrShowVideoControl) object:nil];
        [self performSelector:@selector(hideOrShowVideoControl) withObject:nil afterDelay:5];
    }
    self.topView.alpha = 1.0;
    self.bottomView.alpha = 1.0;

    if (!isPlaying)
    {
        if (_startPlayBtn) {
            
            [_startPlayBtn removeFromSuperview];
            _startPlayBtn = nil;
        }
        
    }
    [self removeProgressTimer];
    [self.carousel removeFromSuperview];
    [self addSubview:self.carousel];
    if (_valueLabel == nil) {
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_4s-100, SCREEN_WIDTH, 25)];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont systemFontOfSize:FONTCALE_Y * 25];
        
        _valueLabel.textColor = [UIColor whiteColor];
//        _valueLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_valueLabel];
    }
    else
    {
        _valueLabel.hidden = NO;
    }
//    _valueLabel.hidden = NO;
//    CGPoint valueBgCenter = _valueBg.center;
//    valueBgCenter.x = (VIEW_W(slider) - VIEW_W(_valueLabel) / 2) * slider.value + VIEW_X(slider) + VIEW_W(_valueLabel) + slider.currentThumbImage.size.width/2 * slider.value;
//    _valueLabel.center = valueBgCenter;
//    MMLog(@"=============%f",valueBgCenter.x);
    int num = [_allZip_Array count] *slider.value;
    if (num >= [_allZip_Array count])
    {
        num = (int)_allZip_Array.count-1;
    }
    
     [self.carousel scrollToItemAtIndex:num animated:NO];

    
//    self.startTime = [[self.startTime componentsSeparatedByString:@"."] firstObject];
    
    NSTimeInterval allTimeInterval = [self.endTime longLongValue] - [self.startTime longLongValue];
    NSTimeInterval selectedTimeInterval = _progressSlider.value * allTimeInterval;
    
    int hour = (int)(selectedTimeInterval/3600);
    int minute = (int)(selectedTimeInterval - hour*3600)/60;
    int secord = selectedTimeInterval - hour*3600 - minute*60;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secord];
    
    NSString *time = FORMATSTRING(VALUEFORKEY([_allZip_Array objectAtIndex:num], @"fileName"));
    time = [time componentsSeparatedByString:@"."].firstObject;
    time = [MyTools yearToTimestamp:time];
    time = [MyTools timestampChangesStandarTimeMinute:time];
    
    _valueLabel.text =time;
    hour = (int)(allTimeInterval/3600);
    minute = (int)(allTimeInterval - hour*3600)/60;
    secord = allTimeInterval - hour*3600 - minute*60;
    self.endTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secord];
//    MMLog(@"%@",self.startTimeLabel.text);
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_allZip_Array count];

}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{

    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 150.0f)];
        NSString *url_str = VALUEFORKEY(_allZip_Array[index], @"fileName");
        url_str = [NSString stringWithFormat:@"http://%@/INDEX/%@",[SettingConfig shareInstance].ip_url,url_str];
        
        [((UIImageView *)view) sd_setImageWithURL:[NSURL URLWithString:url_str] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
    }
    else
    {
        //get a reference to the label in the recycled view
        NSString *url_str = VALUEFORKEY(_allZip_Array[index], @"fileName");
        url_str = [NSString stringWithFormat:@"http://%@/INDEX/%@",[SettingConfig shareInstance].ip_url,url_str];
        [((UIImageView *)view) sd_setImageWithURL:[NSURL URLWithString:url_str] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
    }
    
    UIImageView *play_image = [[UIImageView alloc] initWithFrame:CGRectMake((200-80*PSDSCALE_X)/2, (150-80*PSDSCALE_Y)/2, 80*PSDSCALE_X, 80*PSDSCALE_Y)];
    play_image.image = GETYCIMAGE(@"camera_play");
    play_image.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:play_image];
    
    return view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.7;
    }
    return value;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    float num = (float)carousel.currentItemIndex/_allZip_Array.count;
    if (carousel.currentItemIndex == _allZip_Array.count - 1)
    {
        num = 1.0f;
    }
    self.progressSlider.value = num;
    NSTimeInterval allTimeInterval = [self.endTime longLongValue] - [self.startTime longLongValue];
    NSTimeInterval selectedTimeInterval = _progressSlider.value * allTimeInterval;
    
    int hour = (int)(selectedTimeInterval/3600);
    int minute = (int)(selectedTimeInterval - hour*3600)/60;
    int secord = selectedTimeInterval - hour*3600 - minute*60;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secord];
    
    
    NSString *time = FORMATSTRING(VALUEFORKEY([_allZip_Array objectAtIndex:carousel.currentItemIndex], @"fileName"));
    time = [time componentsSeparatedByString:@"."].firstObject;
    time = [MyTools yearToTimestamp:time];
    time = [MyTools timestampChangesStandarTimeMinute:time];
    
    _valueLabel.text =time;
    
    
    hour = (int)(allTimeInterval/3600);
    minute = (int)(allTimeInterval - hour*3600)/60;
    secord = allTimeInterval - hour*3600 - minute*60;
    self.endTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secord];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (index == carousel.currentItemIndex)
    {
        [self.carousel removeFromSuperview];
        self.carousel = nil;
        self.image = nil;
        [_ffmpegPlayer pause];
        [_ffmpegPlayer stop];
        _ffmpegPlayer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoIndicatorView startAnimating];
        });
        NSDictionary *dic = [_allZip_Array objectAtIndex:index];
        NSString *fileName = VALUEFORKEY(dic, @"fileName");

        __weak typeof(self) weakSelf = self;
            
        AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
        MsgModel *requestMsg = [[MsgModel alloc] init];
        requestMsg.cmdId = @"0C";
        requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
        requestMsg.msgBody = [fileName componentsSeparatedByString:@"."][0];
            
        [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
                
            if ([msg.msgBody isEqualToString:@"OK"]) {
                // 回放
                weakSelf.isLive = NO;
                weakSelf.back_LiveShow_btn.hidden = NO;
                weakSelf.valueLabel.hidden = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf removeProgressTimer];
                    [weakSelf addProgressTimer];
                    [weakSelf.ffmpegPlayer load:weakSelf.videoLiveRecUrlStr delegate:weakSelf];
                });
            }
        }];
}
    
    
}


#pragma mark - 单击手势方法
- (void)handleSingleTap{
    
    if (self.topView.alpha == 0.0) {
        [self hideOrShowVideoControl];
        [self performSelector:@selector(hideOrShowVideoControl) withObject:nil afterDelay:5];
    } else {
        [self hideOrShowVideoControl];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOrShowVideoControl) object:nil];
    }
    
}

- (void)hideOrShowVideoControl {
    [UIView animateWithDuration:0.5 animations:^{
        if (self.topView.alpha == 0.0) {
            self.topView.alpha = 1.0;
            
        }else{
            self.topView.alpha = 0.0;
        }
        
        if (self.bottomView.alpha == 0.0) {
            self.bottomView.alpha = 1.0;
            
        }else{
            self.bottomView.alpha = 0.0;
        }
    } completion:^(BOOL finish){
 
    }];

}

-(void)colseTheVideo:(UIButton *)sender{

    // 点击返回，判断如果不是直播，回到直播
    if ([self.subviews indexOfObject:_startPlayBtn] == NSNotFound) {
        if (!_isLive) {
            _isLive = YES;
            [self.videoIndicatorView startAnimating];
            self.image = nil;
            [_ffmpegPlayer pause];
            [_ffmpegPlayer stop];
            _ffmpegPlayer = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([progressTimer isValid]) {
                    [self removeProgressTimer];
                }
                [self.ffmpegPlayer load:_videoURLStr delegate:self];
            });
        }
    }
    if (self.carousel) {
        
        [self.carousel removeFromSuperview];
        self.carousel = nil;
        self.progressSlider.value = 1.0f;
    }
    if (_valueLabel) {
        _valueLabel.hidden = YES;
    }
    isPlaying = NO;
    [self removeProgressTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoBackBtnClick" object:sender];
}

- (void)startPlayBtn_clicked_action:(UIButton *)sender {
    
    [sender removeFromSuperview];
    
    [self.videoIndicatorView startAnimating];
    [self.ffmpegPlayer load:_videoURLStr delegate:self];
}

#pragma mark - XKFFmpegPlayerDelegate
- (void)loading {
    
}
- (void)failed:(NSError *)error {
    [self initPlayer];
}

- (void)playing {
//    [self.videoIndicatorView stopAnimating];
}
- (void)paused {
    if (_ffmpegPlayer.isEOF) {
        [self initPlayer];
    }
}

- (void)tick:(float)position
    duration:(float)duration {
    
}

// 播放视频
- (void)presentFrame:(UIImage *)image {
    isPlaying = YES;
    self.image = image;
}


@end
