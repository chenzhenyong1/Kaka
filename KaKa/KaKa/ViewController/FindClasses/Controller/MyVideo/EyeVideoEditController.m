//
//  EyeVideoEditController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeVideoEditController.h"
#import <AVFoundation/AVFoundation.h>
#import "SAVideoRangeSlider.h"

#import "ImageTextButton.h"
#import "EyeVideoShareController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EyeCustomBtn.h"
#import "EyeMusicCell.h"
#import "EyeAudioTool.h"

//#import "EyeEditVideoSoundCell.h"



#define tmpPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMp4.mp4"]

#define leftPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"leftMp4.mp4"]

#define rightPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"rightMp4.mp4"]

#define mergePath [NSTemporaryDirectory() stringByAppendingPathComponent:@"mergeMp4.mp4"]

typedef void (^CutFinishReturn)(void);
@interface EyeVideoEditController ()<SAVideoRangeSliderDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;

@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;



/** 视频片段时间 */
@property (nonatomic, strong) UILabel *timeLabel;
/** 视频片段时间 */
@property (nonatomic, strong) UILabel *leftTimeLabel;
/** 视频片段时间 */
@property (nonatomic, strong) UILabel *rightTimeLabel;


/** 剪辑后的视频地址 */
@property (strong, nonatomic) NSString *videoPath;
/** 剪辑的起始时间 */
@property (nonatomic) CGFloat startTime;
/** 剪辑的结束时间 */
@property (nonatomic) CGFloat stopTime;


@property (strong, nonatomic) AVAssetExportSession *exportSession;

/** 音乐图片数组 */
@property (nonatomic, strong) NSArray *musicArr;
/** 音乐名字数组（不加后缀名） */
@property (nonatomic, strong) NSArray *musicNameArr;

/** 底部按钮 */
@property (nonatomic, weak) UICollectionView *collectionView;


@property (nonatomic, weak) UIButton *orginSoundButton;
@end

@implementation EyeVideoEditController


-(void)dealloc
{
    [self deleteTmpFile:leftPath];
    [self deleteTmpFile:rightPath];
    [self deleteTmpFile:mergePath];
    [self deleteTmpFile:tmpPath];
    ZYLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.musicArr = @[@{@"无":@"bg_no_music"},@{@"宁静悠远":@"music_pic_1"},@{@"西部风情":@"music_pic_2"},@{@"DJ狂欢":@"music_pic_3"},@{@"浪漫爱情":@"music_pic_4"},@{@"似水流连":@"music_pic_5"},@{@"欢乐海岸":@"music_pic_6"},@{@"童真无忧":@"music_pic_7"}];
    self.musicNameArr = @[@" ",@"test1",@"test2",@"test3",@"test4",@"test5",@"test6",@"test7"];
    
    [self setupNav];
    
    //视频
    [self playView];
    
    //图片滑竿
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self mySAVideoRangeSlider:[NSURL fileURLWithPath:self.originalVideoPath]];
        //时间
        [self timeLabel];
        
        //底部按钮
        [self setupBtn];
    });
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    self.videoPath = tmpPath;
//    [self deleteTmpFile:self.videoPath];
//    [self cutVideoWithStartTime:0.01 withStopTime:self.stopTime cutPath:tmpPath refreshUI:YES];
}

/**
 *  设置导航栏
 */
- (void)setupNav
{
    self.title = @"视频编辑";
    self.view.backgroundColor = ZYGlobalBgColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}

- (void)back
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出分享" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    
    [alert show];
    


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//确认
        [self.playView pause];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
/**
 *  点击下一步
 */
- (void)rightItemClick
{
    
    if ([self.playView durationTime] < 5.0 || [self.playView durationTime] > 30.0) {
        
        [self addActityText:@"只支持5~30的视频分享" deleyTime:1.0];
        return;
    }
    [self.playView pause];
    [self.playView removeFromSuperview];
    
    if (self.playView.musicName) {
        [EyeAudioTool stopMusicWithMusicName:self.playView.musicName];
    }
    
    //跳转到视频分享页面
    EyeVideoShareController *videoShareCtl = [[EyeVideoShareController alloc] init];
    videoShareCtl.videoPath = self.originalVideoPath;
    videoShareCtl.musicName = self.playView.musicName;
    videoShareCtl.mute = self.playView.player.volume == 0 ? YES:NO;
    [self.navigationController pushViewController:videoShareCtl animated:YES];
}

