//
//  EyeAroundTopicListCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAroundTopicListCell.h"
#import "EyeSubjectsModel.h"
#import "ThumbList.h"

@interface EyeAroundTopicListCell ()

/** 封面 */
@property (nonatomic, weak) UIImageView *coverImageView;
/** 封面蒙版 */
@property (nonatomic, weak) UIView *darkView;
/** 标题 */
@property (nonatomic, weak) UILabel *topicTitleLabel;

@end


@implementation EyeAroundTopicListCell

#pragma mark -- life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor whiteColor];
        [self configureLayout];
    }
    return self;
}

- (void)configureLayout
{
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
        
    }];
    
    [self.darkView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.coverImageView);
        
    }];
    
    [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.center.equalTo(self);
        
    }];

}

#pragma mark -- public

-(void)refreshUIWithModel:(EyeSubjectsModel *)model
{
    if ([model.subjectKind integerValue] == 4) {
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }else
    {
        self.coverImageView.clipsToBounds = NO;
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[model.thumbList[0] thumbUrl]] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
    
    self.topicTitleLabel.text = model.title;
}



#pragma mark -- property
-(UIImageView *)coverImageView
{
    if (!_coverImageView) {
        
        UIImageView *coverImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:coverImageView];
        
        _coverImageView = coverImageView;

    }
    
    return _coverImageView;
}

-(UIView *)darkView
{
    if (!_darkView) {
        
        UIView *darkView = [[UIView alloc] init];
        
        darkView.backgroundColor = [UIColor blackColor];
        
        darkView.alpha = 0.0;
        
        [self.coverImageView addSubview:darkView];
        
        _darkView = darkView;
        
    }
    
    return _darkView;
}

-(UILabel *)topicTitleLabel
{
    if (!_topicTitleLabel) {
        
        UILabel *label = [[UILabel alloc] init];
        
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        
        [self.contentView addSubview:label];
        _topicTitleLabel = label;
    }
    
    return _topicTitleLabel;
}

@end
