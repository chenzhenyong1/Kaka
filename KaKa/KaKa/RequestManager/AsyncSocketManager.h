//
//  AsyncSocketManager.h
//  ShengTuRui
//
//  Created by ShowSoft on 16/6/7.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>
#import <CocoaSecurity/CocoaSecurity.h>

#import "MsgModel.h"

#define DefaultUserName     @"EKAKA1"
#define DefaultPWD      @"12345678"

#define REQUEST_TIME_OUT @"TIMEOUT"

enum{
    SocketOfflineByServer, // 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

/**
 *  获取主机返回的数据
 *
 *  @param resultList 已经解析好的数据
 */
typedef void(^ResultMsgBlock)(MsgModel *msg);
typedef void(^ConnectResultBlock)(NSString * connectResult);

typedef void(^AgainConnectResultBlock)(NSString * againConnectResult);

@interface AsyncSocketManager : NSObject <AsyncSocketDelegate>

@property(nonatomic,strong)AsyncSocket * asyncSocket;
@property(nonatomic,copy)NSString * socketName;
@property(nonatomic,copy)NSString * hostMac;

@property(nonatomic,copy)NSString * host;
@property(nonatomic,assign)UInt16   port;

@property (nonatomic, retain) NSTimer        *connectTimer; // 心跳机制计时器

@property(nonatomic,strong)ResultMsgBlock resultMsgBlock;
@property(nonatomic,strong)ConnectResultBlock connectResultBlock;
@property(nonatomic,strong)AgainConnectResultBlock againConnectResultBlock;

+(AsyncSocketManager *)sharedAsyncSocketManager;

+(AsyncSocketManager *)initWithName:(NSString *)socketName HostMac:(NSString *)mac;

//连接
-(void)connectToHost:(NSString *)host onPort:(UInt16)port connectResult:(void (^)(NSString * connectResult))connectResult;
//重连
- (void)againConnectToHost:(NSString *)host onPort:(UInt16)port againConnectResult:(void (^)(NSString * againConnectResultBlock))againConnectResult;

//断开连接
-(void)disconnectSocket;

//发送消息
-(void)sendData:(MsgModel *)msg receiveData:(void (^)(MsgModel *msg))resultMsg;

// 移除心跳定时器
- (void)destroyConnectTimer;

@end
