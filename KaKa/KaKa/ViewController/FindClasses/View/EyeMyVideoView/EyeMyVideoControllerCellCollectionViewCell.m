//
//  EyeMyVideoControllerCellCollectionViewCell.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeMyVideoControllerCellCollectionViewCell.h"
#import "VideoListModel.h"

@interface EyeMyVideoControllerCellCollectionViewCell ()

@property (nonatomic, strong) UIImageView *videoAndPhotoImage;

@property (nonatomic, strong) UIImageView *play_image;

@property (nonatomic, strong) UILabel *time_lab;
@end


@implementation EyeMyVideoControllerCellCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self configLayout];
        self.videoAndPhotoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.width)];
        self.videoAndPhotoImage.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.videoAndPhotoImage];
        self.videoAndPhotoImage.contentMode = UIViewContentModeScaleAspectFit;
        self.play_image = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, VIEW_H(_videoAndPhotoImage)-28*PSDSCALE_Y, 18*PSDSCALE_X, 22*PSDSCALE_Y)];
        self.play_image.contentMode = UIViewContentModeScaleAspectFill;
        self.play_image.image = GETYCIMAGE(@"albums_play");
        [self.videoAndPhotoImage addSubview:self.play_image];
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H(_videoAndPhotoImage)-35*PSDSCALE_Y, VIEW_W(_videoAndPhotoImage)-10*PSDSCALE_X, 24*PSDSCALE_Y)];
        self.time_lab.textColor = [UIColor whiteColor];
        self.time_lab.textAlignment = NSTextAlignmentRight;
        self.time_lab.font = [UIFont systemFontOfSize:17*FONTCALE_Y];
        [self.contentView addSubview:self.time_lab];
        
    }
    return self;
}

//- (void)configLayout
//{
//    
//    
//    
//    [self.videoAndPhotoImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.edges.equalTo(self.contentView);
//        
//    }];
//    
//    
////    [self.play_image mas_makeConstraints:^(MASConstraintMaker *make) {
////        
////        make.center.equalTo(self.contentView);
////        make.size.mas_equalTo(CGSizeMake(80*PSDSCALE_X, 80*PSDSCALE_Y));
////        
////    }];
//}

-(void)refreshData:(VideoListModel *)model
{
    
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
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.videoAndPhotoImage.image = [UIImage imageWithData:imageData];
            
        });
    });
}

//#pragma mark -- property
//
//-(UIImageView *)videoAndPhotoImage
//{
//    if (!_videoAndPhotoImage) {
//        
//        _videoAndPhotoImage = [[UIImageView alloc] init];
//        
//        _videoAndPhotoImage.backgroundColor = [UIColor blackColor];
//        
//        _videoAndPhotoImage.contentMode = UIViewContentModeScaleAspectFit;
//        
//       
//        
//        
//        
//        [self.contentView addSubview:_videoAndPhotoImage];
//        
//    }
//    
//    return _videoAndPhotoImage;
//}
//
//-(UIImageView *)play_image
//{
//    if (!_play_image) {
//        UIImageView *play_image = [[UIImageView alloc] init];
//        play_image.contentMode = UIViewContentModeScaleAspectFill;
//        play_image.image = GETYCIMAGE(@"camera_play");
//        [self.videoAndPhotoImage addSubview:play_image];
//        
//        
//        
//        _play_image = play_image;
//    }
//    
//    return _play_image;
//}

@end
