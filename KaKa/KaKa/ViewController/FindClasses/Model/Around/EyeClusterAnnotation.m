//
//  EyeClusterAnnotation.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeClusterAnnotation.h"

@implementation EyeClusterAnnotation

@synthesize size = _size;

-(NSMutableArray *)itemArr
{
    if (!_itemArr) {
        _itemArr = [NSMutableArray array];
    }
    
    return _itemArr;
}

@end
