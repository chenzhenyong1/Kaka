//
//  EyeDetailMediaCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaList;
@class EyePictureListModel;
@class AlbumsPathModel;
@interface EyeDetailMediaCell : UITableViewCell

/** 播放按钮 */
@property (nonatomic, weak) UIButton *playBtn;

/** 话题类型 */
@property (nonatomic, copy) NSString *subjectKind;

//详细信息
- (void)refreshUI:(MediaList *)mediaList;
//查看图片
- (void)refreshCheckPic:(EyePictureListModel *)model;
//查看游记
- (void)refreshCheckTravels:(NSString *)imagePath;
//查看轨迹
- (void)refreshCheckTrack:(AlbumsPathModel *)model;

@end
