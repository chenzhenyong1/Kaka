//
//  AsyncSocketManager.m
//  ShengTuRui
//
//  Created by ShowSoft on 16/6/7.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "AsyncSocketManager.h"
#import "MsgModel.h"
#define TIME_OUT 60

@interface AsyncSocketManager ()

// 是否正在连接
@property(nonatomic,assign)BOOL isConnectting;
// block数组
@property (nonatomic, strong) NSMutableDictionary *blockDic;
// 命令Id
@property (nonatomic, assign) NSInteger cmdIndex;

@end


@implementation AsyncSocketManager
{
    //发送数据超时定时器
    NSTimer *_sendDataTimer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(AsyncSocketManager *)sharedAsyncSocketManager {
    
    static AsyncSocketManager * sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[AsyncSocketManager alloc] init];
    });
    
    return sharedInstace;
}

+(AsyncSocketManager *)initWithName:(NSString *)socketName HostMac:(NSString *)mac {
    
    AsyncSocketManager * manager = [[AsyncSocketManager alloc]init];
    manager.socketName = socketName;
    manager.hostMac = mac;
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.asyncSocket = [[AsyncSocket alloc]initWithDelegate:self];
        self.blockDic = [NSMutableDictionary dictionary];
        self.cmdIndex = 1;
        
        // 进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    }
    return self;
}

- (void)onApplicationDidBecomeActiveHandle {
    // 进入前台 重新启动心跳
    if (self.connectTimer) {
        [self.connectTimer fire];
    }
}
// 连接socket
- (void)connectToHost:(NSString *)host onPort:(UInt16)port connectResult:(void (^)(NSString * connectResult))connectResult{
    
    if (self.asyncSocket.isConnected) {
        [self.asyncSocket disconnect];
    }
    self.host = host;
    self.port = port;
    
    if (!self.asyncSocket) {
        self.asyncSocket = [[AsyncSocket alloc]initWithDelegate:self];
    }
    
    self.isConnectting = YES;
    
    NSError * error = nil;
    BOOL result = [self.asyncSocket connectToHost:host onPort:port withTimeout:3 error:&error];
    if (!result) {
        MMLog(@"连接出错了00----%@",error);
    }
    
    self.connectResultBlock = connectResult;
}


- (void)againConnectToHost:(NSString *)host onPort:(UInt16)port againConnectResult:(void (^)(NSString * againConnectResultBlock))againConnectResult {

    if (self.asyncSocket.isConnected) {
        return;
    }
    self.host = host;
    self.port = port;
    
    if (!self.asyncSocket) {
        self.asyncSocket = [[AsyncSocket alloc]initWithDelegate:self];
    }
    
    self.isConnectting = YES;
    
    NSError * error = nil;
    BOOL result = [self.asyncSocket connectToHost:host onPort:port withTimeout:3 error:&error];
    if (!result) {
        MMLog(@"连接出错了00----%@",error);
    }
    
    self.againConnectResultBlock = againConnectResult;
}

-(void)disconnectSocket{
    
    [self destroyConnectTimer];
    
    if ([self.asyncSocket isConnected]) {
        [self.asyncSocket disconnect];
    }
    self.asyncSocket.delegate = nil;
    self.asyncSocket = nil;
}

- (void)destroyConnectTimer {
    
    if ([self.connectTimer isValid]) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
}

#pragma mark --方法

/**
 *  发送消息
 */
-(void)sendData:(MsgModel *)msg receiveData:(void (^)(MsgModel *msg))resultMsg {
    
    if ([self.asyncSocket isConnected]) {
        
        if (_sendDataTimer) {
            [_sendDataTimer invalidate];
            _sendDataTimer = nil;
        }
        
        self.resultMsgBlock = [resultMsg copy];
        
        msg.msgSN = [NSString stringWithFormat:@"%04lx", (long)self.cmdIndex];
        self.cmdIndex++;
        if (self.cmdIndex > 65535) {
            self.cmdIndex = 0;
        }
        // 把block存到数组中
        [self.blockDic setObject:[resultMsg copy] forKey:[msg.cmdId lowercaseString]];
        
        NSData * data = [self buildMessageDataWithModel:msg];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            [self.asyncSocket writeData:data withTimeout:-1 tag:0];
//        });
        
        _sendDataTimer = [NSTimer scheduledTimerWithTimeInterval:40.0f target:self selector:@selector(sendData_time_out) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_sendDataTimer forMode:NSRunLoopCommonModes];
        
    } else {
        
        if (self.isConnectting) {
            return;
        }
        //重连
        
        [self againConnectToHost:self.host onPort:self.port againConnectResult:^(NSString *againConnectResultBlock) {
            
        }];
        
        
    }
    
}

