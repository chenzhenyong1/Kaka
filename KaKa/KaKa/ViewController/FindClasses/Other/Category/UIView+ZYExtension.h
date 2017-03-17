//
//  UIView+ZYExtension.h
//  百思不得姐
//
//  Created by 陈振勇 on 16/5/30.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZYExtension)

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;


@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat right;

- (void)removeAllSubViews;

@end
