//
//  EyeCustomBtn.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeCustomBtn.h"

#define ImageRidio 0.6
@implementation EyeCustomBtn

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    // 1.title
    CGFloat titleX = 0;
    CGFloat titleY = self.bounds.size.height * ImageRidio - 3;
    CGFloat titleW = self.bounds.size.width;
    CGFloat titleH = self.bounds.size.height - titleY;
//    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];//title字体大小
    self.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    // 2.imageView

    self.imageView.centerX = self.titleLabel.centerX;
    self.imageView.centerY = (self.height - self.titleLabel.height) * 0.6;
    
//    [self.imageView sizeToFit];
}

@end
