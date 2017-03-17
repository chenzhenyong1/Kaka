//
//  MediaList.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaList : NSObject

/** 话题ID */
@property (nonatomic, copy) NSString *subjectId;
/** 媒体ID */
@property (nonatomic, copy) NSString *mediaId;
/** 媒体类型，为以下枚举之一：
 代码	意义
 v	（音）视频
 i	图片
 a	音频
 t	视频缩略图
 h	图片缩略图
 p	头像
 */
@property (nonatomic, copy) NSString *mediaType;
/** 媒体宽度，单位：像素 */
@property (nonatomic, copy) NSString *width;
/** 媒体高度，单位：像素 */
@property (nonatomic, copy) NSString *height;
/** 缩略图媒体ID */
@property (nonatomic, copy) NSString *thumbMediaId;
/** 缩略图URL */
@property (nonatomic, copy) NSString *thumbUrl;
/** 媒体创建时间，epoch时间 */
@property (nonatomic, copy) NSString *createTime;
/** 媒体时长，单位：秒 */
@property (nonatomic, copy) NSString *timeLength;
/** 附着在轨迹的序号 */
@property (nonatomic, copy) NSString *attachToTrackSeqNum;
/** 文字描述（心情短语） */
@property (nonatomic, copy) NSString *shortText;
/** 轨迹点的添加时间，epoch时间 */
@property (nonatomic, copy) NSString *addedTime;
/** 是否静音 */
@property (nonatomic, copy) NSString *mute;
/** 背景音乐文件名，APP端的本地音乐文件名 */
@property (nonatomic, copy) NSString *backgroundMusic;

/****** 额外的辅助属性 ******/

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end
