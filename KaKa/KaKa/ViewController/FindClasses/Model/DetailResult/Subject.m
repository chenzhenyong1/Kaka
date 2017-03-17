//
//  Subject.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "Subject.h"

@implementation Subject
{
    CGFloat _cellHeight;
}

-(CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(kScreenWidth - 20 , MAXFLOAT);
        // 计算文字的高度
        CGFloat textH = [self.shortText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
        
        // cell的高度
        _cellHeight = 10 + 45 + 10 +textH + 10;
    }
    return _cellHeight;
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"thumbList" : @"ThumbList",
             };
    
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"ID" : @"id",
             };
}

-(NSString *)publishTime
{
    
    NSTimeInterval publish = [_publishTime doubleValue] / 1000;
    
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
    
    NSDate *nowDate = [[NSDate date]  dateByAddingTimeInterval: interval1];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    //    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    //    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        NSDateComponents *cmps = [nowDate deltaFrom:create];
        
        if (cmps.hour >= 1) { // 时间差距 >= 1小时
            return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
        } else if (cmps.minute >= 1) { // 1小时 > 时间差距 >= 1分钟
            return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
        } else { // 1分钟 > 时间差距
            return @"刚刚";
        }
    }
    else
    {
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        return [fmt stringFromDate:[create  dateByAddingTimeInterval:-interval1]];
    }
    
}
@end
