//
//  Subject.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  话题对象

#import <Foundation/Foundation.h>

@interface Subject : NSObject

/** 话题ID */
@property (nonatomic, copy) NSString *ID;
/** 发表话题的用户的ID */
@property (nonatomic, copy) NSString *authorUserId;
/** 发表话题的用户的昵称 */
@property (nonatomic, copy) NSString *authorNickName;
/** 发表话题的用户头像的媒体URL。有2种情况：
 schema	意义
 app	应用预定义头像，格式：app:<文件名>
 http	用户自己上传的头像， */
@property (nonatomic, copy) NSString *authorPortraitUrl;
/** 话题类型ID */
@property (nonatomic, copy) NSString *subjectKind;
/** 话题ID */
@property (nonatomic, copy) NSString *subjectState;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 话题文本 */
@property (nonatomic, copy) NSString *shortText;
/** 发表时间，epoch时间 */
@property (nonatomic, copy) NSString *publishTime;
/** 发表时的经度 */
@property (nonatomic, copy) NSString *lon;
/** 发表时的纬度 */
@property (nonatomic, copy) NSString *lat;
/** 发表时的位置描述 */
@property (nonatomic, copy) NSString *location;
/** 话题栏目ID */
@property (nonatomic, copy) NSString *columnId;
/** 话题缩略图媒体信息数组 */
@property (nonatomic, copy) NSArray *thumbList;
/** 平均速度（游记、轨迹），单位：公里/小时 */
@property (nonatomic, copy) NSString *avgSpd;
/** 总时长（游记、轨迹、视频），单位：秒 */
@property (nonatomic, copy) NSString *timeLength;
/** 总里程（游记、轨迹），单位：公里 */
@property (nonatomic, copy) NSString *mileage;
/** 查看数 */
@property (nonatomic, copy) NSString *viewCount;
/** 当前用户是否查看过 */
@property (nonatomic, copy) NSString *viewed;
/** 收藏数 */
@property (nonatomic, copy) NSString *setFavCount;
/** 当前用户是否收藏过 */
@property (nonatomic, copy) NSString *favSet;
/** 话题ID */
@property (nonatomic, copy) NSString *voteCount;
/** 点赞数 */
@property (nonatomic, copy) NSString *voted;
/** 评论数量 */
@property (nonatomic, copy) NSString *remarkCount;

/****** 额外的辅助属性 ******/

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;
//{
//    "id" : 1234,
//    "authorUserId" : "28",
//    "authorNickName" : "用户昵称",
//    "authorPortraitUrl" : "http://portrait-url",
//    "subjectKind" : 1,
//    "subjectState" : 2,
//    "title" : "话题标题",
//    "shortText" : "话题文字内容",
//    "publishTime" : 1468311680510,
//    "lon" : 124.234344,
//    "lat" : 22.234423,
//    "location" : "宝安区清丽路",
//    "columnId" : 2,
//    "thumbList" : [ {
//        "mediaId" : "i-1wNB9fqUSOyUI-retX0KOw.jpg",
//        "thumbMediaType" : "h ",
//        "thumbMediaId" : "h-1wNB9fqUSOyUI-retX0KOw-thumb.jpg",
//        "thumbUrl" : "http://thumb-url"
//    } ],
//    "avgSpd" : 61.5,
//    "timeLength" : 7200,
//    "mileage" : 893000,
//    "viewCount" : 12,
//    "viewed" : true,
//    "setFavCount" : 2,
//    "favSet" : false,
//    "voteCount" : 2,
//    "voted" : false,
//    "remarkCount" : 10
//}
@end
