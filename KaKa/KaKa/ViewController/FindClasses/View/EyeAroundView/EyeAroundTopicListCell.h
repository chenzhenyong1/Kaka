//
//  EyeAroundTopicListCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  附近话题聊表的cell

#import <UIKit/UIKit.h>

@class EyeSubjectsModel;
@interface EyeAroundTopicListCell : UITableViewCell


- (void)refreshUIWithModel:(EyeSubjectsModel *)model;

@end
