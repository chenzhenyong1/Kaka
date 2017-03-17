//
//  ColumnOverview.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "ColumnOverview.h"
#import "MJExtension.h"

@implementation ColumnOverview

MJExtensionCodingImplementation

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"imgViews" : @"ImgView",
             };
    
}

@end
