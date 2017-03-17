//
//  AsyncUdpSocketManager.h
//  ShengTuRui
//
//  Created by ShowSoft on 16/6/17.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncUdpSocket.h>
#import <CocoaSecurity/CocoaSecurity.h>
#import "MsgModel.h"
//获取本机IP
#include <ifaddrs.h>
#include <arpa/inet.h>

typedef void(^ResultBlock)(MsgModel * msgModel, NSString * host, UInt16 port);

@interface AsyncUdpSocketManager : NSObject <AsyncUdpSocketDelegate>

@property(nonatomic,strong)AsyncUdpSocket * udpSocket;

@property(nonatomic,strong)ResultBlock resultBlock;
//本地IP
@property(nonatomic,strong)NSString * localIP;

/**
 *  信息内容是否要加入长度,默认为NO
 */
@property(nonatomic,assign)BOOL haveContentLength;

/**
 *  返回数据是否有长度，按照客户给的协议：搜索主机时返回数据是有长度的，添加主机没有
 */
@property(nonatomic,assign)BOOL reveiceDataHaveLength;


/**
 *  查找指定主机的结果，
 */
@property(nonatomic,strong)NSMutableArray * hostResultArray;


+(AsyncUdpSocketManager *)sharedAsyncUdpSocketManager;


-(void)sendBroadcast:(MsgModel *)msg toHost:(NSString *)host port:(UInt16)port receiveData:(void (^)(MsgModel * msgModel, NSString * host, UInt16 port))resultBlock;

-(void)closeUDPSocket;

@end
