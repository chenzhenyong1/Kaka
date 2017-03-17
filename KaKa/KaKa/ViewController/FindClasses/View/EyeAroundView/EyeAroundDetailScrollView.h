//
//  EyeAroundDetailScrollView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackList.h"

typedef void(^trackListBlock)(TrackList *trackList);
@interface EyeAroundDetailScrollView : UIView

/** 数据数组MediaList */
@property (nonatomic, strong) NSArray *mediaListArr;

/** 轨迹数组 */
@property (nonatomic, strong) NSArray *trackListArr;

/** 回调返回轨迹模型 */
@property (nonatomic, copy) trackListBlock aroundDetailBlock;


/** 话题类型ID */
@property (nonatomic, copy) NSString *subjectKind;

+ (instancetype)detailScrollView;
//视频取出和取消
- (void)deleteAndPause;

@end
