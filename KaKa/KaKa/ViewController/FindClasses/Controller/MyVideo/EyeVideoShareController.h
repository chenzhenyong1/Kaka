//
//  EyeVideoShareController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/19.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeShareController.h"

@interface EyeVideoShareController : EyeShareController


/** 当前视频的播放地址 */
@property (strong, nonatomic) NSString *videoPath;
/** 视频播放的音乐名称 */
@property (nonatomic, copy) NSString *musicName;
/** 是否静音 */
@property (nonatomic, assign) BOOL mute;
@end
