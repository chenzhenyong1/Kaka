//
//  EyeBreakRulePictureController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/28.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章图片选取页面

#import "EyeBaseViewController.h"

@interface EyeBreakRulePictureController : EyeBaseViewController

/** 视频路径 */
@property (nonatomic, copy) NSString *videoPath;

/** 取得图片跳回违章页面block */
@property (nonatomic, copy) void (^breakRulesImageBlock)(UIImage *image);

@end
