//
//  AlbumsMapPaopaoImageVIew.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/9/2.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsMapPaopaoImageVIew.h"

@implementation AlbumsMapPaopaoImageVIew

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUI];
    }
    
    return self;
}

- (void)createUI {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = GETYCIMAGE(@"albums_video_bg2.png");
    [self addSubview:imageView];
    _imageView = imageView;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(imageView), VIEW_H(imageView))];
    bg.image = [UIImage imageNamed:@"albums_annotation_bg.png"];
    [self addSubview:bg];
    
    imageView.layer.mask = bg.layer;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 13, -5, 15, 15)];
    label.backgroundColor = RGBSTRING(@"b11c22");
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:FONTCALE_Y * 18];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 15/2.0;
    label.layer.masksToBounds = YES;
    [self addSubview:label];
    _imageCountLabel = label;
}

@end
