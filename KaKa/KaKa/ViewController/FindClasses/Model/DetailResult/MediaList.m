//
//  MediaList.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  话题媒体列表

#import "MediaList.h"

@implementation MediaList
{
    CGFloat _cellHeight;
}

- (CGFloat)cellHeight
{
    
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(kScreenWidth - 20 , MAXFLOAT);
        // 计算文字的高度
        CGFloat textH = [self.shortText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
        
        // cell的高度
        _cellHeight = kScreenWidth * 9/16 + 10 + textH + 10;
    }
    return _cellHeight;
}

@end
