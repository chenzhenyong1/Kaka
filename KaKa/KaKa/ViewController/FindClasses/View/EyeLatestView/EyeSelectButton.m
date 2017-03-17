//
//  EyeSelectButton.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSelectButton.h"

@implementation EyeSelectButton

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.x = 0;
    self.imageView.width = 15;
    self.imageView.height = 15;
    self.imageView.centerY = self.height / 2;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.x = self.imageView.right + 5;
    self.titleLabel.centerY = self.height / 2;
}

@end
