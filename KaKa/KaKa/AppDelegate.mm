//
//  AppDelegate.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/16.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeChatManager.h"
#import <WXApi.h>

#import <UMSocialWechatHandler.h>
#import <UMSocialQQHandler.h>
#import "GetIPAddress.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>
@interface AppDelegate ()   

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self.window makeKeyAndVisible];
//    [UserDefaults setObject:@"13113610723" forKey:@"UserName"];
//    [UserDefaults synchronize];
    // 初始化SDK (请前往 http://tusdk.com 获取您的 APP 开发密钥)
    //showsoft.Kaka 73da7d86d6645ab4-00-eut1q1
    //Change.Kaka 86f1b59d4c0afeba-00-gfv1q1
    [TuSDK initSdkWithAppKey:@"86f1b59d4c0afeba-00-gfv1q1"];
    [TuSDK setLogLevel:lsqLogLevelDEBUG];
    rootViewController = [[RootViewController alloc] init];
    self.window.rootViewController = rootViewController;
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:(NSString *)baiduMapKey  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //键盘处理
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;                                //控制整个功能是否启用
    manager.shouldResignOnTouchOutside = YES;            //控制点击背景是否收起键盘
    manager.shouldToolbarUsesTextFieldTintColor = YES;   //控制键盘上的工具条文字颜色是否用户自定义。
    manager.enableAutoToolbar = NO;                      //控制是否显示键盘上的工具条。
    manager.shouldShowTextFieldPlaceholder = NO;         //控制是否显示键盘上的TextField文字。
    
    
    // 向微信注册应用ID
    [WXApi registerApp:@"wx2ac14cac95a8eea1"];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UMAppKey];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx2ac14cac95a8eea1" appSecret:@"e5f049c014390d12c443744eaa93b2d5" url:@"http://www.e-eye.cn/"];
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
    [UMSocialQQHandler setQQWithAppId:@"1105472361" appKey:@"j2M9pk6Ju3goZscw" url:@"http://www.e-eye.cn/"];
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //微信登录设置
    if ([WXApi handleOpenURL:url delegate:[WeChatManager shareWeChatManager]]) {
        return YES;;
    }
    
    // qq
    if ([TencentOAuth HandleOpenURL:url]) {
        return YES;
    }
    
    return NO;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.isForceLandscape||_allowRotation)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else if (self.isForcePortrait)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    if (_allowRotation) {
//        // 允许屏幕旋转方向
//        return UIInterfaceOrientationMaskLandscapeRight;
//    }else
//    {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ON_RESIGN_ACTIVE" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ON_BECOME_ACTIVE" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 系统接收到内存警告时候调用!
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    // 1.取消下载
    [mgr cancelAll];
    
    // 2.清除内存中的所有图片
    [mgr.imageCache clearMemory];
}

@end
