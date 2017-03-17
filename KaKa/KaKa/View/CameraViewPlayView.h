//
//  CameraViewPlayView.h
//  KaKa
//
//  Created by Change_pan on 16/8/16.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraViewPlayViewDelegate <NSObject>

- (void)aaaaa;

@end

@interface CameraViewPlayView : UIView

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) NSString *video_path;

@property (nonatomic, strong) NSString *video_photo_path;

@property (nonatomic, copy) id<CameraViewPlayViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath;


@end
