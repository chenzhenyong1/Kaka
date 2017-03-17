//
//  AlbumsTravelAddCollectionViewCell.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/8.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelAddCollectionViewCell.h"

@implementation AlbumsTravelAddCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _itemImage = [[UIImageView alloc] initWithFrame:self.bounds];
//        _itemImage.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        _itemImage.clipsToBounds = YES;
        _itemImage.userInteractionEnabled = YES;
        [self.contentView addSubview:_itemImage];
        
        // 删除按钮
        UIImage *delImage = GETNCIMAGE(@"albums_photo_delete.png");
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(_itemImage) - delImage.size.width, 0, delImage.size.width, delImage.size.height)];
        [deleteBtn setBackgroundImage:delImage forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deletePhoto_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        [_itemImage addSubview:deleteBtn];
        _deleteBtn = deleteBtn;
    }
    
    return self;
}

- (void)deletePhoto_button_clicked_action:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDeleteBtnWithIndexPath:)]) {
        [_delegate didClickDeleteBtnWithIndexPath:self.indexPath];
    }
}

@end
