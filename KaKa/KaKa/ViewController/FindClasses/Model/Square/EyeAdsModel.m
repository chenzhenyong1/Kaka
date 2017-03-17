//
//  EyeAdsModel.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/29.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAdsModel.h"
#import "MJExtension.h"

@implementation EyeAdsModel

MJExtensionCodingImplementation

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"ID" : @"id",
             @"desc" : @"description"
             };
}

@end
