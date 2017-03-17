//
//  AlbumsPathModel.m
//  KaKa
//
//  Created by Change_pan on 16/8/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsPathModel.h"

@implementation AlbumsPathModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    MMLog(@"%@类这个字段没有定义%@",[NSString stringWithUTF8String:object_getClassName(self)],key);
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
}
@end
