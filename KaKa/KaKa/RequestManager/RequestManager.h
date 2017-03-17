//
//  RequestManager.h
//  LvXin
//
//  Created by Weiyijie on 15/9/17.
//  Copyright (c) 2015年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRGCookieManager.h"



/**
 *  生产服务器
 *  http://kakaapi.e-miv.com/appserv/
 */

/**
 *  测试服务器
 *  http://testapi.e-eye.cn:8081/appserv/
 */



#define UpLoadPicQuality 0.3
#define HeadURl @"http://kakaapi.e-miv.com/appserv/"
#define PicURl @"http://112.124.109.41:8080/PowerStation/"

#define AppId    @"3"
#define DevType  @"ios"

/**
 *  宏定义请求成功的block
 *
 *  @param response 请求成功返回的数据
 */

typedef void(^Succeed)(id responseObject);

/**
 *  宏定义请求失败的block
 *
 *  @param error 报错信息
 */
typedef void(^Failed)(NSError * error);

/**
 *  上传或者下载的进度
 *
 *  @param progress 进度
 */
typedef void (^Progress)(NSProgress *progress);
/**
*  取消下载
*
*  @param progress 取消
*/
typedef void (^Cancle)(void);

@interface RequestManager : NSObject

/**
 *  普通get方法请求网络数据
 *
 *  @param url     请求网址路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)getRequestWithUrlString:(NSString *)url params:(NSDictionary *)params succeed:(Succeed)succeed andFailed:(Failed)failed;

#pragma mark - 登录注册

/**
 账号验证（GET existUser）
 */
+ (void)existUserWithPhoneNumber:(NSString *)phone succeed:(Succeed)succeed failed:(Failed)failed;

/**
 请求短信验证（post reqAuth）
 */
+ (void)reqAuthWithPhoneNumber:(NSString *)phone succeed:(Succeed)succeed failed:(Failed)failed;

/**
 验证短信（post auth）
 */
+ (void)authWithToken:(NSString *)token authCode:(NSString *)code succeed:(Succeed)succeed failed:(Failed)failed;

/**
 注册（post register）
 */
+ (void)registerWithToken:(NSString *)token
                 nickName:(NSString *)nickName
                 password:(NSString *)password
                 phoneNum:(NSString *)phoneNum
                idCardNum:(NSString *)idCardNum //非必填
                    email:(NSString *)email     //非必填
                  succeed:(Succeed)succeed
                   failed:(Failed)failed;

/**
 更新密码（忘记、修改）（post updatePassword）
 */
+ (void)updatePasswordWithAuthToken:(NSString *)authToken newPassword:(NSString *)newPassword loginToken:(NSString *)loginToken succeed:(Succeed)succeed failed:(Failed)failed;

/**
 获取验证图片（get getCaptcha）
 图片的高度，单位：像素，必须大于等于24
 图片的宽度，单位：像素，必须大于等于65
 */
+ (void)getCaptchaWithWidth:(NSInteger)width height:(NSInteger)height succeed:(Succeed)succeed failed:(Failed)failed;

/**
 *  登录请求
 *
 *  @param userID    用于登录的ID
 *  @param idType    ID的类型 phoneNum
 *  @param password  密码
 *  @param devToken  设备token
 *  @param captchaId 验证码ID
 *  @param captcha   验证码
 *  @param succeed   成功
 *  @param failed    失败
 */

+ (void)loginWithID:(NSString *)userID
             idType:(NSString *)idType
           password:(NSString *)password
           devToken:(NSString *)devToken
          captchaId:(NSString *)captchaId
            captcha:(NSString *)captcha
            succeed:(Succeed)succeed
             failed:(Failed)failed;

/**
 *  第三方登录
 *
 *  @param channel     第三方ID qq wechat 必需
 *  @param devToken    设备的友盟令牌
 *  @param accessToken 第三方登录返回的 accessToken 必需
 *  @param openId      第三方登录返回的openId，有些渠道在此阶段提供openId，如qq
 *  @param succeed     成功返回数据
 *  @param failed      失败返回错误
 */
+ (void)thirdPartyLoginWithChannel:(NSString *)channel devToken:(NSString *)devToken accessToken:(NSString *)accessToken openId:(NSString *)openId succeed:(Succeed)succeed failed:(Failed)failed;

#pragma mark - 用户中心
/**
 *  查询用户信息
 *
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)qryUserInfoSucceed:(Succeed)succeed failed:(Failed)failed;

/**
 *  6.6.	更新用户一般信息接口 (POST updateUserInfo)
 *
 *  @param registerToken 先前在注册过程中返回的注册令牌
 *  @param userInfo      所要更新的用户信息，用户信息的属性中，不包含userId, password, phoneNum等属性。
 *  @param succeed       请求成功回调
 *  @param failed        请求失败回调
 */
+ (void)postUpdateUserInfoWithUserInfo:(NSDictionary *)userInfo succeed:(Succeed)succeed failed:(Failed)failed;
/**
 *  查询用户消息
 *  注意：按消息时间查询时，为了应对服务器时间调整的情况，服务端将实际返回时间比请求的消息时间稍提前10分钟的消息，故返回的结果可能和上次查询返回的结果有重复的消息，应用端应注意处理重复的情况
 *  lastMsgTime msgId两者只能提供其一
 *
 *  @param lastMsgTime 最后一次获得的消息的最后的消息时间（createTime属性最大者，长整型，epoch毫秒数）。首次检取时，本参数可传0。按最后消息时间查询将检取此时间后的所有消息记录（为了应对服务器时间调整的情况，服务端将实际返回时间比请求的消息时间稍提前10分钟的消息）
 *  @param msgId       消息ID
 *  @param succeed     成功返回数据
 *  @param failed      失败返回错误
 */
+ (void)qryUserMessagesWithLastMsgTime:(NSString *)lastMsgTime msgId:(NSString *)msgId Succeed:(Succeed)succeed failed:(Failed)failed;

/**
 *  更新消息属性
 *
 *  @param msgId   id
 *  @param readed  消息是否已读
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)updateMsgAttrsWithMsgId:(NSString *)msgId readed:(BOOL)readed Succeed:(Succeed)succeed failed:(Failed)failed;

/**
 *  删除消息
 *
 *  @param msgIdsArray   id数组
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)delMsgWithMsgIdsArray:(NSArray *)msgIdsArray Succeed:(Succeed)succeed failed:(Failed)failed;


//获取摄像头版本信息
+(void)getSystemDataWithSucceed:(Succeed)succeed failed:(Failed)failed;


//批量下载
+ (NSMutableArray *)downloadFileWithURL:(NSArray *)url_array destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination;

//循环文件下载
+(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                    progress:(Progress )progress
                                     succeed:(Succeed)succeed
                                   andFailed:(Failed)failed cancle:(Cancle)cancle;
//文件下载
+(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                    progress:(Progress )progress
                                     succeed:(Succeed)succeed
                                   andFailed:(Failed)failed;
//上传
+(void)uploadWithURL:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)filedata name:(NSString *)name fileName:(NSString *)filename mimeType:(NSString *) mimeType progress:(Progress)progress success:(Succeed)success fail:(Failed)fail;

@end
