//
//  RootViewController.m
//  BaseFrame
//
//  Created by wei_yijie on 16/6/21.
//  Copyright (c) 2015年 showsoft. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RootViewController.h"

#import "LoginViewController.h"

#import "DiscoverViewController.h"
#import "CameraViewController.h"
#import "AlbumsViewController.h"
#import "MeViewController.h"

#import "EyeFindViewController.h"
#import "EyeNavigationController.h"
#import "MyTools.h"
#import "CameraSettingViewController.h"
#import "CameraDetailViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <TuSDKGeeV1/TuSDKGeeV1.h>
@interface RootViewController ()<UITabBarControllerDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,TuSDKFilterManagerDelegate>
{
    UITabBarController *tabbarController;
    LoginViewController *loginViewController;
    UINavigationController *loginNavgationController;
    
    EyeNavigationController *nav1;
    UINavigationController *nav2;
    UINavigationController *nav3;
    UINavigationController *nav4;
    
    BOOL isSocketDisconnectAlertViewShowEnable;
    
    NSURLSessionDownloadTask *downloadtask;
}
@property (nonatomic, strong) UILabel *progress_lab;
@property (nonatomic, strong) UILabel *freeProgressView;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;

//下载进度
@property (nonatomic, assign) double progress_download;

@end

@implementation RootViewController
{
    NSString *upload_zip;
    NSString *camera_version;
    MBProgressHUD *hud;
    //遮盖
    UIView *_cover;
    //是否显示
    BOOL _isOpen;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [TuSDK checkManagerWithDelegate:self];
    //添加Tabbar
    [self addTabbar];
    
    //添加登陆界面
    
    if (![SettingConfig shareInstance].isLogin)
    {
        [self addLoginView:NO];
    }
    else
    {
        NSString *mac_address = [SettingConfig shareInstance].mac_address;
        
        if ([UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",mac_address]])
        {
            [self getSystemData];
        }
        
        
    }
    
    //注册通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginStatusNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusNotification:) name:@"loginStatusNotification" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SocketConnectStateNotif" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnectStateNotif:) name:@"SocketConnectStateNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle) name:@"ON_RESIGN_ACTIVE" object:nil];
    
//    [NotificationCenter postNotificationName:@"FindCtlSetupNavNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNav) name:@"FindCtlSetupNavNotification" object:nil];
//    [NotificationCenter addObserver:self selector:@selector(setupNav) name:@"FindCtlSetupNavNotification" object:nil];
}

/**
 进入前台
 */
- (void)onApplicationDidBecomeActiveHandle
{
    if (downloadtask)
    {
        downloadtask = nil;
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Upload"];
        
        NSString *file_Path = [documentsDirectoryURL absoluteString];
        // 判断文件夹是否存在，如果不存在，则创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
        else
        {
            NSLog(@"文件夹已存在");
        }
         __weak __typeof(self) weakSelf = self;
         [self list_click];
     downloadtask =  [ [AFHTTPSessionManager manager] downloadTaskWithResumeData:self.resumeData progress:^(NSProgress * _Nonnull downloadProgress)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progress_lab.text = [NSString stringWithFormat:@"正在下载 %.2f%%",downloadProgress.fractionCompleted*100];
                weakSelf.progress_download = downloadProgress.fractionCompleted;
                [UIView animateWithDuration:2 animations:^{
                    CGRect frame = weakSelf.freeProgressView.frame;
                    frame.size.width = (500*downloadProgress.fractionCompleted)*PSDSCALE_X;
                    weakSelf.freeProgressView.frame = frame;
                } completion:^(BOOL finished) {
                    
                }];
            });
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error)
            {
                [self dismissList];
                if (weakSelf.progress_download == 0)
                {
                    [self addActityText:@"升级包下载失败" deleyTime:1];
                }
                
                [self deleteDirInCache];
            }else
            {
                downloadtask = nil;
                weakSelf.progress_download = 0.0;
                NSLog(@"下载完成");
                NSString *mac_address = [SettingConfig shareInstance].mac_address;
                [UserDefaults setObject:camera_version forKey:[NSString stringWithFormat:@"version_%@",mac_address]];
                [UserDefaults synchronize];
                [self dismissList];
            }
        }];
        [downloadtask resume];
    }
}

