//
//  EyeSubjectsController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  话题列表控制器(最新，更多。。。的父类)

#import "EyeBaseViewController.h"
#import "EyePlayView.h"


@class ColumnBrief;
@interface EyeSubjectsController : EyeBaseViewController


/** tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *latestDataArr;

/** 栏目 */
@property (nonatomic, strong) ColumnBrief *columnBrief;

/** 话题类型  */
@property (nonatomic, assign) EyeSubjectsControllerType type;

/** 所要查询的收藏话题的用户的ID */
@property (nonatomic, copy) NSString *collectedBy;
/** 所要查询的发表话题的用户的ID */
@property (nonatomic, copy) NSString *issuedBy;

/** cell的视频播放器 */
@property (nonatomic, weak) EyePlayView *playView;

@end
