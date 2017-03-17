//
//  MoviePlayerViewController.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import "ZFPlayer.h"
#import "FMDBTools.h"
#import "MyTools.h"
#import "EyeVideoEditController.h"
#import "EyeBreakRulesEditController.h"
#import "AlbumsVideoViewController.h"

@interface MoviePlayerViewController ()<ZFPlayerViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) ZFPlayerView *playerView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;


@end

@implementation MoviePlayerViewController
{
    BOOL isScreen;//是否横竖屏
}
- (void)dealloc
{
    NSLog(@"%@释放了",self.class);
    [self.playerView cancelAutoFadeOutControlBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel *title_lab = [[UILabel alloc] init];
    title_lab.textAlignment = NSTextAlignmentCenter;
    title_lab.font = [UIFont boldSystemFontOfSize:17];
    title_lab.text = @"视频预览";
    title_lab.textColor = [UIColor whiteColor];
    [self.view addSubview:title_lab];
    [title_lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(0);
        make.top.equalTo(self.view).offset(20);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(44);
    }];
    
    
    
    self.playerView = [[ZFPlayerView alloc] init];
    self.playerView.delegate = self;
    self.playerView.userInteractionEnabled = YES;
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(120);
        make.left.right.equalTo(self.view);
        // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
        make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
    }];
    
    //    添加 消息observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle) name:@"ON_RESIGN_ACTIVE" object:nil];
    
    // 设置播放前的占位图（需要在设置视频URL之前设置）
    
    self.playerView.placeholderImageName = self.imageURL;
    // 设置视频的URL
    self.playerView.videoURL = self.videoURL;
    NSString *videoName = [[self.videoURL absoluteString] componentsSeparatedByString:@"/"].lastObject;
    // 设置标题
    self.playerView.title = videoName;
    //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
    self.playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
    if (![self.superVC isKindOfClass:[AlbumsVideoViewController class]])
    {
        self.playerView.controlView.collectBtn.hidden = YES;
        self.playerView.controlView.reportBtn.hidden = YES;
        self.playerView.controlView.shareBtn.hidden = YES;
        self.playerView.controlView.deleteBtn.hidden = YES;
        self.playerView.controlView.loopBtn.hidden = YES;
        
    }
    
    // 打开下载功能（默认没有这个功能）
    self.playerView.hasDownload = NO;
    // 下载按钮的回调

    
    // 是否自动播放，默认不自动播放
    if (self.autoPlayTheVideo) {
        [self.playerView autoPlayTheVideo];
    }

    __weak typeof(self) weakSelf = self;
    self.playerView.goBackBlock = ^{
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    self.playerView.collectBlock = ^{
        // 收藏
        if ([FMDBTools selectContactMember:weakSelf.imageURL userName:UserName])
        {
            [weakSelf addActityText:@"不能重复收藏" deleyTime:1];
            return;
        }
        
        if ([FMDBTools saveContactsWithImageUrl:weakSelf.imageURL type:kCollectTypeVideo])
        {
            [weakSelf addActityText:@"收藏成功" deleyTime:1];
            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        }
        else
        {
            [weakSelf addActityText:@"收藏失败" deleyTime:1];
        }

    };
    
    //删除
    self.playerView.deleteBlock = ^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否删除当前视频" delegate:weakSelf cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alert show];
        
        NSLog(@"删除");
    };
    
    //分享
   
    self.playerView.shareBlock = ^{
        
        [weakSelf vertical_Screen];
        [weakSelf.playerView pause];
        ZYLog(@"分享");
        // 跳转到视频编辑页面
        EyeVideoEditController *videoEditCtl = [[EyeVideoEditController alloc] init];
        
        videoEditCtl.originalVideoPath = weakSelf.videoURL.path;
        
        [weakSelf.navigationController pushViewController:videoEditCtl animated:YES];
    };
    
    //举报
    self.playerView.reportBlock = ^{
        
        [weakSelf vertical_Screen];
        [weakSelf.playerView pause];
        ZYLog(@"举报");
        EyeBreakRulesEditController *videoEditCtl = [[EyeBreakRulesEditController alloc] init];
        
        videoEditCtl.originalVideoPath = weakSelf.videoURL.path;
        
        [weakSelf.navigationController pushViewController:videoEditCtl animated:YES];
    };
    
}

//进入
- (void)onApplicationDidBecomeActiveHandle
{
    [self vertical_Screen];
}

//退出
- (void)onApplicationWillResignActiveHandle
{
    if (isScreen)
    {
        [self vertical_Screen];
    }
}





-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            NSString *urlString = [[self.videoURL absoluteString] componentsSeparatedByString:@"file://"].lastObject;
            
            BOOL isDel = [self deleteDirInCache:self.imageURL];
            if (isDel)
            {
                NSString *fileName = urlString;
                if ([fileName containsString:@"CycleVideo"]) {
                    
//                    fileName = [self cyclePhoto_PathChangeCycleVideo_Path:fileName];
                    
                }else{
                    
                    fileName = [fileName componentsSeparatedByString:@"_"][0];
                    fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                    NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
                    
                    for (NSString *str in pathArr)
                    {
                        
                        if ([str containsString:fileName])
                        {
                            fileName = str;
                            break;
                        }
                    }
                }
                BOOL isdeleteVideo = [self deleteDirInCache:fileName];
                if (isdeleteVideo)
                {
                    MMLog(@"删除成功");
                    
                    if ([FMDBTools selectContactMember:self.imageURL userName:UserName])
                    {
                        // 有收藏，先删除收藏
                        BOOL isDeleteSuccess = [FMDBTools deleteCollectWithimageUrl:self.imageURL];
                        if (isDeleteSuccess)
                        {
                            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
                        }
                    }
                    
                    [self addActityText:@"删除成功" deleyTime:1];
                    
                    self.block();
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        [self vertical_Screen];
                        [self.playerView removeFromSuperview];
                        self.playerView = nil;
                    });
                    
                }
                else
                {
                    MMLog(@"删除失败");
                }
            }
        }
            break;
            
        default:
            break;
    }
}


//删除文件

-(BOOL)deleteDirInCache:(NSString *)dirName
{
    BOOL isDeleted = NO;
    //不存在就下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirName])
    {
        isDeleted = [[NSFileManager defaultManager] removeItemAtPath:dirName error:nil];
        return isDeleted;
    }
    return isDeleted;
}



//竖屏
- (void)vertical_Screen
{
    //强制旋转竖屏
    [self forceOrientationPortrait];
    //设置屏幕的转向为竖屏
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(120);
    }];
    
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

//横屏
- (void)cross_Screen
{
    //强制旋转竖屏
    [self forceOrientationLandscape];
    
    //强制翻转屏幕，Home键在右边。
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
    }];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

#pragma  mark 横屏设置
//强制横屏
- (void)forceOrientationLandscape
{
    isScreen = YES;
    AppDelegate*appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    appdelegate.isForcePortrait=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

//强制竖屏
- (void)forceOrientationPortrait
{
    isScreen = NO;
    AppDelegate*appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    appdelegate.isForceLandscape=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}




@end
