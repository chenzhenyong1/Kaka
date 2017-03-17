//
//  WeChatManager.m
//  UPark
//
//  Created by 深圳市 秀软科技有限公司 on 15/12/2.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import "WeChatManager.h"

#define BASE_HEAD_URL   @"https://api.weixin.qq.com/sns/"

#define APP_ID          @"wx2ac14cac95a8eea1"               //APPID
#define APP_SECRET      @"e5f049c014390d12c443744eaa93b2d5" //appsecret

#define SCOPE           @"snsapi_userinfo"
#define STATE           @"KaKa"

#define GRANT_TYPE      @"authorization_code"

@implementation WeChatManager

static WeChatManager *manager = nil;

+ (instancetype)shareWeChatManager
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    }) ;
    
    return manager ;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [WeChatManager shareWeChatManager];
}

/*! @brief 检查微信是否已被用户安装
 *
 * @return 微信已安装返回YES，未安装返回NO。
 */
- (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

/*!发送授权登录请求
 *
 */
- (void)sendAuthRequest
{
    SendAuthReq *authReq = [[SendAuthReq alloc] init];
    authReq.scope = SCOPE;
    authReq.state = STATE;
    
    [WXApi sendReq:authReq];
}

/*通过code获取access_token
 *
 */
- (void)getAccess_tokenWithCode:(NSString *)code succeed:(Succeed)succeed failed:(Failed)failed
{
    NSString *urlString = [BASE_HEAD_URL stringByAppendingString:[NSString stringWithFormat:@"oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=%@", APP_ID, APP_SECRET, code, GRANT_TYPE]];
    
    [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

// 获取微信用户信息
- (void)getWeChat_userInfoWithAccess_token:(NSString *)access_token openId:(NSString *)openId succeed:(Succeed)succeed failed:(Failed)failed
{
    NSString *urlString = [BASE_HEAD_URL stringByAppendingString:[NSString stringWithFormat:@"userinfo?access_token=%@&openid=%@", access_token, openId]];
    
    [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

/*
 *发送消息到微信
 */
- (void)sendMessageToWX:(NSString *)text message:(WXMediaMessage *)message bText:(BOOL)bText scene:(int)scene
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = text;
    req.message = message;
    req.bText = bText;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {

    }
    if([resp isKindOfClass:[PayResp class]]) {
        
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        SendAuthResp *authResp = (SendAuthResp *)resp;
        switch (authResp.errCode) {
                case 0:
            {
                // 认证和权限成功
                [NotificationCenter postNotificationName:@"WeChat_Auth_Code" object:authResp.code];
            }
                break;
                case -2:
                strMsg = @"用户拒绝授权！";
                break;
                case -4:
                strMsg = @"用户取消授权！";
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"授权结果：失败！retcode = %d, retstr = %@", authResp.errCode,authResp.errStr];
                break;
        }
        
        
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:strMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
}


@end
