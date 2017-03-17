//
//  AlbumsTravelAddCollectionViewCell.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/8.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumsTravelAddCollectionViewCellDelegate <NSObject>

@optional
// 删除按钮点击
- (void)didClickDeleteBtnWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface AlbumsTravelAddCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *itemImage;

@property (nonatomic, strong) UIButton *deleteBtn; // 删除按钮

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<AlbumsTravelAddCollectionViewCellDelegate> delegate;

@end
