//
//  EyeMyPictureCollectionCell.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeMyPictureCollectionCell.h"


@interface EyeMyPictureCollectionCell ()

/** 图片 */
@property (nonatomic, strong) UIImageView *imgView;


@end

@implementation EyeMyPictureCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configLayout];
    }
    
    return self;
}

- (void)configLayout
{
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
    }];
    
}

#pragma mark --- public

-(void)refreshUI:(NSString *)imageName
{
    if ([imageName isEqualToString:@"bg_add_photo"]) {
        self.imgView.image = [UIImage imageNamed:imageName];
    }else
    {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageName];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.imgView.image = [UIImage imageWithData:imageData];
                
            });
        });
    }
    
    
//    self.imgView.image = image;
    
}

#pragma mark -- property

-(UIImageView *)imgView
{
    if (!_imgView) {
        
        _imgView = [[UIImageView alloc] init];
        
        _imgView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:_imgView];
        
    }
    
    return _imgView;
}

@end
