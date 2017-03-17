//
//  ImgView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "ImgView.h"
#import "MJExtension.h"

@implementation ImgView
{
    CGFloat _cellHeight;
}

MJExtensionCodingImplementation

-(CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(kScreenWidth * 0.3 , 20);
        // 计算文字的高度
        CGFloat textH = [self.subjectTitle boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
        //头顶按钮的文字高度也顺便写到这里
        CGFloat titleBtnH = [self.subjectTitle boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
        // cell的高度
        _cellHeight = 10 + titleBtnH + 10 + kScreenWidth * 0.3 + 10 +textH + 10;
    }
    return _cellHeight;
}

@end
