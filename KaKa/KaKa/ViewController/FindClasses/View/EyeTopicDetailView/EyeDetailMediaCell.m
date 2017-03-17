//
//  EyeDetailMediaCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeDetailMediaCell.h"
#import "MediaList.h"
#import "EyePictureListModel.h"
#import "AlbumsPathModel.h"
#import "MyTools.h"
@interface EyeDetailMediaCell ()

/** 封面 */
@property (nonatomic, weak) UIImageView *coverImageView;
/** 话题文本 */
@property (nonatomic, weak) UILabel *shorteTextLabel;

@end


@implementation EyeDetailMediaCell

#pragma mark -- life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self configureLayout];
    }
    
    return self;
}

- (void)configureLayout
{
    //图片封面
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self).offset(10);
        
        make.left.right.equalTo(self);
        
        make.height.equalTo(@(kScreenWidth * 9/16));
        
    }];
    //话题文本
    [self.shorteTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(10);
        
    }];
    //播放按钮
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.coverImageView);
        
    }];

}

#pragma mark -- public
-(void)refreshUI:(MediaList *)mediaList
{
    if ([mediaList.mediaType isEqualToString:@"v"] || [mediaList.mediaType isEqualToString:@"t"]) {
        
        self.playBtn.hidden = NO;
        
    }else{
        self.playBtn.hidden = YES;
    }
    
    if ([self.subjectKind integerValue] == 4) {
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }else
    {
        self.coverImageView.clipsToBounds = NO;
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:mediaList.thumbUrl] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
    
    self.shorteTextLabel.text = mediaList.shortText;
    
    

}
/**
 *  查看图片
 *
 *  @param model EyePictureListModel
 */
- (void)refreshCheckPic:(EyePictureListModel *)model
{
    self.playBtn.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.coverImageView.image = [UIImage imageWithData:imageData];
            
        });
    });
    
}

/**
 *  游记查看
 *
 *  @param imagePath 图片路径
 */
- (void)refreshCheckTravels:(NSString *)imagePath
{
    self.playBtn.hidden = YES;
    
    self.coverImageView.image = [self getTraverlPicture:imagePath];
    
}


/**
 *  查看轨迹
 *
 *  @param model EyePictureListModel
 */
- (void)refreshCheckTrack:(AlbumsPathModel *)model
{
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.playBtn.hidden = YES;
    
    NSArray *pathArr =[MyTools getAllDataWithPath:Path_Photo(model.mac_adr) mac_adr:model.mac_adr];
    for (NSString *str in pathArr)
    {
        NSString *temp_str1 = [model.fileName componentsSeparatedByString:@"."][0];
        NSString *temp_str2 = [str componentsSeparatedByString:@"/"].lastObject;
        temp_str2 = [temp_str2 componentsSeparatedByString:@"."][0];
        if ([temp_str1 isEqualToString:temp_str2])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:str];
            self.coverImageView.image = image;
        }
        
    }
    
}

#pragma mark -- 获取游记图片

- (UIImage *)getTraverlPicture:(NSString *)imagePath
{
    
//    NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
//    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    
    ZYLog(@"imagePath = %@",imagePath);
    return image;
}


#pragma mark -- serFrame
-(void)setFrame:(CGRect)frame
{
    //    self.backgroundColor = [UIColor redColor];
    frame.size.height -= 10;
//    frame.origin.y += 10;
    
    [super setFrame:frame];
}

#pragma mark -- property
-(UIImageView *)coverImageView
{
    if (!_coverImageView) {
        UIImageView *imageView = [UIImageView new];
        
        [self.contentView addSubview:imageView];
        
        _coverImageView = imageView;
    }
    
    return _coverImageView;
}

-(UILabel *)shorteTextLabel
{
    if (!_shorteTextLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        [self addSubview:label];
        
        _shorteTextLabel = label;
    }
    return _shorteTextLabel;
}

-(UIButton *)playBtn
{
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"find_videoPlay"] forState:UIControlStateNormal];
        [btn sizeToFit];
        
        
        [self.contentView addSubview:btn];
        
        _playBtn = btn;
    }
    
    return _playBtn;
}

@end
