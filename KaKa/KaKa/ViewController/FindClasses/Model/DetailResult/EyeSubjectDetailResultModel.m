//
//  EyeSubjectDetailResultModel.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSubjectDetailResultModel.h"

@implementation EyeSubjectDetailResultModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"trackList" : @"TrackList",
             @"mediaList" : @"MediaList",
             @"interactList" : @"InteractList"
             
             };
    
}

@end
