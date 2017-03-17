//
//  EyeVideoListCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeVideoListCell.h"
#import <UIImageView+WebCache.h>

@interface  EyeVideoListCell ()


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation EyeVideoListCell

- (void)awakeFromNib {
    
    [self.imageView sd_setImageWithURL:[[NSBundle mainBundle] URLForResource:@"FinalVideo-711.mov" withExtension:nil] placeholderImage:[UIImage imageNamed:@"img_03"]];
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = [imageName copy];
    
   
}

@end
