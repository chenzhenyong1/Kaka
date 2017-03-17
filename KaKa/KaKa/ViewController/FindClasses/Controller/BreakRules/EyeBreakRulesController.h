//
//  EyeBreakRulesController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章举报页面

#import "EyeBaseViewController.h"
#import "EyeHeaderView.h"

@interface EyeBreakRulesController : EyeBaseViewController

/** 视频播放路径 */
@property (nonatomic, copy) NSString *videoPath;

/** 视频播放的音乐名称 */
@property (nonatomic, copy) NSString *musicName;
/** 是否静音 */
@property (nonatomic, assign) BOOL mute;


@property (nonatomic, strong) EyeHeaderView *headerView;


/** 原始文件路径 */
@property (nonatomic, copy) NSString *path;

@end
