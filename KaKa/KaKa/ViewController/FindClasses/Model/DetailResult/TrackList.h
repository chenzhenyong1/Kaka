//
//  TrackList.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackList : NSObject

/** 话题ID */
@property (nonatomic, copy) NSString *subjectId;
/** 轨迹序号 */
@property (nonatomic, copy) NSString *seqNum;
/** 轨迹点经度 */
@property (nonatomic, copy) NSString *lon;
/** 轨迹点纬度 */
@property (nonatomic, copy) NSString *lat;
/** GPS时间，epoch时间 */
@property (nonatomic, copy) NSString *gpsTime;
/**轨迹的系统接收时间，epoch时间 */
@property (nonatomic, copy) NSString *sysTime;
/** 时速 */
@property (nonatomic, copy) NSString *spd;
/** 方向 */
@property (nonatomic, copy) NSString *head;
/** 轨迹点的添加时间，epoch时间 */
@property (nonatomic, copy) NSString *addedTime;


@end
