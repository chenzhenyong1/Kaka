//
//  EyeCheckVideoController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"

@class EyeAddressModel;
@interface EyeCheckVideoController : EyeBaseViewController

/** 当前视频的播放地址 */
@property (strong, nonatomic) NSString *videoPath;
/** 视频播放的音乐名称 */
@property (nonatomic, copy) NSString *musicName;
/** 是否静音 */
@property (nonatomic, assign) BOOL mute;

/** 视频封面 */
@property (nonatomic, weak) UIImageView *videoCoverImageView;

/** 封面图片 */
@property (nonatomic, strong) UIImage *coverImage;

/** 地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;

@end
