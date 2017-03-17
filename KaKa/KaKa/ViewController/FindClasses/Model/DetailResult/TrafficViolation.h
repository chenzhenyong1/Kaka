//
//  TrafficViolation.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrafficViolation : NSObject

/** 话题ID */
@property (nonatomic, copy) NSString *subjectId;
/** 违章时间, epoch时间 */
@property (nonatomic, copy) NSString *violateTime;
/** 违章地点 */
@property (nonatomic, copy) NSString *violateLocation;
/** 车辆类型，为以下常量之一：
 代码	意义
 1	大车
 2	小车

 */
@property (nonatomic, copy) NSString *vehType;
/** 违章行为代码，此代码为系统枚举 */
@property (nonatomic, copy) NSString *violateTypeCode;
/** 联系人姓名 */
@property (nonatomic, copy) NSString *contact;
/** 联系电话 */
@property (nonatomic, copy) NSString *contactPhoneNum;
/** 系统受理时间，epoch时间 */
@property (nonatomic, copy) NSString *acceptTime;
/** 向交通管理部门申报时间，epoch时间 */
@property (nonatomic, copy) NSString *submitTime;
/** 违章举报处理状态，为下列常量之一：
 代码	意义
 1	暂未受理
 2	系统已受理
 3	交通管理部门处理中
 4	交通管理部门通过
 5	交通管理部门驳回
 */
@property (nonatomic, copy) NSString *processState;
/** 车牌号 */
@property (nonatomic, copy) NSString *plate;
@end