//进入后台
- (void)onApplicationWillResignActiveHandle
{
    if (downloadtask) {
        __weak typeof(self) selfVc = self;
        [downloadtask cancelByProducingResumeData:^(NSData *resumeData) {
            //  resumeData : 包含了继续下载的开始位置\下载的url
            selfVc.resumeData = resumeData;
        }];
    }
}


#pragma -mark TuSDKFilterManagerDelegate
- (void)onTuSDKFilterManagerInited:(TuSDKFilterManager *)manager;
{
    // 可以将方法去掉，不进行初始化完成的提示
    NSLog(@"初始化完成");
}

- (void)socketConnectStateNotif:(NSNotification *)notif {
    
    NSString *BSSID;
    if ([[self getSSIDInfo] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic =  [self getSSIDInfo];
        BSSID = VALUEFORKEY(dic, @"BSSID");
        BSSID = [BSSID uppercaseString];
        NSArray *BSSIDS = [BSSID componentsSeparatedByString:@":"];
        NSMutableArray *temp_arr = [NSMutableArray array];
        for (NSString *str in BSSIDS)
        {
            if (str.length < 2)
            {
                NSString *temp_str = [NSString stringWithFormat:@"0%@",str];
                [temp_arr addObject:temp_str];
            }
            else
            {
                [temp_arr addObject:str];
            }
            
        }
        BSSID = [temp_arr componentsJoinedByString:@""];
    }

    BOOL isSocketConnect = [notif.object boolValue];
    if (isSocketConnect) {
        isSocketDisconnectAlertViewShowEnable = YES;
    }
    
    if (isSocketDisconnectAlertViewShowEnable) {
        
        if ([BSSID isEqualToString:[SettingConfig shareInstance].currentCameraModel.macAddress]) {
            // 如果等于当前macAddress
            // 重新登录
            [self reLogin];
        } else {
            // 不等，退出
            if (isSocketDisconnectAlertViewShowEnable && !isSocketConnect) {
                if ([SettingConfig shareInstance].currentViewController) {
                    UIViewController *tempVC = nil;
                    for (UIViewController *vc in [SettingConfig shareInstance].currentViewController.navigationController.childViewControllers) {
                        if ([vc isKindOfClass:[CameraSettingViewController class]] || [vc isKindOfClass:[CameraDetailViewController class]]) {
                            tempVC = vc;
                            break;
                        }
                    }
                    
                    if (tempVC) {
                        UIAlertView *socketDisconnectAlertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"摄像头连接断开，请重新连接" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        socketDisconnectAlertView.tag = 100;
                        [socketDisconnectAlertView show];
                    }
                }
                
            }
            
        }

    }
    
}

// 重新登录
- (void)reLogin {
    NSString *userName = [UserDefaults objectForKey:[NSString stringWithFormat:@"CameraUserName_%@",[SettingConfig shareInstance].currentCameraModel.macAddress]];
    NSString *passwd = [UserDefaults objectForKey:[NSString stringWithFormat:@"CameraPassword_%@",[SettingConfig shareInstance].currentCameraModel.macAddress]];
    if (userName == nil) {
        userName = DefaultUserName;
    }
    if (passwd == nil) {
        passwd = DefaultPWD;
    }
    MsgModel * msg = [[MsgModel alloc]init];
    msg.cmdId = @"01";
    msg.msgSN = @"0001";
    msg.token = @"0000000000000000000000000000000000000000000000000000000000000000";
    NSString *msgBody = [NSString stringWithFormat:@"username:%@&passwd:%@", userName, passwd];
    msg.msgBody = msgBody;
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
    }];


}
- (id)getSSIDInfo  //引用
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info;
    
    /**
     {
     BSSID = "e0:b9:4d:6c:9d:d";
     SSID = "KAKA_C9D0D";
     SSIDDATA = <4b414b41 5f433944 3044>;
     }
     */
}



//#pragma mark - UIStatusBarStyle
///**
// *  改变状态栏样式
// *
// *  @return 样式
// */
//- (UIStatusBarStyle)preferredStatusBarStyle{
//    //plist里 View controller-based status bar appearance = YES 设置才有效
//    return UIStatusBarStyleLightContent;
//}

