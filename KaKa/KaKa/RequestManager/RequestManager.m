//
//  RequestManager.m
//  LvXin
//
//  Created by Weiyijie on 15/9/17.
//  Copyright (c) 2015年 showsoft. All rights reserved.
//

#import "RequestManager.h"
#import "AFNetworking.h"

@implementation RequestManager

#pragma mark -基本的GET 和POST请求
//https://github.com/AFNetworking/AFNetworking
//---******************************-------带附件 POST请求

+(void)uploadWithURL:(NSString *)url params:(NSDictionary *)params name:(NSString *)name photos:(NSArray*)_photosArray progress:(Progress)progress Succeed:(Succeed)succeed andFailed:(Failed)failed
{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i < [_photosArray count]; i ++) {
            UIImage *loc_image = [_photosArray objectAtIndex:i];
            NSData *dataObj = UIImageJPEGRepresentation(loc_image, UpLoadPicQuality);
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
            [formater setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
            [formData appendPartWithFileData:dataObj name:@"upload_file" fileName:[NSString stringWithFormat:@"%@.jpg",[formater stringFromDate:[NSDate date]]] mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        succeed(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

//*************************************基本的GET 和POST请求

/**
 *  普通get方法请求网络数据
 *
 *  @param url     请求网址路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)getRequestWithUrlString:(NSString *)url params:(NSDictionary *)params succeed:(Succeed)succeed andFailed:(Failed)failed{
    
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

/**
 *  普通post方法请求网络数据
 *
 *  @param url     请求网址路径
 *  @param params  请求参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)postRequestWithUrlString:(NSString *)url params:(NSDictionary *)params succeed:(Succeed)succeed andFailed:(Failed)failed
{
    if ([[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]] count] !=0) {
        [PRGCookieManager setCookie];
    }
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

//不调验证的方法
+ (void)noCheckPostRequestWithUrlString:(NSString *)urlString withDic:(NSDictionary *)dic Succeed:(Succeed)succeed andFaild:(Failed)failed
{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager POST:urlString parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error);
    }];
}

#pragma mark - 登录注册

/**
 账号验证（GET existUser）
 */
+ (void)existUserWithPhoneNumber:(NSString *)phone succeed:(Succeed)succeed failed:(Failed)failed{
    
    NSString *url = [HeadURl stringByAppendingString:@"existUser"];
    NSDictionary *param_dic = @{@"appId":AppId,
                                @"phoneNum":phone,
                                };
    [RequestManager getRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

/**
 请求短信验证（post reqAuth）
 */
+ (void)reqAuthWithPhoneNumber:(NSString *)phone succeed:(Succeed)succeed failed:(Failed)failed{
    NSString *url = [HeadURl stringByAppendingString:@"reqAuth"];
    NSDictionary *param_dic = @{@"appId":AppId,
                                @"authMethod":@"sms",
                                @"arg":phone,
                                @"usedForAuth":@(YES)
                                };
    [RequestManager noCheckPostRequestWithUrlString:url withDic:param_dic Succeed:^(id responseObject) {
        succeed(responseObject);
    } andFaild:^(NSError *error) {
        failed(error);
    }];}

/**
 验证短信（post auth）
 */
+ (void)authWithToken:(NSString *)token authCode:(NSString *)code succeed:(Succeed)succeed failed:(Failed)failed {
    NSString *url = [HeadURl stringByAppendingString:@"auth"];
    NSDictionary *param_dic = @{@"authToken":token,
                                @"authMethod":@"sms",
                                @"captcha":code
                                };
    [RequestManager noCheckPostRequestWithUrlString:url withDic:param_dic Succeed:^(id responseObject) {
        succeed(responseObject);
    } andFaild:^(NSError *error) {
        failed(error);
    }];
}

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
                   failed:(Failed)failed{
    NSString *url = [HeadURl stringByAppendingString:@"register"];
    NSDictionary *param_dic = @{@"authToken":token,
                                @"nickName":nickName,
                                @"password":password,
                                @"phoneNum":phoneNum,
                                @"idCardNum":idCardNum,
                                @"appId":AppId,
                                @"email":email
                                };
    [RequestManager postRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

/**
 更新密码（忘记、修改）（post updatePassword）
 */
+ (void)updatePasswordWithAuthToken:(NSString *)authToken newPassword:(NSString *)newPassword loginToken:(NSString *)loginToken succeed:(Succeed)succeed failed:(Failed)failed{
    NSString *url = [HeadURl stringByAppendingString:@"updatePassword"];
    
    if (loginToken == nil) {
        /**
         *  忘记密码
         */
        NSDictionary * param_dic = @{@"newPassword":newPassword,
                                     @"authToken":authToken,
                                     };
        [RequestManager postRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
            succeed(responseObject);
        } andFailed:^(NSError *error) {
            failed(error);
        }];
        
    } else {
        NSDictionary * param_dic = @{@"newPassword":newPassword,
                                     @"authToken":authToken,
                                     @"loginToken":loginToken,
                                     };
        [RequestManager postRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
            succeed(responseObject);
        } andFailed:^(NSError *error) {
            failed(error);
        }];
    }
    
    
}



/**
 获取验证图片（get getCaptcha）
 图片的高度，单位：像素，必须大于等于24
 图片的宽度，单位：像素，必须大于等于65
 */
+ (void)getCaptchaWithWidth:(NSInteger)width height:(NSInteger)height succeed:(Succeed)succeed failed:(Failed)failed{
    NSString *url = [HeadURl stringByAppendingString:@"getCaptcha"];
    NSDictionary *param_dic = @{@"width":@(width),
                                @"height":@(height),
                                };
    
    [RequestManager getRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];

}


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
             failed:(Failed)failed{
    
    NSString *url = [HeadURl stringByAppendingString:@"login"];
    NSDictionary *param_dic = @{@"appId":AppId,
                                @"id":userID,
                                @"idType":idType,
                                @"password":password,
                                @"devType":DevType,
                                @"devToken":devToken,
                                @"captchaId":captchaId,
                                @"captcha":captcha
                                };
    [RequestManager postRequestWithUrlString:url params:param_dic succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

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
+ (void)thirdPartyLoginWithChannel:(NSString *)channel devToken:(NSString *)devToken accessToken:(NSString *)accessToken openId:(NSString *)openId succeed:(Succeed)succeed failed:(Failed)failed {
    
    NSString *urlString = [HeadURl stringByAppendingString:@"thirdPartyLogin"];
    
    if (!openId) {
        openId = @"";
    }
    
    if (!devToken) {
        devToken = @"";
    }
    
    NSDictionary *params = @{@"appId":@(3),
                             @"channel":channel,
                             @"devType":@"ios",
                             @"devToken":devToken,
                             @"accessToken":accessToken,
                             @"openId":openId
                             };
    
    [RequestManager postRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];

}

#pragma mark - 用户中心
/**
 *  查询用户信息
 *
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)qryUserInfoSucceed:(Succeed)succeed failed:(Failed)failed {
    
    NSString *urlString = [HeadURl stringByAppendingString:@"qryUserInfo"];
    
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"loginToken":loginToken};
    
    [RequestManager getRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

/**
 *  6.6.	更新用户一般信息接口 (POST updateUserInfo)
 *
 *  @param registerToken 先前在注册过程中返回的注册令牌
 *  @param userInfo      所要更新的用户信息，用户信息的属性中，不包含userId, password, phoneNum等属性。
 *  @param succeed       请求成功回调
 *  @param failed        请求失败回调
 */
+ (void)postUpdateUserInfoWithUserInfo:(NSDictionary *)userInfo succeed:(Succeed)succeed failed:(Failed)failed {
    NSString * url = [HeadURl stringByAppendingString:@"updateUserInfo"];
    
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *param = @{@"userInfo":userInfo, @"loginToken":loginToken};
    
    [RequestManager postRequestWithUrlString:url params:param succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}

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
+ (void)qryUserMessagesWithLastMsgTime:(NSString *)lastMsgTime msgId:(NSString *)msgId Succeed:(Succeed)succeed failed:(Failed)failed {
    
    NSString *urlString = [HeadURl stringByAppendingString:@"qryMessages"];
    
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    
    if (!lastMsgTime) {
        lastMsgTime = @"";
    }
    
    if (!msgId) {
        msgId = @"";
    }
    
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"loginToken":loginToken, @"lastMsgTime":lastMsgTime, @"msgId":msgId,@"filter":@"receiverOnly"};
    
    [RequestManager getRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];

}

/**
 *  更新消息属性
 *
 *  @param msgId   id
 *  @param readed  消息是否已读
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)updateMsgAttrsWithMsgId:(NSString *)msgId readed:(BOOL)readed Succeed:(Succeed)succeed failed:(Failed)failed {
    
    NSString *urlString = [HeadURl stringByAppendingString:@"updateMsgAttrs"];
    
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"loginToken":loginToken, @"msgId":msgId, @"readed":@(readed)};
    
    [RequestManager postRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];

}

/**
 *  删除消息
 *
 *  @param msgIdsArray   id数组
 *  @param succeed 成功返回数据
 *  @param failed  失败返回错误
 */
+ (void)delMsgWithMsgIdsArray:(NSArray *)msgIdsArray Succeed:(Succeed)succeed failed:(Failed)failed {
    
    NSString *urlString = [HeadURl stringByAppendingString:@"delMessages"];
    
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"loginToken":loginToken, @"msgIdList":msgIdsArray};
    
    [RequestManager postRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];

}

//获取摄像头版本信息
+(void)getSystemDataWithSucceed:(Succeed)succeed failed:(Failed)failed
{
    NSString *urlString = [HeadURl stringByAppendingString:@"qryProfile"];
    if (![SettingConfig shareInstance].loginToken) {
        return;
    }
    NSString *loginToken = [[SettingConfig shareInstance].loginToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{@"loginToken":loginToken};
    
    [RequestManager getRequestWithUrlString:urlString params:params succeed:^(id responseObject) {
        succeed(responseObject);
    } andFailed:^(NSError *error) {
        failed(error);
    }];
}


//批量下载
+ (NSMutableArray *)downloadFileWithURL:(NSArray *)url_array destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableArray *all_task = [[NSMutableArray alloc] initWithCapacity:url_array.count];
    __block NSInteger finish_download_tag = 0;
    for (NSDictionary *dic in url_array) {
        NSString *url_str = VALUEFORKEY(dic, @"fileName");
        url_str = [NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url, url_str];
        NSURL *URL = [NSURL URLWithString:url_str];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSProgress *progress = [[NSProgress alloc] init];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:destination completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            finish_download_tag++;
            if (finish_download_tag == url_array.count) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadShowResource" object:nil];
                
            }
        }];
        [downloadTask resume];
        [all_task addObject:progress];
    }
    return all_task;
    
}

+(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                    progress:(Progress )progress
                                     succeed:(Succeed)succeed
                                    andFailed:(Failed)failed{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURL *urlpath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlpath];
    
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [fileURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (error) {
            failed(error);
        }else{
            
            succeed(response);
        }
    }];
    
    [downloadtask resume];
    return downloadtask;
}

+(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                    progress:(Progress )progress
                                     succeed:(Succeed)succeed
                                   andFailed:(Failed)failed cancle:(Cancle)cancle
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURL *urlpath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlpath];
    
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [fileURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (error) {
            failed(error);
        }else{
            
            succeed(response);
        }
    }];
    if (cancle) {
        cancle();
    }
    [downloadtask resume];
    return downloadtask;
}

+(void)uploadWithURL:(NSString *)url params:(NSDictionary *)params fileData:(NSData *)filedata name:(NSString *)name fileName:(NSString *)filename mimeType:(NSString *) mimeType progress:(Progress)progress success:(Succeed)success fail:(Failed)fail{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:filedata name:name fileName:filename mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}









@end
