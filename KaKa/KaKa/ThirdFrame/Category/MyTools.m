//
//  MyTools.m
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import "MyTools.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>
static CGRect oldframe;
@implementation MyTools

/**
 *  获取当前时间的时间戳（例子：1464326536）
 *
 *  @return 时间戳字符串型
 */
+ (NSString *)getCurrentTimestamp
{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    // 转为字符型
    return timeString;
}

/**
 *  获取当前标准时间（例子：2015-02-03）
 *
 *  @return 标准时间字符串型
 */
+ (NSString *)getCurrentStandarTime
{
    NSDate *  senddate=[NSDate date];

    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];

    [dateformatter setDateFormat:@"yyyy-MM-dd"];

    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

/**
 *  获取当前标准时间（带时分秒）
 *
 *  @return 标准时间字符串型
 */
+ (NSString *)getCurrentStandarTimeWithMinute
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

+ (NSString *)getCurrentStandarTimeWithMinute1
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

/**
 *  获取时间字符串
 *
 *  @param dateFormatter 时间格式类型
 *  @param date          要转换的时间
 *
 *  @return 转换后的时间字符串
 */
+ (NSString *)getDateStringWithDateFormatter:(NSString *)dateFormatter date:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatter];
    
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

/**
 *  时间戳转换为时间的方法
 *
 *  @param timestamp 时间戳
 *
 *  @return 标准时间字符串
 */
+ (NSString *)timestampChangesStandarTime:(NSString *)timestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;

}

+ (NSString *)timestampChangesStandarTimeHaveHoureAndMin:(NSString *)timestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
    
}
+(NSString *)timestampChangesStandarTimeNoMinute:(NSString *)timestam
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestam doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;

}

+(NSString *)timestampChangesStandarTimeMinute:(NSString *)timestam
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestam doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
    
}

/**
 *  时间转换为时间戳的方法
 *
 *  @param time 时间
 *
 *  @return 标准时间字符串
 */
+ (NSString *)timeChangesStandarTimestamp:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:time];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    // 转为字符型
    return timeString;
}
//年月日时分秒转时间戳
+(NSString *)yearToTimestamp:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [formatter dateFromString:time];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    // 转为字符型
    return timeString;
}

+ (NSString *)timeChangesStandarTimestampMinute:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:time];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    // 转为字符型
    return timeString;
}

//当月第一天
+(NSString *)getCurrentTime
{
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit
                               fromDate:now];
    comps.day = 1;
    NSDate *firstDay = [cal dateFromComponents:comps];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    return [df stringFromDate:firstDay];
}



+(NSString *)timeToweek:(NSString *)time{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *formatterDate = [inputFormatter dateFromString:time];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//    [outputFormatter setDateFormat:@"HH:mm 'on' EEEE MMMM d"];
    // For US English, the output is:
    // newDateString 10:30 on Sunday July 11
    [outputFormatter setDateFormat:@"EEEE"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    return newDateString;
}

//点击图片放大
+(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

//缩小
+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

//获取沙盒指定路径数据
+ (NSMutableArray *)getAllDataWithPath:(NSString *)path mac_adr:(NSString *)mac_adr
{
    if (mac_adr.length)
    {
        NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
        NSMutableArray *files = [[NSMutableArray alloc] init];
        for (NSString *fileName in fileNames) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [files addObject:filePath];
        }
        return files;
    }
    else
    {
        NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:User_Path(mac_adr) error:nil];
        NSMutableArray *files = [[NSMutableArray alloc] init];
        for (NSString *fileName in fileNames) {
            
            NSMutableArray *path_arr = [[path componentsSeparatedByString:@"/"] mutableCopy];
            NSMutableArray *temp_path_arr = [path_arr mutableCopy];
            for (int i = 0; temp_path_arr.count; i ++)
            {
                if ([UserName isEqualToString:temp_path_arr[i]])
                {
                    [path_arr insertObject:fileName atIndex:i+1];
                    break;
                }
            }
            NSString *temp_path = [[NSString alloc] init];
            [path_arr removeObjectAtIndex:0];
            for (NSString *str in path_arr)
            {
                temp_path = [temp_path stringByAppendingString:[NSString stringWithFormat:@"/%@",str]];
            }
            
            fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:temp_path error:nil];
            
            for (NSString *fileName in fileNames) {
                NSString *filePath = [temp_path stringByAppendingPathComponent:fileName];
                [files addObject:filePath];
            }
        }
        return files;
    }
   
}

+ (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString*
    outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                             
                                                                             NULL, /* allocator */
                                                                             
                                                                             (__bridge CFStringRef)input,
                                                                             
                                                                             NULL, /* charactersToLeaveUnescaped */
                                                                             
                                                                             (CFStringRef)@"!$&'()*+,-.:;=?@_~%#[]",
                                                                             
                                                                             kCFStringEncodingUTF8);
    
    
    return
    outputStr;
}

//解析获取经纬度
+ (CLLocationCoordinate2D)getLocationWithGPRMC:(NSString *)cprmc
{
//    cprmc = @"$GPRMC,,,,,,,,A*2C";
    NSArray *temp_arr = [cprmc componentsSeparatedByString:@","];
    
    if (temp_arr.count < 6) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    NSString *latitude_str1 = temp_arr[5];
    NSString *longitude_str1 = temp_arr[3];
    
    if (latitude_str1.length == 0 || longitude_str1.length == 0) {//过滤空字符串
        return kCLLocationCoordinate2DInvalid;
    }
    
    NSString *latitude_str2 = [latitude_str1 substringToIndex:2];
    NSString *longitude_str2 = [longitude_str1 substringToIndex:3];
    
    latitude_str1 = [latitude_str1 substringFromIndex:2];
    longitude_str1 = [longitude_str1 substringFromIndex:3];
    
    float latitude = [latitude_str2 intValue] + [latitude_str1 floatValue]/60;
    float longitude = [longitude_str2 intValue] + [longitude_str1 floatValue]/60;
    
    //1.创建经纬度结构体
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    center = BMKCoorDictionaryDecode(BMKConvertBaiduCoorFrom(center,BMK_COORDTYPE_GPS));//转换后的百度坐标
    
    return center;
}


@end
