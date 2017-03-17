//
//  EyeVideoPictureSelectedController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/20.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//  视频分享的封面选择

#import "EyeBaseViewController.h"

@interface EyeVideoPictureSelectedController : EyeBaseViewController

/** 视频路径 */
@property (nonatomic, copy) NSString *videoPath;
/** 取得图片跳回分享页面block */
@property (nonatomic, copy) void (^selectedImageBlock)(UIImage *image);

@end
