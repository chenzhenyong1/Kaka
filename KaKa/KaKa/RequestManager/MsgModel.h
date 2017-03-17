//
//  MsgModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/4.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HEADFLAG @"EYEC"
#define VERSIONFLAG @"0100"
#define MSGSN @"0001"

@interface MsgModel : NSObject

/// 协议头标识，“EYEC”标识客户端，“EYES”标识服务端 4个字节
@property (nonatomic, copy) NSString *headFlag;

/// 命令ID 1个字节
@property (nonatomic, copy) NSString *cmdId;

/// 消息号 2个字节
@property (nonatomic, copy) NSString *msgSN;

/// 协议版本号标识，长度为两字节，0x01 0x00表示协议版本号是V1.0，依次类推
@property (nonatomic, copy) NSString *versionFlag;

/// 令牌，设备用以识别合法APP的标识 32字节
@property (nonatomic, copy) NSString *token;

/// 数据体长度，MsgBody的字节数 2字节
@property (nonatomic, assign) NSInteger msgLenth;

/// 数据体，命令内容或返回值，字节数可以为0 MAX=200
@property (nonatomic, copy) NSString *msgBody;

/// 从消息头开始，直到校验码前一个字节的CRC16-CCITT 校验码 2字节
@property (nonatomic, copy) NSString *verifyCode;

@end
