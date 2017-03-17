//
//  EyeBaseViewController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/15.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EyeCustomBtn.h"
#import "UMSocialQQHandler.h"

@interface EyeBaseViewController ()<UMSocialUIDelegate>{
    
    
    MBProgressHUD *hud;
    BOOL keyBoardHide;

}

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation EyeBaseViewController




- (void)dealloc {
    [NotificationCenter removeObserver:self];
    
    ZYLog(@"BaseViewController release");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册键盘事件用于处理弹框被键盘遮住问题
    keyBoardHide = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
//    [self setupNav];
    
}

- (void)setupNavBar
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)keyboardWillHide:(NSNotification *)notification
{
    keyBoardHide = YES;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    keyBoardHide = NO;
}
//文字提示框
- (void)addActityText:(NSString *)text deleyTime:(float)duration;
{
    [hud removeFromSuperview];
    hud = nil;
    //如果键盘已弹出，往上移一点
    if (!keyBoardHide) {
        UIView *view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        view.center = CGPointMake(view.center.x, view.center.y - 50);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }else{
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    hud.mode = MBProgressHUDModeText;
    hud.color = [UIColor blackColor];
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.labelColor = [UIColor whiteColor];
    hud.margin = 15;
    hud.cornerRadius = 3;
    [hud hide:YES afterDelay:duration];
//    hud.bezelView.color = [UIColor blackColor];
//    hud.label.text = text;
//    hud.label.font = [UIFont systemFontOfSize:13];
//    hud.label.textColor = [UIColor whiteColor];
//    hud.margin = 15;
//    hud.bezelView.layer.cornerRadius = 3;
//    
//    [hud hideAnimated:YES afterDelay:duration];
}
//加载提示
- (void)addActityLoading:(NSString *)title subTitle:(NSString *)subTitle{
    [hud removeFromSuperview];
    hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;//模式
    hud.color = [UIColor blackColor];//颜色
    hud.labelText = title;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.labelColor = [UIColor whiteColor];
    hud.detailsLabelText = subTitle;
    hud.detailsLabelFont = [UIFont systemFontOfSize:13];
    hud.detailsLabelColor = [UIColor whiteColor];
    [self.view addSubview:hud];
}
- (void)removeActityLoading{
    [hud removeFromSuperview];
    hud = nil;
}
//删除文件
-(void)deleteTmpFile:(NSString *)path
{
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
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
        self.imageGenerator.maximumSize = CGSizeMake(kScreenWidth *2, kScreenWidth * 9/16 *2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(kScreenWidth, kScreenWidth * 9/16);
    }
    
    int picWidth = kScreenWidth;
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

//按钮图片在上 文字在下
- (EyeCustomBtn *)setupButtonFrame:(CGRect)frame imageName:(NSString *)imageName
{
    EyeCustomBtn *customBtn = [EyeCustomBtn buttonWithType:UIButtonTypeCustom];
    customBtn.frame = frame;
    customBtn.backgroundColor = [UIColor blackColor];
    [customBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [customBtn setTitle:@"0" forState:UIControlStateNormal];
    return customBtn;
}


#pragma mark -- 话题交互请求
/**
 *  发送话题查看请求
 */
- (void)checkTopicWithSubjectID:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure
{
    //发送话题查看请求
    NSMutableDictionary *interParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *interactListParam = [NSMutableDictionary dictionary];
    interactListParam[@"subjectId"] = subjectId;
    interactListParam[@"actType"] = @"1";//查看
    
    interParams[@"interact"] = interactListParam;
    interParams[@"loginToken"] = LoginToken;
    
    [HttpTool post:subjectInteractive_URL params:interParams success:^(id responseObj) {
        
        
        if (success) {
            success(responseObj);
        }

        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];
    
    
    
}


//是否收藏请求
- (void)favTopic:(BOOL)isFav withSubjectId:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure
{
    //发送话题 点赞/取消点赞 请求
    NSMutableDictionary *interParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *interactListParam = [NSMutableDictionary dictionary];
    interactListParam[@"subjectId"] = subjectId;
    if (isFav) {
        interactListParam[@"actType"] = @"3";//收藏
    }else{
        interactListParam[@"actType"] = @"6";//取消收藏
    }
    
    
    interParams[@"interact"] = interactListParam;
    interParams[@"loginToken"] = LoginToken;
    
    [HttpTool post:subjectInteractive_URL params:interParams success:^(id responseObj) {
        
        if (success) {
            success(responseObj);
        }
        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];
    
}

/**
 *  是否点赞请求
 */
- (void)voteTopic:(BOOL)isVote withSubjectId:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure
{
    //发送话题 点赞/取消点赞 请求
    NSMutableDictionary *interParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *interactListParam = [NSMutableDictionary dictionary];
    interactListParam[@"subjectId"] = subjectId;
    if (isVote) {
        interactListParam[@"actType"] = @"2";//点赞
    }else{
        interactListParam[@"actType"] = @"5";//取消点赞
    }
    
    
    interParams[@"interact"] = interactListParam;
    interParams[@"loginToken"] = LoginToken;
    
    [HttpTool post:subjectInteractive_URL params:interParams success:^(id responseObj) {
        
        if (success) {
            success(responseObj);
        }
        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];
    
}

/**
 *  点击分享
 *
 *  @param ctl 分享按钮所在的控制器
 */
-(void)shareClick:(UIViewController *)ctl withSubjectID:(NSString *)subjectId title:(NSString *)title
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"subjectId"] = subjectId;
    
    [HttpTool get:qryShareSubject_URL params:params success:^(id responseObj) {
        
        ZYLog(@"responseObj = %@",responseObj);
        NSString *url = responseObj[@"result"][@"url"];
        
        [self thirdShareWithUrl:url OnController:ctl title:title];
        
    } failure:^(NSError *error) {
       
        [self addActityText:@"网络错误" deleyTime:1];
        
        ZYLog(@"error = %@",error);
    }];
    
    
}


- (void)thirdShareWithUrl:(NSString *)url OnController:(UIViewController *)ctl title:(NSString *)title
{
    //QQ
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = title;
    [UMSocialData defaultData].extConfig.qqData.url = url;
    //QQ空间
    [UMSocialData defaultData].extConfig.qzoneData.title = title;
    [UMSocialData defaultData].extConfig.qzoneData.url = url;
    //微信好友
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = title;
    //微信朋友圈
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
    
//    if ([QQApiInterface isQQInstalled]) {
    
        [UMSocialSnsService presentSnsIconSheetView:ctl
                                             appKey:UMAppKey
                                          shareText:@"来自咔咔分享"
                                         shareImage:[UIImage imageNamed:@"share_icon"]
                                    shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone]
                                           delegate:nil];
        
//        NSLog(@"没安装qq或qq空间");
//        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone]];
//    }else
//    {
//        [UMSocialSnsService presentSnsIconSheetView:ctl
//                                             appKey:UMAppKey
//                                          shareText:@"咔咔iOS"
//                                         shareImage:[UIImage imageNamed:@"share_icon"]
//                                    shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline]
//                                           delegate:nil];
//    }
}

//友盟分享回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        ZYLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}



-(void)deleteSubjectWithSubjectId:(NSString *)subjectId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"subjectId"] = subjectId;
    
    [HttpTool post:deleteSubject_URL params:params success:^(id responseObj) {
        
        if (success) {
            success(responseObj);
        }
        
        
    } failure:^(NSError *error) {
        
        if (error) {
            failure(error);
        }
    }];

}

#pragma mark - Helpers


-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}

@end