- (void)setupBtn
{
    // 截取选中片段按钮
    ImageTextButton *selectBtn = [self buttonWithImageName:@"find_video_selectVideoPart" title:@"截取选中片段"];
    [selectBtn sizeToFit];
    selectBtn.centerX = self.view.centerX - selectBtn.width;
    selectBtn.y = CGRectGetMaxY(self.mySAVideoRangeSlider.frame) + self.view.width * 0.1 - 10;
    
    [selectBtn addTarget:self action:@selector(selectedClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBtn];
    
    // 删除选中片段按钮
    ImageTextButton *deleBtn = [self buttonWithImageName:@"find_video_deleteVideoPart" title:@"删除选中片段"];
    [deleBtn sizeToFit];
    deleBtn.centerX = self.view.centerX + deleBtn.width;
    deleBtn.y = selectBtn.y;
   
    [deleBtn addTarget:self action:@selector(deletedClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleBtn];
    
    
    // 原声关闭按钮
    [self orginSoundBtn];
    
    //底部音乐按钮
    [self bottomMusicCollectionView];
    
    
    [self descLabel];
    
   
}
// 原声关闭按钮
- (void)orginSoundBtn
{
    UIButton *orginSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [orginSoundBtn setBackgroundImage:[UIImage imageNamed:@"find_orginSound_close"] forState:UIControlStateNormal];
    [orginSoundBtn addTarget:self action:@selector(orginSoundBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:orginSoundBtn];
    
    [orginSoundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    self.orginSoundButton = orginSoundBtn;
    
    
    UILabel *orginSoundLabel = [[UILabel alloc] init];
    orginSoundLabel.text = @"原声关闭";
    orginSoundLabel.font = [UIFont systemFontOfSize:10];
    orginSoundLabel.textColor = [UIColor darkGrayColor];
    orginSoundLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:orginSoundLabel];
    
    [orginSoundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(orginSoundBtn.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-5);
        make.width.equalTo(orginSoundBtn.mas_width);
        make.height.equalTo(@15);
        
    }];


}
//点击原声关闭按钮
- (void)orginSoundBtnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (btn.isSelected) {
        
        [btn setBackgroundImage:[UIImage imageNamed:@"find_orginSound_open"] forState:UIControlStateNormal];
        self.playView.player.volume = 0;
        
    }else{
        
        [btn setBackgroundImage:[UIImage imageNamed:@"find_orginSound_close"] forState:UIControlStateNormal];
        
        self.playView.player.volume = 1;
    }
    
    
}


//截取选中片段
- (void)selectedClick
{
    
    if ((self.stopTime - self.startTime) < 5.0) {
        
        [self addActityText:@"视频不能短于5秒" deleyTime:1.0];
        
        return;
    }
    
    self.videoPath = tmpPath;
    [self deleteTmpFile:self.videoPath];
     [self addActityLoading:@"正在截取片段中..." subTitle:@""];
    // 截取视频片段
    
    
    
    [self cutVideoWithStartTime:self.startTime withStopTime:self.stopTime cutPath:tmpPath refreshUI:YES];
    
    
}

//删除选中片段（其实就是截取左边和右边的视频，然后合并）
- (void)deletedClick
{
    
    if (([self.playView durationTime] - (self.stopTime - self.startTime)) < 5.0) {
        [self addActityText:@"视频不能短于5秒" deleyTime:1.0];
        
        return;
    }
    
    [self deleteTmpFile:leftPath];
    [self deleteTmpFile:rightPath];
    [self deleteTmpFile:mergePath];
    [self deleteTmpFile:tmpPath];
    
//    ZYLog(@"self.startTime = %f  self.mySAVideoRangeSlider.leftPosition = %f  self.stopTime = %f  self.mySAVideoRangeSlider.rightPosition = %f  self.playView.durationTime = %f",self.startTime,self.mySAVideoRangeSlider.leftPosition,self.stopTime,self.mySAVideoRangeSlider.rightPosition,self.playView.durationTime);
    //剪辑左边视频
    
    [self addActityLoading:@"正在删除片段中..." subTitle:@"等待时间可能比较长"];
    
//    if (self.startTime != 0 && self.stopTime != self.playView.durationTime) {
//        [self cutVideoWithStartTime:0 withStopTime:self.mySAVideoRangeSlider.leftPosition cutPath:leftPath refreshUI:NO];
//        
//        return;
//    }
    
    NSString *stop = [NSString stringWithFormat:@"%.1f",self.mySAVideoRangeSlider.rightPosition];
    NSString *duration = [NSString stringWithFormat:@"%.1f",self.playView.durationTime];
    
    
    //滑块没动
    if (self.startTime == 0 && [stop isEqualToString:duration]) {
        
        [self addActityText:@"视频不能短于5秒" deleyTime:1.0];
        return;
        
    }else if (self.startTime == 0 && self.stopTime != self.playView.durationTime){//左边滑块没动
//        self.videoPath = tmpPath;
//        [self deleteTmpFile:self.videoPath];
        [self cutVideoWithStartTime:self.stopTime withStopTime:self.playView.durationTime cutPath:tmpPath refreshUI:YES];
        
        return;
    }else if (self.startTime != 0 && [stop isEqualToString:duration]){//右边滑块没动
//        self.videoPath = tmpPath;
//        [self deleteTmpFile:self.videoPath];
        [self cutVideoWithStartTime:0 withStopTime:self.startTime cutPath:tmpPath refreshUI:YES];
        
        return;
    }else {
        [self cutVideoWithStartTime:0 withStopTime:self.mySAVideoRangeSlider.leftPosition cutPath:leftPath refreshUI:NO];
        
        return;
    }
    
    
    
    
   
    
}
/**
 *  合并视频
 *
 *  @param firstPath  第一个视频地址
 *  @param secondPath 第二个视频地址
 */
-(void)mergeAndSaveWithFirstPath:(NSString *)firstPath withSecondPath:(NSString *)secondPath
{
    AVAsset *firstAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:firstPath]];
    AVAsset *secondAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:secondPath]];
    
    // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 2 - Video track
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                        ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                        ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];
    
    NSURL *url = [NSURL fileURLWithPath:mergePath];
    // 3 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self exportDidFinish:exporter];
            
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        
        ZYLog(@"合并成功");
        [self videoPlay:outputURL.path];
        [self addActityText:@"删除片段成功" deleyTime:0.5];
        
    }else
    {
        [self addActityText:@"删除片段失败" deleyTime:1];
    }
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//            
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在通用设置将允许访问相册打开"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                        [self addActityText:@"删除片段失败" deleyTime:1];
//                    } else {
//                        ZYLog(@"合并成功");
//                        [self videoPlay:outputURL.path];
//                        [self addActityText:@"删除片段成功" deleyTime:0.5];
//                    }
//                });
//            }];
//        }
//    }
}
/**
 *  视频剪辑
 *
 *  @param startTime 截取的开始时间
 *  @param stopTime  截取的结束时间
 */
