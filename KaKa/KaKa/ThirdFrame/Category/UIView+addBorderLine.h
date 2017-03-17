//
//  UIView+addBorderLine.h
//  YunAnJiaRequestTest
//
//  Created by 深圳市 秀软科技有限公司 on 16/3/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, BorderLineDirection) {
    kBorderLineDirectionTop = 1 << 0,       // 上边界
    kBorderLineDirectionLeft = 1 << 1,      // 左边界
    kBorderLineDirectionRight = 1 << 2,     // 右边界
    kBorderLineDirectionBottom = 1 << 3,    // 下边界
    kBorderLineDirectionAll = 0xF,          // 4个边界都有
};

@interface UIView (addBorderLine)

/*
 根据方向画View的边框
 color        边框颜色
 borderWidth  边框宽度
 direction    方向，可以有多个 如kBorderLineDirectionTop|kBorderLineDirectionRight
 */
- (void)addBorderLineWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth direction:(BorderLineDirection)direction;
@end
