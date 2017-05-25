//
//  PhotoCell.m
//  KaKa
//
//  Created by 陈振勇 on 2017/4/24.
//  Copyright © 2017年 深圳市秀软科技有限公司. All rights reserved.
//

#import "PhotoCell.h"
#import "AlbumsTravelDetailModel.h"

@interface  PhotoCell()

/** 图片 */
@property (nonatomic, weak) UIImageView *itemImageView;
/** 不分享的图片 */
@property (nonatomic, weak) UIImageView *unShare_imageView;

/** AlbumsTravelDetailModel */
@property (nonatomic, strong) AlbumsTravelDetailModel *model;

/** cameraMac */
@property (nonatomic, strong) NSString *cameraMac;

@end


@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *itemImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //        _itemImage.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        itemImageView.contentMode = UIViewContentModeScaleAspectFill;
        itemImageView.clipsToBounds = YES;
        itemImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:itemImageView];
        _itemImageView = itemImageView;

        UIImageView *unShare_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44*PSDSCALE_X, 28*PSDSCALE_Y)];
        unShare_imageView.image = GETYCIMAGE(@"albums_my_youji_share_sel");
        unShare_imageView.contentMode = UIViewContentModeScaleAspectFit;
        unShare_imageView.center = CGPointMake(VIEW_W(self)/2, VIEW_H(self)/2);
        [self.contentView addSubview:unShare_imageView];
        unShare_imageView.hidden = YES;
        _unShare_imageView = unShare_imageView;
    }
    
    return self;
}

-(void)layoutSubviews
{
    self.itemImageView.frame = self.bounds;
    
     _unShare_imageView.center = CGPointMake(VIEW_W(self)/2, VIEW_H(self)/2);
}


- (void)refreshWithAlbumsTravelDetailModel:(AlbumsTravelDetailModel *)model cameraMac:(NSString *)cameraMac
{
    _model = model;
    _cameraMac = cameraMac;
    
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)model.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", model.fileName]];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
    if (image) {
        self.itemImageView.image = image;
    }else{
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        self.itemImageView.image = [UIImage imageWithData:imageData];
    }
    
    
    
    _unShare_imageView.hidden = model.shared;
   
    
}




@end
