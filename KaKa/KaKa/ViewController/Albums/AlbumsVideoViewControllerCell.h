//
//  AlbumsVideoViewControllerCell.h
//  KaKa
//
//  Created by Change_pan on 16/8/1.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumsModel;
@interface AlbumsVideoViewControllerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *VideoAndPhotoImage;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UILabel *time_lab;

- (void)refreshData:(AlbumsModel *)model;
@end
