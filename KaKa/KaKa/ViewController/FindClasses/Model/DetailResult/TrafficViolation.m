//
//  TrafficViolation.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章举报信息，只有当话题类型为违章举报时才有此属性。

#import "TrafficViolation.h"

@implementation TrafficViolation


-(NSString *)violateTime
{
    
    NSTimeInterval publish = [_violateTime doubleValue] / 1000;
    
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:(publish)];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setTimeZone:[NSTimeZone localTimeZone]];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    // 帖子的创建时间
    NSString *localeDateStr = [fmt stringFromDate:localeDate];
    NSDate *create = [fmt dateFromString:localeDateStr];
    
    NSTimeZone *sysZone = [NSTimeZone systemTimeZone];
    
    NSInteger interval1 = [sysZone secondsFromGMTForDate: [NSDate date]];
    
//    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];
    
    //    ZYLog(@"create=%@ , nowDate = %@",create,nowDate);
    
    
        
    return [fmt stringFromDate:[create  dateByAddingTimeInterval:-interval1]];
    
    
    
    
}
-(NSString *)getWatermark:(NSString *)str
{
//    NSRange range1 = [str rangeOfString:@"/" options:NSBackwardsSearch];
    
    
//    NSString *subStr = [str substringWithRange:NSMakeRange(range1.location + 1 , 14)];
    
    
    NSMutableString *sub = [str mutableCopy];
    int index = 4;
    [sub insertString:@"-" atIndex:index];
    [sub insertString:@"-" atIndex:index+=3];
    [sub insertString:@" " atIndex:index+=3];
    [sub insertString:@":" atIndex:index+=3];
    [sub insertString:@":" atIndex:index+=3];
    
    return sub;
}
@end
