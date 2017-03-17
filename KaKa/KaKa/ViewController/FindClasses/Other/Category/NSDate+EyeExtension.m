//
//  NSDate+EyeExtension.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/29.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "NSDate+EyeExtension.h"

@implementation NSDate (EyeExtension)

- (NSDateComponents *)deltaFrom:(NSDate *)from
{
    // 日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 比较时间
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    return [calendar components:unit fromDate:from toDate:self options:0];
}

- (BOOL)isThisYear
{
    NSTimeZone *sysZone = [NSTimeZone systemTimeZone];
    
    NSInteger interval1 = [sysZone secondsFromGMTForDate: [NSDate date]];
    
    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];
    
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    fmt.dateFormat = @"yyyy";
    
    //    NSString *nowString = [fmt stringFromDate:nowDate];
    //    NSString *selfString = [fmt stringFromDate:self];
    //    ZYLog(@"nowDate = %@  self = %@",nowDate,self);
    
    NSDate *locationDate = [fmt dateFromString:[fmt stringFromDate:nowDate]];
    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitYear fromDate:selfDate toDate:locationDate options:0];
//    ZYLog(@"locationDate cmps = %@",cmps);
    
    return cmps.year == 0;
}

- (BOOL)isToday
{
    
    // 日历
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    calendar.timeZone = [NSTimeZone localTimeZone];
//    
//    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
//
//    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
//    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
//
//    return nowCmps.year == selfCmps.year
//    && nowCmps.month == selfCmps.month
//    && nowCmps.day == selfCmps.day;
//
    NSTimeZone *sysZone = [NSTimeZone systemTimeZone];
    
    NSInteger interval1 = [sysZone secondsFromGMTForDate: [NSDate date]];
    
    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];

    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSDate *locationDate = [[fmt dateFromString:[fmt stringFromDate:nowDate]] dateByAddingTimeInterval:-interval1];
    
    NSDate *selfDate = [[fmt dateFromString:[fmt stringFromDate:self]]dateByAddingTimeInterval:-interval1];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:selfDate toDate:locationDate options:0];
//    ZYLog(@"locationDate cmps = %@",cmps);
    
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 0;
   
}

//- (BOOL)isToday
//{
//    
//    NSTimeZone *sysZone = [NSTimeZone systemTimeZone];
//    
//    NSInteger interval1 = [sysZone secondsFromGMTForDate: [NSDate date]];
//    
//    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];
//    
//    
////    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
////    
////    fmt.dateFormat = @"yyyy-MM-dd";
////    
//////    NSString *nowString = [fmt stringFromDate:nowDate];
//////    NSString *selfString = [fmt stringFromDate:self];
//////    ZYLog(@"nowDate = %@  self = %@",nowDate,self);
////    
////    NSDate *locationDate = [fmt dateFromString:[fmt stringFromDate:nowDate]];
////    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
////    NSCalendar *calendar = [NSCalendar currentCalendar];
////    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:selfDate toDate:locationDate options:0];
////    ZYLog(@"locationDate cmps = %@",cmps);
//    
////    return cmps.year == 0
////    && cmps.month == 0
////    && cmps.day == 0;
//    return [nowDate isEqualToDate:self];
//
//}

- (BOOL)isYesterday
{
    // 2014-12-31 23:59:59 -> 2014-12-31
    // 2015-01-01 00:00:01 -> 2015-01-01
    
    NSTimeZone *sysZone = [NSTimeZone systemTimeZone];
    
    NSInteger interval1 = [sysZone secondsFromGMTForDate: [NSDate date]];
    
    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];
    
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    fmt.dateFormat = @"yyyy-MM-dd";
    
    //    NSString *nowString = [fmt stringFromDate:nowDate];
    //    NSString *selfString = [fmt stringFromDate:self];
    //    ZYLog(@"nowDate = %@  self = %@",nowDate,self);
    
    NSDate *locationDate = [fmt dateFromString:[fmt stringFromDate:nowDate]];
    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:selfDate toDate:locationDate options:0];
//    ZYLog(@"locationDate cmps = %@",cmps);
    
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}
@end
