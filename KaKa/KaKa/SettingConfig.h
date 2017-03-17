//
//  SettingConfig.h
//  LvXin
//
//  Created by wei_yijie on 15/9/1.
//  Copyright (c) 2015年 showsoft. All rights reserved.
//
//  系统语言和字体修改配置单例

#import <Foundation/Foundation.h>
#import "CameraListModel.h"

typedef enum{
    SimpleChinese,
    TraditionalChinese,
    English
}LanguageType ;

typedef enum{
    SuperBig,
    Big,
    Normal,
    Small
}FontType ;

@interface SettingConfig : NSObject

@property (nonatomic,assign) LanguageType languege;

@property (nonatomic,assign) FontType fontSize;


@property (nonatomic, assign) BOOL isLogin;//是否点击了登录界面登录按钮

@property (nonatomic, assign) BOOL isLogout;//是否点击了退出按钮

@property (nonatomic, strong) NSString *phone;//账号
@property (nonatomic, strong) NSString *passWord;//密码

@property (nonatomic, copy) NSString *loginToken; // 登录成功获取的token值
@property (nonatomic, copy) NSString *deviceLoginToken; // 登录摄像机成功获取的token值

@property (nonatomic, strong) CameraListModel *currentCameraModel; // 当前选择摄像头

@property (nonatomic, strong) NSString *mac_address;

@property (nonatomic, strong) NSString *voip_account;//用户容联账号
@property (nonatomic, strong) NSString *voip_pwd;//用户容联密码
@property (nonatomic, copy) NSString *ip_url;//ip
@property (nonatomic, assign) BOOL isOpen;//下载开关是否打开
@property (nonatomic, assign) BOOL isPhotoWithVideo;//拍照关联视频

@property (nonatomic, strong) NSString *isDownload;

@property (nonatomic, strong) UIViewController *currentViewController;


// 网络是否连接
@property (nonatomic,assign) BOOL isNetworkConnect;

+ (SettingConfig *)shareInstance;

+ (void)releaseInstance;

@end
