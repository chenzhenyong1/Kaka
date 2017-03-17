//
//  WeChatManager.h
//  UPark
//
//  Created by 深圳市 秀软科技有限公司 on 15/12/2.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WeChatManager : NSObject <WXApiDelegate>

+ (instancetype)shareWeChatManager;

/*! @brief 检查微信是否已被用户安装
 *
 * @return 微信已安装返回YES，未安装返回NO。
 */
-(BOOL) isWXAppInstalled;

/*!发送授权登录请求
 *
 */
- (void)sendAuthRequest;

/*通过code获取access_token
 *
 */
- (void)getAccess_tokenWithCode:(NSString *)code succeed:(Succeed)succeed failed:(Failed)failed;

// 获取微信用户信息
- (void)getWeChat_userInfoWithAccess_token:(NSString *)access_token openId:(NSString *)openId succeed:(Succeed)succeed failed:(Failed)failed;

/*
 *发送消息到微信
 */
- (void)sendMessageToWX:(NSString *)text message:(WXMediaMessage *)message bText:(BOOL)bText scene:(int)scene;
@end