- (void)cutVideoWithStartTime:(CGFloat)startTime withStopTime:(CGFloat)stopTime cutPath:(NSString *)path refreshUI:(BOOL)isRefresh
{
    
   
    
    AVAsset *anAsset = self.playView.player.currentItem.asset;
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        
        NSURL *furl = [NSURL fileURLWithPath:path];
        
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeMPEG4;
        
        CMTime start = CMTimeMakeWithSeconds(startTime, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(stopTime-startTime, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            ZYLog(@"currentThread = %@",[NSThread currentThread]);
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    ZYLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    ZYLog(@"Export canceled");
                    break;
                default:
                    ZYLog(@"NONE");
                    
                    
                    
                    if (isRefresh) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self videoPlay:path];
                            ZYLog(@"剪辑成功");
                            [self addActityText:@"截取片段成功" deleyTime:0.5];
                            
                        });
                    }else{
                        [self finishCutInPath:path];
                    }
                    
                    
                    break;
            }
        }];
        
    }

}
/**
 *  剪辑成功回调
 *
 *  @param path 地址
 */
- (void)finishCutInPath:(NSString *)path
{
    if ([path isEqualToString:leftPath]) {
        //剪辑右边视频
        [self cutVideoWithStartTime:self.mySAVideoRangeSlider.rightPosition withStopTime:[self.playView durationTime] cutPath:rightPath refreshUI:NO];
    }else if ([path isEqualToString:rightPath]){
        //合并视频
         [self mergeAndSaveWithFirstPath:leftPath withSecondPath:rightPath];
    }

}

