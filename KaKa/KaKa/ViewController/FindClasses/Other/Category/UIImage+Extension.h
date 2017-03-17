//
//  UIImage+Extension.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/21.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  根据图片名返回一张能够自由拉伸的图片
 *
 *  @param name 图片名
 *
 *  @return 图片
 */
+ (UIImage *)resizeImage:(NSString *)name;

/**
 * 圆形图片
 */
- (UIImage *)circleImage;
+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
@end
