//
//  EyeSubjectsCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>


@class EyeSubjectsModel;
typedef void(^commentBlock)(void);
typedef void(^cancelCollectBlock)(void);
typedef void(^shareBtnBlock)(void);
typedef void(^praiseBtnBlock)(BOOL isVote);
typedef void(^deleteBtnBlock)();
@interface EyeSubjectsCell : UITableViewCell


/** 播放按钮 */
@property (nonatomic, weak) UIButton *playBtn;
/** 点赞按钮 */
@property (nonatomic, weak) UIButton *voteCountButton;
/** EyeSubjectsModel */
@property (nonatomic, strong) EyeSubjectsModel *model;
/** 点击评论按钮的回调 */
@property (nonatomic, copy) commentBlock commentBlock;
/** 点击取消点赞按钮的回调 */
@property (nonatomic, copy) cancelCollectBlock cancelCollectBlock;
/** 点击分享按钮的回调 */
@property (nonatomic, copy) cancelCollectBlock shareBtnBlock;
/** 点赞按钮的回调 */
@property (nonatomic, copy) praiseBtnBlock praiseBtnBlock;
/** 话题类型  */
@property (nonatomic, assign) EyeSubjectsControllerType type;

/** 分享的点赞按钮 */
@property (nonatomic, weak) UIButton *shareVoteCountButton;
/** 分享的查看按钮 */
@property (nonatomic, weak) UIButton *shareViewCountButton;
/** 分享的评论按钮 */
@property (nonatomic, weak) UIButton *shareCommentCountButton;
/** 分享的删除按钮 */
@property (nonatomic, weak) UIButton *delteButton;
/** 点击删除按钮的回调 */
@property (nonatomic, copy) deleteBtnBlock deleteBtnBlock;


- (void)refreshUI:(EyeSubjectsModel *)model;

@end
