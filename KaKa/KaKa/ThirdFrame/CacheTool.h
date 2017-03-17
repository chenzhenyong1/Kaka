//
//  CacheTool.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/23.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CameraListModel.h"
#import "AlbumsTravelModel.h"
#import "AlbumsTravelDetailModel.h"
#import "CameraTime_lineModel.h"

@interface CacheTool : NSObject

/**
 *  查询摄像机列表
 *
 *  @return 查询到的摄像机数据
 */
+ (NSMutableArray *)queryCameraList;

/**
 *  根据mac地址查询摄像机
 *
 *  @param macAddress 要查询的摄像机
 *
 *  @return 查询到的摄像机
 */
+ (CameraListModel *)queryCameraWithMacAddress:(NSString *)macAddress;

/**
 *  更新摄像机列表
 *
 *  @param model 更新的摄像机
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateCameraListWithCameraListModel:(CameraListModel *)model;


#pragma mark - 游记
/**
 *  根据用户名查询游记
 *
 *  @param userName 用户名
 *
 *  @return @return 查询到的AlbumsTravelModel数据
 */
+ (NSMutableArray *)queryTravelsWithUserName:(NSString *)userName;
/**
 *  根据travelId查询游记
 *
 *  @param userName 用户名
 *
 *  @return @return 查询到的AlbumsTravelModel数据
 */
+ (AlbumsTravelModel *)queryTravelsWithTravelId:(NSString *)travelId;

/**
 *  根据摄像机mac地址、用户名查找正在进行中的游记，即只有开始，没有结束的游记
 *
 *  @param cameraMac 要查找的mac地址
 *  @param userName  要查找的用户
 *
 *  @return 游记数据
 */
+ (NSMutableArray *)queryTravelsUncompleteWithCameraMac:(NSString *)cameraMac userName:(NSString *)userName;

/**
 *  更新游记
 *
 *  @param model 更新的游记数据
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateTravelWithTravelModel:(AlbumsTravelModel *)travelModel;

/**
 *  根据游记Id删除游记
 *
 *  @param travelId 要删除的游记id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteTravelWithTravelId:(NSInteger)travelId;

/**
 *  根据游记Id删除空游记
 *
 *  @param travelId 要删除的游记id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteEmptyTravelWithTravelId:(NSInteger)travelId;

// 游记详情
/**
 *  根据游记Id查询游记详情
 *
 *  @param travelId 要查找的游记id
 *
 *  @return 游记详情数据
 */
+ (NSMutableArray *)queryTravelDetailWithTravelId:(NSInteger)travelId;

/** 查询某一条数据是否存在 */
+ (BOOL)isExistTravelDetailWithTime:(NSString *)time travelId:(NSInteger)travelId;

/**
 *  更新游记详情
 *
 *  @param detail 要更新的游记详情
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateTravelDetailWithDetailModel:(AlbumsTravelDetailModel *)detail;

/**
 *  删除游记详情
 *
 *  @param detailId 要删除的游记详情id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteTravelDetailWithDetailId:(NSInteger)detailId;

#pragma mark - 时间线

/**
 *  根据时间和用户、mac地址查找时间线数据
 *
 *  @param date      日期
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListWithDate:(NSString *)date camereMac:(NSString *)camereMac userId:(NSString *)userId;

/**
 *  根据mac地址、用户查找time之后的时间线数据
 *
 *  @param time      时间
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListAfterTime:(NSString *)time camereMac:(NSString *)camereMac userId:(NSString *)userId;

/**
 *  根据mac地址、用户查找一个时间段内的时间线数据
 *
 *  @param fromTime  开始时间
 *  @param toTime    结束时间
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListFromTime:(NSString *)fromTime toTime:(NSString *)toTime camereMac:(NSString *)camereMac userId:(NSString *)userId;

/**
 *  根据时间和用户、mac地址查找用户的上次停车数据
 *
 *  @param date      日期
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (CameraTime_lineModel *)queryCameraTime_lineLastStopBeforeDate:(NSString *)beforeDate camereMac:(NSString *)camereMac userId:(NSString *)userId;

/**
 *  根据mac地址查找摄像机最后一次开机时间数据
 *  @param camereMac mac地址
 *  @return 查找到的yyyyMMddHHmmss数据
 */
+ (NSString *)queryCameraTime_lineLastStartCdrTimeWithCamereMac:(NSString *)camereMac;

/**
 *  插入时间线
 *
 *  @param model 要插入的时间线数据
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)insertimeLineWithCameraTime_lineModel:(CameraTime_lineModel *)model;
/**
 *  查找最后一次入库的时间
 *
 *  @param userId    用户
 *  @param camereMac mac地址
 *
 *  @return 查找到的时间
 */
+ (NSString *)dateLastUpdateToCameraTimeLineWithUserId:(NSString *)userId camereMac:(NSString *)camereMac;

@end
