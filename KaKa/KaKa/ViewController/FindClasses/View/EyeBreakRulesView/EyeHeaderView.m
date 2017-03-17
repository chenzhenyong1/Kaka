//
//  EyeHeaderView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeHeaderView.h"


@interface EyeHeaderView ()



/** bottomView */
@property (nonatomic, weak) UIView *bottomView;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;


@end

@implementation EyeHeaderView

#pragma mark -- life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];

        [self bottomView];
        self.height = self.bottomView.bottom;
    }
    return self;
}

#pragma mark -- public
- (void)refreshUIWithMovieResouceUrl:(NSURL *)movieResouceUrl showImage:(UIImage *)showImage{
    [self.playView refreshUIWithMovieResouceUrl:movieResouceUrl showImage:showImage];
    //截取左边违章图片
    UIImage *leftBackImage = [self thumbnailImageForVideo:movieResouceUrl atTime:1.0];
    [self.leftBtn setBackgroundImage:leftBackImage forState:UIControlStateNormal];
    //截取右边违章图片
    UIImage *rightBackImage = [self thumbnailImageForVideo:movieResouceUrl atTime:2.0];
    [self.rightBtn setBackgroundImage:rightBackImage forState:UIControlStateNormal];
    
}


#pragma mark -- properties
- (EyePlayView *)playView {
    if (!_playView){
        EyePlayView *playView = [[EyePlayView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width * 9 / 16)];
        [self addSubview:playView];
        _playView = playView;
    }
    return _playView;
}




-(UIView *)bottomView
{
    if (!_bottomView) {
        
       
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.playView.bottom, self.width, self.playView.height * 0.5 + 20)];
        bottomView.backgroundColor = ZYGlobalBgColor;
        
        int padding = 10;
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setBackgroundColor:[UIColor purpleColor]];
        [bottomView addSubview:leftBtn];
        
        [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.leftBtn = leftBtn;
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setBackgroundColor:[UIColor grayColor]];
        [bottomView addSubview:rightBtn];
        
        [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightBtn = rightBtn;
        
        [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(bottomView.mas_centerY);
            make.left.equalTo(bottomView.mas_left).with.offset(padding);
            make.right.equalTo(rightBtn.mas_left).with.offset(-padding);
            make.height.mas_equalTo(self.playView.height * 0.5);
            make.width.equalTo(rightBtn);
        }];
        
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(bottomView.mas_centerY);
            make.left.equalTo(leftBtn.mas_right).with.offset(padding);
            make.right.equalTo(bottomView.mas_right).with.offset(-padding);
            make.height.mas_equalTo(self.playView.height * 0.5);
            make.width.equalTo(leftBtn);
        }];
        
        [self addSubview:bottomView];
   
        _bottomView = bottomView;
    
    }
    return _bottomView;
}

-(void)leftBtnClick:(UIButton *)button
{
    
    self.addPicture(EyeHeaderViewBtnLeft);

}
-(void)rightBtnClick:(UIButton *)button
{
    
    self.addPicture(EyeHeaderViewBtnRight);
    
}

// 在视频的某个时间截取图片
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    self.imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(self.playView.width*2, self.playView.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.playView.width, self.playView.height);
    }
    
    int picWidth = self.playView.width;
    NSError *error;
    
    
    CMTime actualTime = CMTimeMake(time * 30 , 30);
    
    CMTimeShow(actualTime);
    
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:actualTime actualTime:&actualTime error:&error];
    if (error) {
        ZYLog(@"error = %@",error);
    }
    
    if (halfWayImage != NULL) {
        UIImage *videoScreen;
        if ([self isRetina]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        tmp.width = picWidth;
        tmp.height = picWidth * 9/16;
        
        CGImageRelease(halfWayImage);
        
        return tmp.image;
    }
    
    return nil;
}
-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}
@end