//超时返回数据
-(void)sendData_time_out
{
    [_sendDataTimer invalidate];
    _sendDataTimer = nil;
    MsgModel *msg = [[MsgModel alloc] init];
    msg.msgBody = @"time_out";
    if (_resultMsgBlock)
    {
        self.resultMsgBlock(msg);
    }
}

#pragma mark --AsyncSocket delegate
//建立连接
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    MMLog(@"onScoket:%p 已经和主机：%@ 端口：%d 建立连接",sock,host,port);
    
    self.isConnectting = NO;
    if (self.connectResultBlock) {
        self.connectResultBlock(@"OK");
        self.connectResultBlock = nil;
    }
    [NotificationCenter postNotificationName:@"SocketConnectStateNotif" object:@(1)];
}

- (MsgModel *)analyzeData:(NSData *)data Host:(NSString *)host Port:(UInt16)port {
    
    MMLog(@"===========开始解析============");
    //转十六进制字符串
    NSString * readStr = [self dataToHexString:data];
    
    // 0~8位 headFlag
    if (readStr.length < 8) {
        //头长度不对
        return nil;
    }
    
    MsgModel *msgModel = [[MsgModel alloc] init];
    msgModel.headFlag = [self hexStrToString:[readStr substringToIndex:8]];
    
    if ([msgModel.headFlag isEqualToString:HEADFLAG]) {
        // 如果是主机发送的数据
        return nil;
    }
    
    if (readStr.length >= 10) {
        msgModel.cmdId = [readStr substringWithRange:NSMakeRange(8, 2)];
    }
    
    if (readStr.length >= 14) {
        msgModel.msgSN = [readStr substringWithRange:NSMakeRange(10, 4)];
    }
    
    if (readStr.length >= 18) {
        msgModel.versionFlag = [readStr substringWithRange:NSMakeRange(14, 4)];
    }
    
    if (readStr.length >= 82) {
        msgModel.token = [readStr substringWithRange:NSMakeRange(18, 64)];
    }
    
    if (readStr.length >= 86) {
        // 消息长度
        msgModel.msgLenth = 2 * [self hexStringToDecimal:[readStr substringWithRange:NSMakeRange(82, 4)]];
    }
    
    if (readStr.length >= 86 + msgModel.msgLenth) {
        // 消息体
        msgModel.msgBody = [self hexStrToString:[readStr substringWithRange:NSMakeRange(86, msgModel.msgLenth)]];
    }
    
    // 待验证的crc16验证码
    NSString *needCheckCRC16CodeStr = [readStr substringFromIndex:readStr.length - 4];
    
    unsigned short needCheckCRC16Code = [self hexStringToDecimal:needCheckCRC16CodeStr];
    
    // 计算crc16验证码
    Byte *bytes = (Byte *)[data bytes];
    unsigned short CRC16Code = [self get_crc16:bytes length:data.length-2];
    
    if (CRC16Code != needCheckCRC16Code) {
        // 校验码对不上
        return nil;
    }
    return msgModel;
}



