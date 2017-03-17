//
//  FindHeader.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/19.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#ifndef FindHeader_h
#define FindHeader_h

#ifdef DEBUG
#define ZYLog(...) NSLog(__VA_ARGS__)
#else
#define ZYLog(...)
#endif

#define ZYLogFunc ZYLog(@"%s",__func__)

#define ZYRGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define ZYGlobalBgColor ZYRGBColor(244,248,251)

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

typedef enum {
    
    EyeSubjectsControllerTypeLatest,//最新
    EyeSubjectsControllerTypeMore,//更多
    EyeSubjectsControllerTypeCollect,//收藏
    EyeSubjectsControllerTypeShare,//分享
    
}EyeSubjectsControllerType;



#import "UIView+ZYExtension.h"
#import "UIImage+Extension.h"
#import "NSDate+EyeExtension.h"
#import "HttpTool.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>


/************ 百度地图  *********************/


#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件


/************ 百度地图  *********************/


/************ 网络请求地址  *********************/
#define HeadURL HeadURl

//广告
#define Ads_URL [HeadURL stringByAppendingString:@"qryAdvertisements"]
//首页广场栏目
#define SubjectPiazza_URL [HeadURL stringByAppendingString:@"qrySubjectPiazza"]
//话题
#define Subjects_URL [HeadURL stringByAppendingString:@"qrySubjects"]
//话题详情
#define SubjectDetail_URL [HeadURL stringByAppendingString:@"qrySubjectDetail"]
//媒体授权
#define MediaAccess_URL [HeadURL stringByAppendingString:@"acquireMediaAccess"]
//创建媒体记录
#define createMedias_URL [HeadURL stringByAppendingString:@"createMedias"]
//更新媒体状态
#define updateMediaState_URL [HeadURL stringByAppendingString:@"updateMediaState"]
//发表话题
#define submitSubject_URL [HeadURL stringByAppendingString:@"submitSubject"]
//话题评论
#define SubjectRemarks_URL [HeadURL stringByAppendingString:@"qrySubjectRemarks"]
//违章类型
#define Enums_URL [HeadURL stringByAppendingString:@"qryEnums"]

//话题交互接口
#define subjectInteractive_URL [HeadURL stringByAppendingString:@"subjectInteractive"]

//更新用户一般信息接口
#define updateUserInfo_URL [HeadURL stringByAppendingString:@"updateUserInfo"]

//查询系统设置接口
#define qryProfile_URL [HeadURL stringByAppendingString:@"qryProfile"]
//获取话题分享URL接口
#define qryShareSubject_URL [HeadURL stringByAppendingString:@"qryShareSubjectUrl"]

//删除话题
#define deleteSubject_URL [HeadURL stringByAppendingString:@"deleteSubject"]

//图片栏目id
#define PHOTO_SUBJ_COLUM_ID @"photo-subj-column-id"
//视频栏目id
#define VIDEO_SUBJ_COLUM_ID @"video-subj-column-id"
//游记栏目id
#define TRAVEL_SUBJ_COLUM_ID @"travel-subj-column-id"
//违章举报栏目id
#define TV_SUBJ_COLUM_ID @"tv-subj-column-id"
//轨迹栏目id
#define TRACK_SUBJ_COLUM_ID @"track-subj-column-id"

#define LoginToken [SettingConfig shareInstance].loginToken

/************ 友盟  *********************/
#import <UMSocial.h>
#define UMAppKey @"57860b88e0f55a54f00023ce"

/************ 友盟  *********************/

/************ 网络请求地址  *********************/

//系统单例
#define UserDefaults  [NSUserDefaults standardUserDefaults]
#define NotificationCenter  [NSNotificationCenter defaultCenter]
#define SharedApplication  [UIApplication sharedApplication]
#define APPDelegate     [[UIApplication sharedApplication] delegate]
#define FileManager [NSFileManager defaultManager]


#endif /* FindHeader_h */
