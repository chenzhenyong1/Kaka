//
//  AppDelegate.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/16.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BMKMapManager* _mapManager;
    RootViewController *rootViewController;
}

@property (strong, nonatomic) UIWindow *window;
// 是否允许屏幕旋转
@property (nonatomic, assign) BOOL allowRotation;

@property (assign , nonatomic) BOOL isForceLandscape;
@property (assign , nonatomic) BOOL isForcePortrait;
@end

