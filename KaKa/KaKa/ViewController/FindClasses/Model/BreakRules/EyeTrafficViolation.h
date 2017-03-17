//
//  EyeTrafficViolation.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/16.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章举报参数

#import <Foundation/Foundation.h>

@interface EyeTrafficViolation : NSObject

/** 违章地点 */
@property (nonatomic, copy) NSString *violateLocation;
/** 车辆类型 */
@property (nonatomic, copy) NSString *vehType;
/** 车牌 */
@property (nonatomic, copy) NSString *plate;
/** 违章行为代码 */
@property (nonatomic, copy) NSString *violateTypeCode;
/** 联系人姓名 */
@property (nonatomic, copy) NSString *contact;
/** 联系电话 */
@property (nonatomic, copy) NSString *contactPhoneNum;
/** 违章时间 */
@property (nonatomic, copy) NSString *violateTime;

@end
