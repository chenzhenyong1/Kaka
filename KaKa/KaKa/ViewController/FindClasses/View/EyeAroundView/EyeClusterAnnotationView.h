//
//  EyeClusterAnnotationView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//
/*
 *  点聚合AnnotationView
 */


@interface EyeClusterAnnotationView : BMKPinAnnotationView
/**
 *  聚合的个数
 */
@property (nonatomic, assign) NSInteger size;

/**
 *  聚合的数字标志
 */
@property (nonatomic, strong) UILabel *label;



- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
