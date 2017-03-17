//
//  MessageModel.h
//  MoMo
//
//  Created by 深圳市 秀软科技有限公司 on 16/3/22.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMsgTypeText;         // 简单文本消息，推送到用户端供用户浏览
extern NSString * const kMsgTypeTraceUp;      // 启动跟踪模式后目标第一次上线通知
extern NSString * const kMsgTypeLowPowerUp;   // 目标欠压后首次上报通知
extern NSString * const kMsgTypeEnterRgn;     // 目标进入区域通知
extern NSString * const kMsgTypeLeaveRgn;     // 目标离开区域通知
extern NSString * const kMsgTypeDemolition;   // 目标拆卸提醒
extern NSString * const kMsgTypeShare;        // 系统内分享
extern NSString * const kMsgTypeSys;          // 系统消息

/**
 *  用户消息
 */
@interface MessageModel : NSObject

@property (nonatomic, copy) NSString *msgId; // 消息Id
@property (nonatomic, copy) NSString *type;  // 消息类型
@property (nonatomic, copy) NSString *title;  // 消息标题
@property (nonatomic, copy) NSString *sender;  // 消息发送者手机号
@property (nonatomic, copy) NSString *receiver;  // 消息接收者手机号
@property (nonatomic, copy) NSString *content;  // 消息内容
@property (nonatomic, copy) NSString *sendTime;     // 服务器发送时间
@property (nonatomic, copy) NSString *createTime;   // 创建时间
//@property (nonatomic, copy) NSString *isReaded;     // 是否已读
@property (nonatomic, copy) NSString *readTime;     // 阅读时间

//@property (nonatomic, assign) long sendTime;  // 服务器发送时间
//@property (nonatomic, assign) NSTimeInterval createTime;  // 创建时间
@property (nonatomic, assign) BOOL readed;  // 是否已读
//@property (nonatomic, assign) long readTime;  // 用户读取消息的时间，epoch毫秒数，当消息已读时本属性才会出现

@property (nonatomic, assign) BOOL isOneLine;  // 内容是否显示为一行


@end
