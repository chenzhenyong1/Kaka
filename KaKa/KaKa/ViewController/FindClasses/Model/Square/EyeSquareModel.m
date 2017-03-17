//
//  EyeSquareModel.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSquareModel.h"
#import "MJExtension.h"

@implementation EyeSquareModel

MJExtensionCodingImplementation

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"columnOverviews" : @"ColumnOverview"
             };
    
}

@end
