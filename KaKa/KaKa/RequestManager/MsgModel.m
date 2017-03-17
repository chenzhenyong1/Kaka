//
//  MsgModel.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/4.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MsgModel.h"

@implementation MsgModel

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _headFlag = HEADFLAG;
        _versionFlag = VERSIONFLAG;
        _msgSN = MSGSN;
    }
    
    return self;
}

@end
