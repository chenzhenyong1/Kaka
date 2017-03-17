//
//  ItemList.h
//  媒体测试
//
//  Created by 陈振勇 on 16/8/4.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemList : NSObject

/** bucket */
@property (nonatomic, copy) NSString *bucket;
/** registerTime */
@property (nonatomic, copy) NSString *registerTime;
/** id */
@property (nonatomic, copy) NSString *ID;
/** endPoint */
@property (nonatomic, copy) NSString *endPoint;
/** storePath */
@property (nonatomic, copy) NSString *storePath;
/** mediaUrl */
@property (nonatomic, copy) NSString *mediaUrl;
/** reqId */
@property (nonatomic, copy) NSString *reqId;
/** cName */
@property (nonatomic, copy) NSString *cName;
/** 附着在轨迹的序号 */
@property (nonatomic, copy) NSString *attachToTrackSeqNum;



//        bucket = ekaka-t,
//        registerTime = 1470301879064,
//        id = v-ev0GzkZcQNabbPUECfj9_A.mp4,
//        endPoint = oss-cn-shenzhen.aliyuncs.com,
//        storePath = 411/v-ev0GzkZcQNabbPUECfj9_A.mp4,
//        mediaUrl = http://ekaka-t.oss-cn-shenzhen.aliyuncs.com/411/v-ev0GzkZcQNabbPUECfj9_A.mp4,
//        reqId = #1,
//        cName = 0
@end
