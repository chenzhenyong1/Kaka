//
//  QQManager.m
//  UPark
//
//  Created by 深圳市 秀软科技有限公司 on 15/12/2.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import "QQManager.h"

#define APP_ID @"1105472361"
#define APP_KEY @"j2M9pk6Ju3goZscw"



@interface QQManager () <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *oAuth;
@end

@implementation QQManager

static QQManager *manager = nil;

+ (instancetype)shareQQManager
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
        
        manager.oAuth = [[TencentOAuth alloc] initWithAppId:APP_ID andDelegate:manager];
    }) ;
    
    return manager ;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [QQManager shareQQManager];
}

- (void)authorize
{
    
    NSArray *permissions = [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    
    [_oAuth authorize:permissions];
}

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
//    // 获取用户信息
//    [_oAuth getUserInfo];
    if (_delegate && [_delegate respondsToSelector:@selector(didGetOAuth:)]) {
        [_delegate didGetOAuth:_oAuth];
    }
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*)response
{
    if (_delegate && [_delegate respondsToSelector:@selector(didGetUserInfoResponse:oAuth:)]) {
        [_delegate didGetUserInfoResponse:response oAuth:_oAuth];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (_delegate && [_delegate respondsToSelector:@selector(didNotLogin)]) {
        [_delegate didNotLogin];
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    if (_delegate && [_delegate respondsToSelector:@selector(didNotNetWork)]) {
        [_delegate didNotNetWork];
    }
}

- (void)sendMessageToQQ:(QQApiObject *)message
{
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:message];
    
   [QQApiInterface sendReq:req];
    
}
@end
