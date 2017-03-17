//
//  EyeBaseViewController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/15.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EyeCustomBtn;
@interface EyeBaseViewController : UIViewController

/** 心情描述 */
@property (nonatomic, copy) NSString *mood;

/**
 *  添加文字提示框
 *
 *  @param text     提示语
 *  @param duration 消失时间
 */
- (void)addActityText:(NSString *)text deleyTime:(float)duration;
/**
 *  加载提示
 *
 *  @param title    标题
 *  @param subTitle 子标题
 */
- (void)addActityLoading:(NSString *)title subTitle:(NSString *)subTitle;
/**
 *  移除加载提示
 */
- (void)removeActityLoading;

/**
 *  删除剪辑文件
 */
-(void)deleteTmpFile:(NSString *)path;

// 在视频的某个时间截取图片
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

//按钮图片在上文字在下
- (EyeCustomBtn *)setupButtonFrame:(CGRect)frame imageName:(NSString *)imageName;


#pragma mark -- 话题交互请求
/**
 *  发送查看请求
 *
 *  @param subjectId 话题ID
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
- (void)checkTopicWithSubjectID:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;


/**
 *  发送是否收藏请求
 *
 *  @param isFav     判断是否收藏
 *  @param subjectId 话题ID
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
- (void)favTopic:(BOOL)isFav withSubjectId:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
/**
 *  发送是否点赞请求
 *
 *  @param isVote    判断是否点赞
 *  @param subjectId 话题ID
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
- (void)voteTopic:(BOOL)isVote withSubjectId:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

/**
 *  点击分享
 *
 *  @param ctl 分享按钮所在的控制器
 */
-(void)shareClick:(UIViewController *)ctl withSubjectID:(NSString *)subjectId title:(NSString *)title;
/**
 *  发送删除话题
 *
 *  @param subjectId 话题ID
 *  @param success   请求成功回调
 *  @param failure   请求失败回调
 */
-(void)deleteSubjectWithSubjectId:(NSString *)subjectId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;


- (void)setupNavBar;

@end