//读取数据
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    MMLog(@"接收到的数据--------%@",data);
    
    [sock readDataWithTimeout:-1 tag:0];
    
    MsgModel *model = [self analyzeData:data Host:nil Port:0];
    if ([model.cmdId isEqualToString:@"07"])
    {
        if ([model.msgBody containsString:@"_"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dowload_Video" object:model];
        }
        
    }
    
    _resultMsgBlock = [self.blockDic objectForKey:[model.cmdId lowercaseString]];
    if (_resultMsgBlock) {
        [_sendDataTimer invalidate];
        _sendDataTimer = nil;
        _resultMsgBlock(model);
        // 移除数组中的block
        [self.blockDic removeObjectForKey:[model.cmdId lowercaseString]];
    }
    
    if ([model.cmdId isEqualToString:@"01"]) {
        // 登录成功token
        [SettingConfig shareInstance].deviceLoginToken = model.token;
        // 心跳
        if (!self.connectTimer) {
            self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
            [self.connectTimer fire];
        }
        
    } else if([model.cmdId isEqualToString:@"02"]) {
        // 心跳
        MMLog(@"heard jump %@", model.msgBody);
    } 
    
}

//数据写入完成调用
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    MMLog(@"数据发送完成");
    [sock readDataWithTimeout:-1 tag:0];

}

//遇到错误时关闭连接
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    MMLog(@"遇到错误时关闭连接onSocket:%p will disconnect with error:%@",sock,err.localizedDescription);
}

//断开连接
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    MMLog(@"断开连接:%p",sock);
    if (sock.userData == SocketOfflineByUser) {
        // 用户主动cut
    } else {
        self.isConnectting = NO;
        if (self.connectResultBlock) {
            self.connectResultBlock(REQUEST_TIME_OUT);
            self.connectResultBlock = nil;
        }
        
        if ([SettingConfig shareInstance].deviceLoginToken) {
            [SettingConfig shareInstance].deviceLoginToken = nil;
            // 之前登录成功过 重连
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self againConnectToHost:self.host onPort:12330 againConnectResult:nil];
            });
            
            [NotificationCenter postNotificationName:@"SocketConnectStateNotif" object:@(0)];
            
        }
        
    }

}

// 心跳
- (void)longConnectToSocket {
    
    MsgModel * msg = [[MsgModel alloc]init];
    msg.cmdId = @"02";
    msg.msgSN = @"0001";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgLenth = msg.msgBody.length;
    
    NSData * data = [self buildMessageDataWithModel:msg];
    [self.asyncSocket writeData:data withTimeout:-1 tag:0];
}


#pragma mark --
/**
 *  构造消息
 *
 *  @param msgModel 消息模型
 *
 *  @return 消息数据
 */
-(NSData * )buildMessageDataWithModel:(MsgModel *)msg {
    
    // 协议头标识
    NSString *hexHeadFlag = [self stringToHexStr:msg.headFlag];
    
    NSString *str = [self stringToHexStr:msg.msgBody];
    NSString *hexMsgLength = [NSString stringWithFormat:@"%04lx", (long)(str.length/2)];
    
    // 协议头标识 + 命令ID + 消息号 + 协议版本号标识 + 令牌 + 数据体长度 + 数据体 + 从消息头开始，直到校验码前一个字节的CRC16-CCITT 校验码
    NSString *crc16DataHex = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", hexHeadFlag, msg.cmdId, msg.msgSN, msg.versionFlag, msg.token, hexMsgLength,str];
    NSData *crc16Data = [self hexStringToByte:crc16DataHex];
    Byte *crc16Byte = (Byte *)[crc16Data bytes];
    //获取校验码
    unsigned short CRC16Code = [self get_crc16:crc16Byte length:(int)crc16Data.length];
    
    NSString *CRC16CodeStr = [self convertDecimalToHexStr:CRC16Code];
    
    // 转换成小写字母
    CRC16CodeStr = [CRC16CodeStr lowercaseString];
    
    
    NSString * completeDataHex = [NSString stringWithFormat:@"%@%@", crc16DataHex, CRC16CodeStr];
    //转data
    NSData * sendData = [self hexStringToByte:completeDataHex];
    MMLog(@"发送的明文数据---------%@",sendData);
    return sendData;
}

#pragma mark --转换方法
/**
 *  十六进制字符串转十进制数字
 */
- (unsigned long long)hexStringToDecimal:(NSString *)str {
    
    unsigned long long len = 0;
    NSScanner * scan = [NSScanner scannerWithString:str];
    [scan scanHexLongLong:&len];
    return len;
}

/**
 *  十六进制字符串转普通字符串
 */
