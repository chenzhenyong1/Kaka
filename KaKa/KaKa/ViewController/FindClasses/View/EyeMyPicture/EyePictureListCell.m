//
//  EyePictureListCell.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyePictureListCell.h"
#import "EyePictureListModel.h"


@implementation EyePictureListCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _itemImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _itemImage.backgroundColor = [UIColor whiteColor];
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        _itemImage.clipsToBounds = YES;
        [self.contentView addSubview:_itemImage];
        
        self.selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(200*PSDSCALE_X, 8*PSDSCALE_Y, 30*PSDSCALE_X, 30*PSDSCALE_Y)];
        [self.selectBtn setImage:GETYCIMAGE(@"albums_btn_nor") forState:UIControlStateNormal];
        [self.selectBtn setImage:GETYCIMAGE(@"albums_btn_sel") forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectBtn];
    }
    
    return self;
}



- (void)refreshData:(EyePictureListModel *)model
{
//    if (!model.isShow)
//    {
//        self.selectBtn.hidden = YES;
//    }
//    else
//    {
//        self.selectBtn.hidden = NO;
//    }
    self.selectBtn.selected = model.isSelect;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.itemImage.image = [UIImage imageWithData:imageData];
            
        });
    });
    
    
}

@end