- (void)videoPlay:(NSString *)path
{
    //替换视频地址
    self.originalVideoPath = path;
    
//    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
//    [self.playView.player replaceCurrentItemWithPlayerItem:item];
    
    [self.playView refreshUIWithMovieResouceUrl:[NSURL fileURLWithPath:path] showImage:[UIImage imageNamed:@"find_videoPlay"]];
    
    [self.mySAVideoRangeSlider removeFromSuperview];
    
    [self mySAVideoRangeSlider:[NSURL fileURLWithPath:path]];
    
    
    [self.playView pause];
    
    self.stopTime = self.playView.durationTime;
    
//    [self orginSoundBtnClick:self.orginSoundButton];

}





- (ImageTextButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title
{
    ImageTextButton *btnView = [[ImageTextButton alloc] init];;
    [btnView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btnView setTitle:title forState:UIControlStateNormal];
    [btnView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnView.titleLabel.font = [UIFont systemFontOfSize:10];
    [btnView setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentDown];
//    [btnView sizeToFit];

    return btnView;
}

- (void)descLabel
{
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = @"支持5~30秒的视频分享";
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.font = [UIFont systemFontOfSize:12];
    [descLabel sizeToFit];
    [self.view addSubview:descLabel];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.collectionView.mas_top).offset(-5);
    }];

}

#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    
    //滑动左边
    if (self.startTime != leftPosition) {
        
        [self.playView.player seekToTime:CMTimeMakeWithSeconds(leftPosition, self.playView.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
            self.playView.showImageView.hidden = NO;
            [self.playView pause];
        }];
    }else if (self.stopTime != rightPosition)
    {
        
    //滑动右边
        [self.playView.player seekToTime:CMTimeMakeWithSeconds(rightPosition, self.playView.player.currentItem.duration.timescale) completionHandler:^(BOOL finished) {
            self.playView.showImageView.hidden = NO;
            [self.playView pause];
        }];
    }
    
    self.startTime = self.mySAVideoRangeSlider.leftPosition;
    self.stopTime = self.mySAVideoRangeSlider.rightPosition;
    
    NSString *second = [self TimeformatFromSeconds:rightPosition - leftPosition];
    NSString *leftSecond = [self TimeformatFromSeconds:leftPosition];
    NSString *rightSecond = [self TimeformatFromSeconds:rightPosition];
    
    
    //剪辑时间段
    self.timeLabel.text = second;
    [self.timeLabel sizeToFit];
    self.leftTimeLabel.text = leftSecond;
    [self.leftTimeLabel sizeToFit];
    self.rightTimeLabel.text = rightSecond;
    [self.rightTimeLabel sizeToFit];
}
//秒数转化成 时 分 秒
-(NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}


#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.musicArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EyeMusicCell *cell = (EyeMusicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"EyeMusicCell" forIndexPath:indexPath];
    
//    cell.backgroundColor = [UIColor purpleColor];
    [cell refreshUI:self.musicArr[indexPath.row]];
    
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    return CGSizeMake(45, 70);
}
//间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.playView.musicName = self.musicNameArr[indexPath.row];
        
    
    ZYLog(@"indexPath = %ld",(long)indexPath.row);
}

#pragma mark -- properties


