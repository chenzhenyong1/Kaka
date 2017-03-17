//
//  PRGAnnotation.m
//  YunAnJia
//
//  Created by Change_pan on 16/3/9.
//  Copyright © 2016年 com.showsoft. All rights reserved.
//

#import "PRGAnnotation.h"

@implementation PRGAnnotation

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    MMLog(@"%@类这个字段没有定义%@",[NSString stringWithUTF8String:object_getClassName(self)],key);
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
}

@end
