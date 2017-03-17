//
//  QQManager.h
//  UPark
//
//  Created by 深圳市 秀软科技有限公司 on 15/12/2.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>

@protocol QQManagerDelegate <NSObject>

@optional
- (void)didGetUserInfoResponse:(APIResponse*)response oAuth:(TencentOAuth *)oAuth;
- (void)didGetOAuth:(TencentOAuth *)oAuth;
- (void)didNotLogin;
- (void)didNotNetWork;

@end

@interface QQManager : NSObject

@property (nonatomic, weak) id <QQManagerDelegate> delegate;

+ (instancetype)shareQQManager;

- (void)authorize;

- (void)sendMessageToQQ:(QQApiObject *)message;
@end
