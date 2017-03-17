//
//  CameraTravelModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsTravelModel : NSObject
@property (nonatomic, assign) NSInteger travelId;//游记Id
@property (nonatomic, copy) NSString *userId;//用户id，存用户名也行
@property (nonatomic, copy) NSString *startTime;//开始时间
@property (nonatomic, copy) NSString *endTime;//结束时间
@property (nonatomic, copy) NSString *cameraMac;//摄像头mac地址
@property (nonatomic, copy) NSString *endMileage;//结束时里程
@property (nonatomic, copy) NSString *tirpMileage;//总里程
@property (nonatomic, copy) NSString *tirpTime;//结束时与当前时间的差
@property (nonatomic, copy) NSString *startPostion;//开始经纬度
@property (nonatomic, copy) NSString *endPostion;//结束经纬度
@property (nonatomic, copy) NSString *startPostionShow;//经百度转换成的要显示的开始地址
@property (nonatomic, copy) NSString *endPostionShow;//经百度转换成的要显示的结束地址
@property (nonatomic, assign) BOOL deleted;// 是否已删除
@property (nonatomic, copy) NSString *flag;// 0 该游记已经结束，1该游记开始时间要在后面获取，2该游记结束时间要在后面获取

@property (nonatomic, assign) BOOL isStartAndEndSame;// 开始和结束是否在同一天
@property (nonatomic, copy) NSString *timeLength;//游记时间
@end
