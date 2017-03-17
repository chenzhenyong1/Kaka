//
//  AlbumsVideoViewControllerCell.m
//  KaKa
//
//  Created by Change_pan on 16/8/1.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsVideoViewControllerCell.h"
#import "AlbumsModel.h"
@implementation AlbumsVideoViewControllerCell
{
    UIImageView *play_image;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.VideoAndPhotoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.width)];
        self.VideoAndPhotoImage.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.VideoAndPhotoImage];
        self.VideoAndPhotoImage.contentMode = UIViewContentModeScaleAspectFit;
        play_image = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, VIEW_H(_VideoAndPhotoImage)-28*PSDSCALE_Y, 18*PSDSCALE_X, 22*PSDSCALE_Y)];
        play_image.contentMode = UIViewContentModeScaleAspectFill;
        play_image.image = GETYCIMAGE(@"albums_play");
        [self.VideoAndPhotoImage addSubview:play_image];
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H(_VideoAndPhotoImage)-35*PSDSCALE_Y, VIEW_W(_VideoAndPhotoImage)-10*PSDSCALE_X, 24*PSDSCALE_Y)];
        self.time_lab.textColor = [UIColor whiteColor];
        self.time_lab.textAlignment = NSTextAlignmentRight;
        self.time_lab.font = [UIFont systemFontOfSize:17*FONTCALE_Y];
        [self.contentView addSubview:self.time_lab];
        
        self.selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(200*PSDSCALE_X, 8*PSDSCALE_Y, 30*PSDSCALE_X, 30*PSDSCALE_Y)];
        [self.selectBtn setImage:GETYCIMAGE(@"albums_btn_nor") forState:UIControlStateNormal];
        [self.selectBtn setImage:GETYCIMAGE(@"albums_btn_sel") forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectBtn];
        
        
        
    }
    return self;
}

- (void)refreshData:(AlbumsModel *)model
{
    if (!model.isShow)
    {
        self.selectBtn.hidden = YES;
    }
    else
    {
        self.selectBtn.hidden = NO;
    }
    
    NSString *time = [model.imageName componentsSeparatedByString:@"."].firstObject;
    time = [time componentsSeparatedByString:@"_"].lastObject;
    
    if ([time intValue] >=60)
    {
        int a = [time intValue]/60;
        int b = [time intValue]%60;
        self.time_lab.text = [NSString stringWithFormat:@"%2d:%2d",a,b];
    }
    else
    {
        self.time_lab.text = [NSString stringWithFormat:@"00:%d",[time intValue]];
    }
    
    self.selectBtn.selected = model.isSelect;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.VideoAndPhotoImage.image = [UIImage imageWithData:imageData];
            
        });
    });
}

@end
