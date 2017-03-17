//
//  UIView+addBorderLine.m
//  YunAnJiaRequestTest
//
//  Created by 深圳市 秀软科技有限公司 on 16/3/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "UIView+addBorderLine.h"

@implementation UIView (addBorderLine)

- (void)addBorderLineWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth direction:(BorderLineDirection)direction
{
    if (direction == 0) {
        return;
    }
    
    if (direction & kBorderLineDirectionTop) {
        // 包含了 kBorderLineDirectionTop
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, borderWidth)];
        line.backgroundColor = color;
        [self addSubview:line];
    }
    
    if (direction & kBorderLineDirectionLeft) {
        // 包含了 kBorderLineDirectionLeft
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, self.bounds.size.height)];
        line.backgroundColor = color;
        [self addSubview:line];
    }
    
    if (direction & kBorderLineDirectionRight) {
        // 包含了 kBorderLineDirectionRight
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-borderWidth, 0, borderWidth, self.bounds.size.height)];
        line.backgroundColor = color;
        [self addSubview:line];
    }
    
    if (direction & kBorderLineDirectionBottom) {
        // 包含了 kBorderLineDirectionBottom
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-borderWidth, self.bounds.size.width, borderWidth)];
        line.backgroundColor = color;
        [self addSubview:line];
    }
}

@end