- (NSString *)hexStrToString:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    NSString *string = [[NSString alloc]initWithData:hexData encoding:NSUTF8StringEncoding];
    return string;
}



/**
 *  普通字符串转换为十六进制
 */
- (NSString *)stringToHexStr:(NSString *)string{
    
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
        
    }
    return hexStr;
}

/**
 *  二进制数组转十六进制字符串
 */
- (NSString *)dataToHexString:(NSData *)data {
    NSUInteger  len = [data length];
    char *  chars = (char *)[data bytes];
    NSMutableString * hexString = [[NSMutableString alloc] init];
    
    for (NSUInteger i = 0; i < len; i++ ) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    
    return hexString;
}

/**
 *  十六进制字符串转字节数组
 */
-(NSData *)hexStringToByte:(NSString *)hexString {
    
    int len = (int)[hexString length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [hexString length] / 2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

/**
 *  获取CRC8校验码
 */
- (unsigned char)getCRC8:(UInt32)counter pointer:(UInt8 *)p{
    UInt8 crc8 = 0;
    
    UInt8 crc_array[256] = {
        0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15, 0x38, 0x3F,
        0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D, 0x70, 0x77, 0x7E, 0x79,
        0x6C, 0x6B, 0x62, 0x65, 0x48, 0x4F, 0x46, 0x41, 0x54, 0x53,
        0x5A, 0x5D, 0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
        0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD, 0x90, 0x97,
        0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85, 0xA8, 0xAF, 0xA6, 0xA1,
        0xB4, 0xB3, 0xBA, 0xBD, 0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC,
        0xD5, 0xD2, 0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
        0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2, 0x8F, 0x88,
        0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A, 0x27, 0x20, 0x29, 0x2E,
        0x3B, 0x3C, 0x35, 0x32, 0x1F, 0x18, 0x11, 0x16, 0x03, 0x04,
        0x0D, 0x0A, 0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
        0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A, 0x89, 0x8E,
        0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C, 0xB1, 0xB6, 0xBF, 0xB8,
        0xAD, 0xAA, 0xA3, 0xA4, 0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2,
        0xEB, 0xEC, 0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
        0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C, 0x51, 0x56,
        0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44, 0x19, 0x1E, 0x17, 0x10,
        0x05, 0x02, 0x0B, 0x0C, 0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A,
        0x33, 0x34, 0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
        0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63, 0x3E, 0x39,
        0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B, 0x06, 0x01, 0x08, 0x0F,
        0x1A, 0x1D, 0x14, 0x13, 0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5,
        0xBC, 0xBB, 0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
        0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB, 0xE6, 0xE1,
        0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3 };
    
    for (; counter > 0; counter--)
    {
        crc8 = crc_array[crc8^*p]; //查表得到CRC码
        p++;
    }
    return crc8;
}


/**
 将十进制整型转换成十六进制的字符串

 @param decimal 十进制整型
 @return 十六进制字符串
 */
- (NSString *)convertDecimalToHexStr:(unsigned short)decimal {
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=decimal%16;
        decimal=decimal/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (decimal == 0) {
            break;
        }
        
    }
    //当字符串少于4位时,要用补上,防止校验错误
    if (str.length != 4) {
        int zeroNum = 4 - (int)str.length;
        while (zeroNum != 0) {
            str = [NSString stringWithFormat:@"0%@",str];
            zeroNum --;
        }
    }
    
    return str;
}


/**
 获取crc16校验码

 @param buffer Byte数组
 @param len 长度
 @return short型校验码
 */
-(unsigned short)get_crc16:(unsigned char*)buffer length:(int)len {
    unsigned short crc = 0x00;
    unsigned short current = 0x00;
    int i = 0,j;
    unsigned char ch = 0x00;
    for(i=0;i<len;i++)
    {
        ch = buffer[i];
        current = (ch&0x000000FF) << 8;
        for(j=0;j<8;j++)
        {
            if((crc ^ current)&0x8000){
                crc = (crc << 1) ^ 0x1021;
            }else{
                crc <<=1;
            }
            crc &=0x0000FFFF;
            current <<=1;
        }
    }
    return crc;
}


@end
