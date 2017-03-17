//
//  EyePopView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/20.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EyePopMenu : UIView


/** 是否要蒙版  */
@property (nonatomic, assign,getter=isDimBackground) BOOL dimBackground;


/**
 *  初始化方法
 */
- (instancetype)initWithContentView:(UIView *)contentView;
+ (instancetype)popMenuWithContentView:(UIView *)contentView;
/**
 *  设置菜单的背景图片
 *
 *  @param backgroundImage 图片
 */
- (void)setBackground:(UIImage *)backgroundImage;
/**
 *  显示菜单（位置）
 *
 *  @param rect CGRect
 */
- (void)showInRect:(CGRect)rect;
/**
 *  关闭菜单
 */
- (void)dismiss;

@end
