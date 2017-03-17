//
//  EyeMediaAccessModel.h
//  KakaFind
//
//  Created by 陈振勇 on 16/9/1.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EyeMediaAccessModel : NSObject
/** 媒体访问URL */
@property (nonatomic, copy) NSString *url;
/** 播放、查看媒体时是否静音 */
@property (nonatomic, copy) NSString *mute;
/** 媒体的配音，为APP端本地预置音乐文件名 */
@property (nonatomic, copy) NSString *backgroundMusic;
/** bucket名称 */
@property (nonatomic, copy) NSString *bucket;
/** bucket的end point。当access为download时返回此属性 */
@property (nonatomic, copy) NSString *endPoint;
/** 是否使用CNAME记录 */
@property (nonatomic, copy) NSString *cName;
/** 临时访问令牌。当access为download时返回此属性。如果bucket为公共访问，则此属性为空。 */
@property (nonatomic, copy) NSString *securityToken;
/** 临时访问Key ID。当access为download时返回此属性。如果bucket为公共访问，则此属性为空。 */
@property (nonatomic, copy) NSString *tempKeyId;
/** 临时访问Key密码。当access为download时返回此属性。如果bucket为公共访问，则此属性为空。 */
@property (nonatomic, copy) NSString *tempKeySecret;
/** 临时访问用户名。当access为push时返回此属性。 */
@property (nonatomic, copy) NSString *userName;
/** 临时访问密码。当access为push时返回此属性。 */
@property (nonatomic, copy) NSString *password;
/** Key过期时间，epoch时间。如果bucket为公共访问，则此属性为0。 */
@property (nonatomic, copy) NSString *keyExpiration;

@end
