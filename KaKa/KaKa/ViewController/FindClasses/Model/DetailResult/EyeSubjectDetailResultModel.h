//
//  EyeSubjectDetailResultModel.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Subject;
@class TrafficViolation;
@interface EyeSubjectDetailResultModel : NSObject

/** 话题对象 */
@property (nonatomic, strong) Subject *subject;
/** 话题轨迹列表 */
@property (nonatomic, strong) NSArray *trackList;
/** 话题媒体列表 */
@property (nonatomic, strong) NSArray *mediaList;
/** 话题交互列表 */
@property (nonatomic, strong) NSArray *interactList;
/** 违章举报信息，只有当话题类型为违章举报时才有此属性。 */
@property (nonatomic, strong) TrafficViolation *trafficViolation;

@end
