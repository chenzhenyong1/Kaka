//
//  AlbumsPhotoCollectionViewCell.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/1.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumsModel;
@interface AlbumsPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *itemImage;
@property (nonatomic, strong) UIButton *selectBtn;

- (void)refreshData:(AlbumsModel *)model;

@end
