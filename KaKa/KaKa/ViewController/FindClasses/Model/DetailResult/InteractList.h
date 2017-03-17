//
//  InteractList.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  话题交互列表

#import <Foundation/Foundation.h>

@interface InteractList : NSObject

/** 媒体交互ID，只有评论类型的交互有此ID */
@property (nonatomic, copy) NSString *ID;
/** 话题ID */
@property (nonatomic, copy) NSString *subjectId;
/** 媒体交互类型代码 */
@property (nonatomic, copy) NSString *actType;
/** 发生交互的用户ID */
@property (nonatomic, copy) NSString *actorUserId;
/** 用户头像URL，有两种情况：
 schema	意义
 app	应用预定义头像，格式：app:<文件名>
 http	用户自己上传的头像，格式：http://...
 */
@property (nonatomic, copy) NSString *actorPortraitUrl;
/** 发生交互的时间，epoch时间 */
@property (nonatomic, copy) NSString *actTime;
/** 所回复的交互项ID，仅用于评论类型的交互 */
@property (nonatomic, copy) NSString *replyToId;
/** 所回复的用户的昵称 */
@property (nonatomic, copy) NSString *actorNickName;
/** 评论/回复文本 */
@property (nonatomic, copy) NSString *shortText;
/** 回复的用户的昵称 */
@property (nonatomic, copy) NSString *replyToNickName;
/****** 额外的辅助属性 ******/

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;
/** 楼层 */
@property (nonatomic, assign) NSInteger floorNum;
@end
