//
//  CameraTime_lineModel.h
//  KaKa
//
//  Created by Change_pan on 16/8/12.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraTime_lineModel : NSObject
@property (nonatomic, copy) NSString *userId;//用户id
@property (nonatomic, copy) NSString *cameraMac;//摄像头mac地址
@property (nonatomic, copy) NSString *startMileage;//开始里程
@property (nonatomic, copy) NSString *time;//时间戳
@property (nonatomic, copy) NSString *type;//类型
@property (nonatomic, copy) NSString *media;//文件名
@property (nonatomic, copy) NSString *endMileage;//接收里程
@property (nonatomic, copy) NSString *gps;//经纬度
@property (nonatomic, copy) NSString *tirpMileage;//里程（公里）
@property (nonatomic, copy) NSString *tirpTime;//时长（秒）

@property (nonatomic, copy) NSString *date;//日期

// 停车显示的时候用到
@property (nonatomic, copy) NSString *startTime;// 停车开始时间
@property (nonatomic, copy) NSString *endTime;// 停车结束时间

@end
