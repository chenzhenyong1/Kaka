//
//  ImgView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgView : NSObject<NSCoding>

/** 缩略图图片URL */
@property (nonatomic, copy) NSString *imgUrl;
/** 话题ID */
@property (nonatomic, copy) NSString *subjectId;
/** 缩略图图片媒体ID */
@property (nonatomic, copy) NSString *imgMediaId;
/** 话题标题 */
@property (nonatomic, copy) NSString *subjectTitle;

/****** 额外的辅助属性 ******/

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;

//{
//    imgUrl : http://ekaka-tp.oss-cn-shenzhen.aliyuncs.com/616/t-4MLTzqHiRJSE6fMWftLNtA-thumb.jpg,
//    subjectId : 409,
//    imgMediaId : t-4MLTzqHiRJSE6fMWftLNtA-thumb.jpg,
//    subjectTitle :
//}

@end
