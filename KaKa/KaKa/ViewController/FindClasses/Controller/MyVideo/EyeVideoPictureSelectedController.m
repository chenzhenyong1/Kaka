//
//  EyeVideoPictureSelectedController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/20.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeVideoPictureSelectedController.h"
#import "SAVideoRangeSlider.h"

@interface EyeVideoPictureSelectedController ()


@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;

/** 滑竿 */
@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
/** 封面 */
@property (nonatomic, strong) UIImageView *coverImageView;
/** CFTimeInterval  */
@property (nonatomic, assign) CFTimeInterval value;

/** name */
@property (nonatomic, strong) NSMutableArray *imageArr;
@end

@implementation EyeVideoPictureSelectedController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ZYGlobalBgColor;
    [self setupNav];
   
    [self mySAVideoRangeSlider:[NSURL fileURLWithPath:self.videoPath]];
    
    [self setupSlider];
    UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:1.0/30];
    
    self.coverImageView.image = image;
    
}

- (void)setupNav
{
    
    self.title = @"图片选择";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
    [self setupNavBar];
}


-(void)mySAVideoRangeSlider:(NSURL *)videoUrl
{
    self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.coverImageView.frame) + 50, self.view.width-20, 50) videoUrl:videoUrl ];
    
    self.mySAVideoRangeSlider.leftThumb.hidden = YES;
    self.mySAVideoRangeSlider.rightThumb.hidden = YES;
    self.mySAVideoRangeSlider.topBorder.hidden = YES;
    self.mySAVideoRangeSlider.bottomBorder.hidden = YES;
    //    self.mySAVideoRangeSlider.delegate = self;
    [self.view addSubview:self.mySAVideoRangeSlider];
    
    
}


- (void)rightClick
{
    ZYLog(@"点击完成");
    
    self.selectedImageBlock(self.coverImageView.image);
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -- property
-(void)setupSlider
{
    UISlider *slider = [[UISlider alloc] init];
    [slider setThumbImage:[UIImage imageNamed:@"ic_drag_and_drop"] forState:UIControlStateNormal];
    
    slider.minimumTrackTintColor = [UIColor clearColor];
    slider.maximumTrackTintColor = [UIColor clearColor];
    
    [self.view addSubview:slider];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.mySAVideoRangeSlider);
        make.left.equalTo(self.mySAVideoRangeSlider).with.offset(self.mySAVideoRangeSlider.leftThumb.width + 3.0);
        make.right.equalTo(self.mySAVideoRangeSlider).with.offset(- self.mySAVideoRangeSlider.rightThumb.width - 3.0);
        make.height.mas_equalTo(slider.currentThumbImage.size.height);
        
    }];
    
    slider.minimumValue = self.mySAVideoRangeSlider.leftPosition + 1.0/30;
    slider.maximumValue = self.mySAVideoRangeSlider.rightPosition;
    
    [slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    
    self.slider = slider;
    
    [self valueChange:slider];
}

- (void)valueChange:(UISlider *)slider
{
    
    self.coverImageView.hidden = NO;
    
    UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:self.slider.value];
    
    self.coverImageView.image = image;
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
        self.imageGenerator.maximumSize = CGSizeMake(self.coverImageView.width*2, self.coverImageView.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.coverImageView.width, self.coverImageView.height);
    }
    
    int picWidth = self.coverImageView.width;
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

-(NSMutableArray *)imageArr
{
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

-(UIImageView *)coverImageView
{
    if (!_coverImageView) {
        UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , self.view.width, self.view.width * 9/16)];
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
//        UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:1.0/30];
//        coverImageView.image = image;
        [self.view addSubview:coverImageView];
        
        _coverImageView = coverImageView;
        
        //左移箭头
        UIButton *left_nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [left_nextBtn setImage:[UIImage imageNamed:@"ic_left_next"] forState:UIControlStateNormal];
        [left_nextBtn sizeToFit];
        left_nextBtn.x = 10;
        left_nextBtn.centerY = coverImageView.height * 0.5 ;
        
        [left_nextBtn addTarget:self action:@selector(leftAddLeftPicClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:left_nextBtn];
        //右移箭头
        UIButton *right_nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [right_nextBtn setImage:[UIImage imageNamed:@"ic_right_next"] forState:UIControlStateNormal];
        [right_nextBtn sizeToFit];
        right_nextBtn.x = self.view.width - 10 - right_nextBtn.currentImage.size.width;
        right_nextBtn.centerY = left_nextBtn.centerY;
        
        [right_nextBtn addTarget:self action:@selector(rightAddLeftPicClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:right_nextBtn];
        
        
    }
    
    return _coverImageView;
}

//向左移一帧
- (void)leftAddLeftPicClick
{
    self.coverImageView.hidden = NO;
    self.slider.value -= 1.0 / 30;
    UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:self.slider.value];
    if (image) {
        
        self.coverImageView.image = image;
    }
}


//向右移一帧
- (void)rightAddLeftPicClick
{
    self.coverImageView.hidden = NO;
    self.slider.value += 1.0 / 30;
    UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:self.slider.value];
    
    self.coverImageView.image = image;
}

#pragma mark - Helpers


-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}
@end