/**
 *  是否隐藏导航栏
 *
 *  @return YES/NO
 */
//- (BOOL)prefersStatusBarHidden{
//    return NO;
//}

#pragma mark - LoginViewController
- (void)loginStatusNotification:(NSNotification *)notification{
    if (![notification.object boolValue]) {
        if (!loginViewController) {
            [self addLoginView:YES];
        }
    }else{
        [NotificationCenter postNotificationName:@"FindCtlSetupNavNotification" object:nil];
        if (loginViewController) {
            [loginViewController removeFromParentViewController];
            [loginViewController.view removeFromSuperview];
            loginViewController = nil;
        }
        if (loginNavgationController)
        {
            [loginNavgationController removeFromParentViewController];
            [loginNavgationController.view removeFromSuperview];
            loginNavgationController = nil;
        }
        NSString *mac_address = [SettingConfig shareInstance].mac_address;
        
        if ([UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",mac_address]])
        {
            [self getSystemData];
        }
    }
    
//    [NotificationCenter postNotificationName:@"FindCtlSetupNavNotification" object:nil];
}

- (void)addLoginView:(BOOL)animation{
    [loginViewController removeFromParentViewController];
    self.navigationController.navigationBarHidden = YES;
    loginViewController = [[LoginViewController alloc] init];
    loginNavgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self.view addSubview:loginNavgationController.view];
    [self addChildViewController:loginNavgationController];
    if (animation) {
        loginViewController.view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            loginViewController.view.alpha = 1;
        }];
    }
}

- (void)addTabbar{
    EyeFindViewController *discoverVC = [[EyeFindViewController alloc] init];
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    AlbumsViewController *albumsVC = [[AlbumsViewController alloc] init];
    MeViewController *meVC = [[MeViewController alloc] init];
    
    tabbarController = [[UITabBarController alloc] init];
    tabbarController.tabBar.backgroundColor = [UIColor orangeColor];
    tabbarController.delegate = self;
    
    if (STATUSBARHEIGHT > 20) {
        // 如果有热点连接的情况，把view往上提
        tabbarController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - 20);
    }
    
    nav1 = [[EyeNavigationController alloc] initWithRootViewController:discoverVC];
    nav2 = [[UINavigationController alloc] initWithRootViewController:cameraVC];
    nav3 = [[UINavigationController alloc] initWithRootViewController:albumsVC];
    nav4 = [[UINavigationController alloc] initWithRootViewController:meVC];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tabbar_title_1", nil) image:GETTABIMAGE(@"tabbar_icon_1_nor") selectedImage:GETTABIMAGE(@"tabbar_icon_1_sel")];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tabbar_title_2", nil) image:GETTABIMAGE(@"tabbar_icon_2_nor") selectedImage:GETTABIMAGE(@"tabbar_icon_2_sel")];
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tabbar_title_3", nil) image:GETTABIMAGE(@"tabbar_icon_3_nor") selectedImage:GETTABIMAGE(@"tabbar_icon_3_sel")];
    UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tabbar_title_4", nil) image:GETTABIMAGE(@"tabbar_icon_4_nor") selectedImage:GETTABIMAGE(@"tabbar_icon_4_sel")];
    
    [item1 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"b11c22")} forState:UIControlStateSelected];
    [item2 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"b11c22")} forState:UIControlStateSelected];
    [item3 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"b11c22")} forState:UIControlStateSelected];
    [item4 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"b11c22")} forState:UIControlStateSelected];
    
    [item1 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"cccccc")} forState:UIControlStateNormal];
    [item2 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"cccccc")} forState:UIControlStateNormal];
    [item3 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"cccccc")} forState:UIControlStateNormal];
    [item4 setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBSTRING(@"cccccc")} forState:UIControlStateNormal];
    
    nav1.tabBarItem = item1;
    nav2.tabBarItem = item2;
    nav3.tabBarItem = item3;
    nav4.tabBarItem = item4;
    
    item1.titlePositionAdjustment = UIOffsetMake(0, -2);
    item2.titlePositionAdjustment = UIOffsetMake(0, -2);
    item3.titlePositionAdjustment = UIOffsetMake(0, -2);
    item4.titlePositionAdjustment = UIOffsetMake(0, -2);

    tabbarController.viewControllers = [NSArray arrayWithObjects:nav1, nav2, nav3, nav4, nil];
    tabbarController.tabBar.backgroundColor = WHITE_COLOR;
    [self.view addSubview:tabbarController.view];
    
    [tabbarController setSelectedIndex:0];
}



- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

#pragma mark - UITabberViewControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    if (tabBarController.selectedIndex == 3) {
//        [self addLoginView:YES];
//    }
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
//        self.view.backgroundColor = [UIColor whiteColor];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"revolution" object:@"0"];
//    }
//    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//        self.view.backgroundColor = [UIColor blackColor];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"revolution" object:@"1"];
//    }
//}

- (void)getSystemData
{
    [RequestManager getSystemDataWithSucceed:^(id responseObject) {
       NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        MMLog(@"===========%@",dic);
        
        if ([FORMATSTRING(VALUEFORKEY(dic, @"errCode")) isEqualToString:@"-26"])
        {
            [NotificationCenter postNotificationName:@"loginStatusNotification" object:@"0"];
            [SettingConfig shareInstance].isLogin = NO;
            [SettingConfig shareInstance].ip_url = nil;
            [SettingConfig shareInstance].currentCameraModel = nil;
            [SettingConfig shareInstance].deviceLoginToken = nil;
            return;
        }
        
        NSDictionary *result = VALUEFORKEY(dic, @"result");
        NSArray *itemList = VALUEFORKEY(result, @"itemList");
        if ([itemList isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *temp_dic in itemList)
            {
                NSString *propName = VALUEFORKEY(temp_dic, @"propName");
                if ([propName isEqualToString:@"camera-firmware-download"])
                {
                    upload_zip = VALUEFORKEY(temp_dic, @"propValue");
                }
                if ([propName isEqualToString:@"camera-firmware-version"])
                {
                    NSString *version = VALUEFORKEY(temp_dic, @"propValue");
                    camera_version = version;
                    
                    NSString *mac_address = [SettingConfig shareInstance].mac_address;
                    NSString *old_camera_version = [UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",mac_address]];
                    
                    if ([version doubleValue]>[old_camera_version doubleValue])
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"摄像头已有新版本，是否下载" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                        [alertView show];
                    }
                    
//                    if (![[UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",mac_address]] length])
//                    {
//                        if ([version doubleValue]>1.0)
//                        {
//                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"摄像头已有新版本，是否下载" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
//                            [alertView show];
//                        }
//                    }
//                    else
//                    {
//                        
//                    }
                    
                }
            }
        }
    } failed:^(NSError *error) {
        MMLog(@"%@",error);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        // 摄像头添加断开
        [[SettingConfig shareInstance].currentViewController.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    switch (buttonIndex) {
        case 1:
        {
            [self downloadUpgrade_package];
        }
            break;
            
        default:
            break;
    }
}

/**
 *  下载升级包
 */
- (void)downloadUpgrade_package
{
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Upload"];
    
    NSString *file_Path = [documentsDirectoryURL absoluteString];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        NSLog(@"文件夹已存在");
    }
    __weak __typeof(self) weakSelf = self;
    [self list_click];
    downloadtask = [RequestManager downloadWithURL:upload_zip savePathURL:documentsDirectoryURL progress:^(NSProgress *progress)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progress_lab.text = [NSString stringWithFormat:@"正在下载 %.2f%%",progress.fractionCompleted*100];
            weakSelf.progress_download = progress.fractionCompleted;
            [UIView animateWithDuration:2 animations:^{
                CGRect frame = weakSelf.freeProgressView.frame;
                frame.size.width = (500*progress.fractionCompleted)*PSDSCALE_X;
                weakSelf.freeProgressView.frame = frame;
            } completion:^(BOOL finished) {
                
            }];
        });
    } succeed:^(id responseObject) {
        NSLog(@"下载完成");
        downloadtask = nil;
        weakSelf.progress_download = 0.0;
        NSString *mac_address = [SettingConfig shareInstance].mac_address;
        [UserDefaults setObject:camera_version forKey:[NSString stringWithFormat:@"version_%@",mac_address]];
        [UserDefaults synchronize];
        [self dismissList];
        
    } andFailed:^(NSError *error) {
        
        [self dismissList];
        if (weakSelf.progress_download == 0)
        {
            [self addActityText:@"升级包下载失败" deleyTime:1];
        }
        [self deleteDirInCache];
    }];
}


