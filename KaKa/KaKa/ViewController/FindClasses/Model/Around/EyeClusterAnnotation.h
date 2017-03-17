//
//  EyeClusterAnnotation.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

/*
 *  点聚合Annotation
 */

@interface EyeClusterAnnotation : BMKPointAnnotation
/**
 *  所包含annotation个数
 */
@property (nonatomic, assign) NSInteger size;
//  该点的标注图片URL
@property (nonatomic, copy) NSString *imgUrl;

/** 标注的Model数组 */
@property (nonatomic, strong) NSMutableArray *itemArr;

@end
