//
//  EyeMyVideoControllerCellCollectionViewCell.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoListModel;
@interface EyeMyVideoControllerCellCollectionViewCell : UICollectionViewCell

- (void)refreshData:(VideoListModel *)model;


@end