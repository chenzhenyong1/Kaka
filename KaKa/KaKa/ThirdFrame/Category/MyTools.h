//
//  MyTools.h
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyTools : NSObject


/**
 *  获取当前时间的时间戳（例子：1464326536）
 *
 *  @return 时间戳字符串型
 */
+ (NSString *)getCurrentTimestamp;

/**
 *  获取当前标准时间（例子：2015-02-03）
 *
 *  @return 标准时间字符串型
 */
+ (NSString *)getCurrentStandarTime;

/**
 *  获取当前标准时间（带时分秒）
 *
 *  @return 标准时间字符串型
 */
+ (NSString *)getCurrentStandarTimeWithMinute;
+ (NSString *)getCurrentStandarTimeWithMinute1;

/**
 *  获取时间字符串
 *
 *  @param dateFormatter 时间格式类型
 *  @param date          要转换的时间
 *
 *  @return 转换后的时间字符串
 */
+ (NSString *)getDateStringWithDateFormatter:(NSString *)dateFormatter date:(NSDate *)date;

/**
 *  时间戳转换为时间的方法
 *
 *  @param timestamp 时间戳
 *
 *  @return 标准时间字符串
 */
+ (NSString *)timestampChangesStandarTime:(NSString *)timestam;

+ (NSString *)timestampChangesStandarTimeHaveHoureAndMin:(NSString *)timestamp;

+(NSString *)timestampChangesStandarTimeMinute:(NSString *)timestam;


/**
 *  时间转换为时间戳的方法
 *
 *  @param time 时间
 *
 *  @return 标准时间字符串
 */
+ (NSString *)timeChangesStandarTimestamp:(NSString *)time;

+ (NSString*)timestampChangesStandarTimeNoMinute:(NSString *)timestam;


+ (NSString *)timeChangesStandarTimestampMinute:(NSString *)time;

 //时间转换星期
+(NSString *)timeToweek:(NSString *)time;

//年月日时分秒转时间戳
+(NSString *)yearToTimestamp:(NSString *)time;

//当月第一天
+(NSString *)getCurrentTime;

//点击图片放大
+(void)showImage:(UIImageView*)avatarImageView;

//获取沙盒指定路径数据
+ (NSMutableArray *)getAllDataWithPath:(NSString *)path mac_adr:(NSString *)mac_adr;

//对+号进行编码
+ (NSString *)encodeToPercentEscapeString: (NSString *) input;

//解析获取经纬度
+ (CLLocationCoordinate2D)getLocationWithGPRMC:(NSString *)cprmc;

@end