//删除文件

-(void)deleteDirInCache
{
    NSArray *path_arr = [MyTools getAllDataWithPath:Upload_Path mac_adr:@"upload"];
    
    for (NSString *path in path_arr)
    {
        //不存在就下载
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}




- (void)list_click
{
    [self addCoverToView:self.view];
}

- (void)dismissList
{
    [_cover removeFromSuperview];
}

//设置遮盖
- (void)addCoverToView:(UIView *)view
{
    _cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _cover.backgroundColor = [[UIColor colorWithRed:177/255.0f green:177/255.0f blue:177/255.0f alpha:YES] colorWithAlphaComponent:0.3];
    [self.view addSubview:_cover];

    [self initUI];
}


- (void)initUI
{
    UIView *bg_View = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-580*PSDSCALE_X)/2, (VIEW_H(_cover)-150*PSDSCALE_Y)/2, 580*PSDSCALE_X, 230*PSDSCALE_Y)];
    bg_View.backgroundColor = [UIColor whiteColor];
    bg_View.layer.masksToBounds = YES;
    bg_View.layer.cornerRadius = 5;
    [_cover addSubview:bg_View];
    
    self.progress_lab = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, 20*PSDSCALE_Y, VIEW_W(_cover)-40*PSDSCALE_X, 42*PSDSCALE_Y)];
    self.progress_lab.textAlignment = NSTextAlignmentLeft;
    self.progress_lab.textColor = [UIColor blackColor];
    self.progress_lab.text = @"正在下载 0.00%";
    self.progress_lab.font = [UIFont systemFontOfSize:32*FONTCALE_Y];
    [bg_View addSubview:self.progress_lab];
    
    
    UIView *allProgressView = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, VIEW_H_Y(self.progress_lab)+36*PSDSCALE_Y, 500*PSDSCALE_X, 23*PSDSCALE_Y)];
    allProgressView.backgroundColor = RGBSTRING(@"dcdcdc");
    allProgressView.layer.masksToBounds = YES;
    allProgressView.layer.cornerRadius = 6;
    [bg_View addSubview:allProgressView];
    
    
    _freeProgressView = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, VIEW_H_Y(self.progress_lab)+36*PSDSCALE_Y, 0, 23*PSDSCALE_Y)];
    _freeProgressView.backgroundColor = [UIColor blueColor];
    _freeProgressView.layer.masksToBounds = YES;
    _freeProgressView.layer.cornerRadius = 6;
    [bg_View addSubview:_freeProgressView];
    
    UIButton *cancel_btn = [[UIButton alloc] initWithFrame:CGRectMake(230*PSDSCALE_X, VIEW_H_Y(allProgressView)+20*PSDSCALE_Y, 120*PSDSCALE_X, 60*PSDSCALE_Y)];
    [cancel_btn.layer setMasksToBounds:YES];
    [cancel_btn.layer setCornerRadius:5.0]; //设置矩圆角半径
    [cancel_btn.layer setBorderWidth:1.0];   //边框宽度
    cancel_btn.layer.borderColor = [UIColor blueColor].CGColor;
    [cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [cancel_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancel_btn.titleLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [bg_View addSubview:cancel_btn];
    [cancel_btn addTarget:self action:@selector(cancel_click) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.progress_download >0)
    {
        CGRect frame = self.freeProgressView.frame;
        frame.size.width = (500*self.progress_download)*PSDSCALE_X;
        self.freeProgressView.frame = frame;
    }
    

}


- (void)cancel_click
{
    [self dismissList];
    [downloadtask cancel];
}



//文字提示框
- (void)addActityText:(NSString *)text deleyTime:(float)duration;
{
    [hud removeFromSuperview];
    hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.color = RGBACOLOR(102, 102, 102, 1);
    hud.labelText = text;
    hud.margin = 15;
    hud.cornerRadius = 3;
    [hud hide:YES afterDelay:duration];
}



@end
