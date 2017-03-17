//
//  EyeMusicCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/30.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeMusicCell.h"


@interface EyeMusicCell ()

/** 图片 */
@property (nonatomic, strong) UIImageView *imgView;
/** 音乐名 */
@property (nonatomic, strong) UILabel *musicLabel;

@end


@implementation EyeMusicCell


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
       
        make.left.right.top.equalTo(self);
        make.height.equalTo(@45);
        
    }];
    
    [self.musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self);
        make.top.equalTo(self.imgView.mas_bottom);
        make.bottom.equalTo(self);
        
    }];
}

#pragma mark -- public

-(void)refreshUI:(NSDictionary *)dic
{
    for (NSString *musicName in dic.allKeys) {
        
        self.imgView.image = [UIImage imageNamed:dic[musicName]];
        self.musicLabel.text = musicName;
    }
    
}



#pragma mark -- property

-(UIImageView *)imgView
{
    if (!_imgView) {
        
        _imgView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_imgView];
        
    }
    
    return _imgView;
}

-(UILabel *)musicLabel
{
    if (!_musicLabel) {
     
        _musicLabel = [[UILabel alloc] init];
        _musicLabel.textAlignment = NSTextAlignmentCenter;
        _musicLabel.textColor = [UIColor darkGrayColor];
        _musicLabel.font = [UIFont systemFontOfSize:10];
        
        [self.contentView addSubview:_musicLabel];
        
    }
    
    return _musicLabel;
}

@end
