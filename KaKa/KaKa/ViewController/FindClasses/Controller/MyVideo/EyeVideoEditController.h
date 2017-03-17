//
//  EyeVideoEditController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBaseViewController.h"
#import "EyePlayView.h"
@interface EyeVideoEditController : EyeBaseViewController

/** 当前视频的播放地址 */
@property (strong, nonatomic) NSString *originalVideoPath;
//供子类使用
@property (nonatomic, weak) EyePlayView *playView;

/** 原始文件路径 */
@property (nonatomic, copy) NSString *path;


@end
