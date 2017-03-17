//
//  ThumbList.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  话题缩略图媒体信息

#import <Foundation/Foundation.h>

@interface ThumbList : NSObject<NSCoding>

/** 缩略图媒体ID */
@property (nonatomic, copy) NSString *thumbMediaId;
/** 缩略图URL */
@property (nonatomic, copy) NSString *thumbUrl;
/** 缩略图媒体类型 */
@property (nonatomic, copy) NSString *thumbMediaType;
/** 原始媒体ID */
@property (nonatomic, copy) NSString *mediaId;

//{
    //                     thumbMediaId : t-mH0RyGTaRmKezQFSNeOy0g-thumb.jpg,
    //                     thumbUrl : http://ekaka-tp.oss-cn-shenzhen.aliyuncs.com/616/t-mH0RyGTaRmKezQFSNeOy0g-thumb.jpg,
    //                     thumbMediaType : t,
    //                     mediaId : v-mH0RyGTaRmKezQFSNeOy0g.mp4
    //                 }

@end