-(void)mySAVideoRangeSlider:(NSURL *)videoUrl
{
    
//        NSURL *url = [[NSBundle mainBundle] URLForResource:@"FinalVideo-711.mov" withExtension:nil];
        self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.playView.frame) + 30, self.view.frame.size.width-40, self.playView.height * 0.25) videoUrl:videoUrl ];
        
        self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed:35/255.0 green:122/255.0 blue:191/255.0 alpha:1.0];
        self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed:35/255.0 green:122/255.0 blue:191/255.0 alpha:1.0];
        self.mySAVideoRangeSlider.minGap = 0;
        self.mySAVideoRangeSlider.delegate = self;
        [self.view addSubview:self.mySAVideoRangeSlider];
        
        self.startTime = self.mySAVideoRangeSlider.leftPosition;
        self.stopTime = self.mySAVideoRangeSlider.rightPosition;
    
        self.leftTimeLabel.text = [self TimeformatFromSeconds:self.startTime];
        self.rightTimeLabel.text = [self TimeformatFromSeconds:self.stopTime];
        self.timeLabel.text = [self TimeformatFromSeconds:self.stopTime - self.startTime];
        [self.leftTimeLabel sizeToFit];
        [self.rightTimeLabel sizeToFit];
        [self.timeLabel sizeToFit];
}


- (EyePlayView *)playView {
    if (!_playView){
        EyePlayView *playView = [[EyePlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width * 9 / 16)];

#warning 修改地址
        //剪辑前的视频地址
//        NSBundle *mainBundle = [NSBundle mainBundle];
//        self.originalVideoPath = [mainBundle pathForResource: @"20160928083000_180" ofType: @"MP4"];
        playView.musicName = self.musicNameArr[0];
        playView.showImageView.hidden = NO;
        
        
        
        NSURL *videoFileUrl = [NSURL fileURLWithPath:self.originalVideoPath];
        
        self.path = self.originalVideoPath;
        
        [playView refreshUIWithMovieResouceUrl:videoFileUrl showImage:[UIImage imageNamed:@"find_breakRules_play"]];
        
        
        
        playView.backgroundColor = ZYGlobalBgColor;
        
        [self.view addSubview:playView];
        _playView = playView;
    }
    return _playView;
}


- (void)bottomMusicCollectionView
{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.itemSize =CGSizeMake(45, 70);
    
    //2.初始化collectionView
    UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(60, self.view.height - 70, self.view.width - 60 , 70) collectionViewLayout:layout];
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:mainCollectionView];
    mainCollectionView.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell   注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [mainCollectionView registerClass:[EyeMusicCell class] forCellWithReuseIdentifier:@"EyeMusicCell"];
    //4.设置代理
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    
    _collectionView = mainCollectionView;
}




-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = ZYRGBColor(180, 67, 68);
        _timeLabel.text = [self TimeformatFromSeconds:self.stopTime - self.startTime];
        [_timeLabel sizeToFit];
        _timeLabel.centerX = self.view.centerX;
        _timeLabel.y = CGRectGetMaxY(self.playView.frame) + 10;
        
        
        
        [self.view addSubview:_timeLabel];
    }
    return _timeLabel;
}

-(UILabel *)leftTimeLabel
{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.textColor = [UIColor darkGrayColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:12];
        _leftTimeLabel.text = [self TimeformatFromSeconds:self.startTime];
        [_leftTimeLabel sizeToFit];
        _leftTimeLabel.x = 8;
        
        _leftTimeLabel.y = CGRectGetMaxY(self.playView.frame) + 8;
        
        
        
        [self.view addSubview:_leftTimeLabel];
    }
    return _leftTimeLabel;

}

-(UILabel *)rightTimeLabel
{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textColor = [UIColor darkGrayColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:12];
        _rightTimeLabel.text = [self TimeformatFromSeconds:self.stopTime];
        [_rightTimeLabel sizeToFit];
        _rightTimeLabel.x = self.view.width - _rightTimeLabel.width - 8;
        
        _rightTimeLabel.y = CGRectGetMaxY(self.playView.frame) + 8;
        
        
        
        [self.view addSubview:_rightTimeLabel];
    }
    return _rightTimeLabel;
    
}


@end
