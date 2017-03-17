//
//  CameraVideoPlayer.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/15.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XKFFmpegPlayer.h"



@interface CameraVideoPlayer : UIImageView

// 播放器
@property (nonatomic, strong) XKFFmpegPlayer *ffmpegPlayer;

// 回放地址
@property (nonatomic, copy) NSString *videoLiveRecUrlStr;

// BOOL值判断当前的状态
@property (nonatomic, assign) BOOL isFullscreen;

@property (nonatomic, strong) UIActivityIndicatorView *videoIndicatorView; // 菊花

// 顶部操作工具栏
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *backButton;
// 底部操作工具栏
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, copy)   NSString *videoURLStr;

// 显示视图控制view
@property (nonatomic, assign) BOOL showControlView;

/**
 *  控制全屏的按钮
 */
@property(nonatomic,retain)UIButton *fullScreenBtn;
/**
 *  播放暂停按钮
 */
@property(nonatomic,retain)UIButton *playOrPauseBtn;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**
 *  初始化方法
 *
 *  @param frame       frame
 *  @param videoURLStr URL字符串，包括网络的和本地的URL
 *  @param usesTcp 是否是tcp
 *
 *  @return id类型，CameraVideoPlayer的一个对象
 */
- (id)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr;

- (void)initPlayer;

@end
