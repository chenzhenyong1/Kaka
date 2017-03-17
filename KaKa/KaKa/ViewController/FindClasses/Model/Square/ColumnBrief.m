//
//  ColumnBrief.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "ColumnBrief.h"
#import "MJExtension.h"

@implementation ColumnBrief

MJExtensionCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"ID" : @"id",
             };
}

@end
