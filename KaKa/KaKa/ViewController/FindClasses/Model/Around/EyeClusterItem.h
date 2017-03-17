//
//  EyeClusterItem.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//
/**
 * 表示一个标注
 */
#import "BMKClusterItem.h"

@class EyeSubjectsModel;
@interface EyeClusterItem : BMKClusterItem

/** 标注的Model */
@property (nonatomic, strong) EyeSubjectsModel *model;

@end
