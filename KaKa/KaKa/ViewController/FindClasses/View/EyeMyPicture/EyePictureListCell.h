//
//  EyePictureListCell.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EyePictureListModel;
@interface EyePictureListCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *itemImage;
@property (nonatomic, strong) UIButton *selectBtn;

- (void)refreshData:(EyePictureListModel *)model;

@end
