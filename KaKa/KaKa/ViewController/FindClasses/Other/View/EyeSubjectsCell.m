//
//  EyeSubjectsCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSubjectsCell.h"
#import "EyeCustomBtn.h"
#import "EyeSubjectsModel.h"
#import "ThumbList.h"
#import "InteractList.h"
#import "UIView+addBorderLine.h"

#define collectBtnW kScreenWidth / 5.0
#define shareBtnW kScreenWidth / 4.0

@interface EyeSubjectsCell ()

/** 头像 */
@property (nonatomic, weak) UIImageView *iconImageView;
/** 姓名 */
@property (nonatomic, weak) UILabel *nameLabel;
/** 地址 */
@property (nonatomic, weak) UILabel *addressLabel;
/** 发表时间 */
@property (nonatomic, weak) UILabel *publishTimeLabel;
/** 封面 */
@property (nonatomic, weak) UIImageView *coverImageView;
/** 话题文本 */
@property (nonatomic, weak) UILabel *shorteTextLabel;
/** 查看按钮 */
@property (nonatomic, weak) UIButton *viewCountButton;

/** 评论按钮 */
@property (nonatomic, weak) UIButton *remarkCountButton;
/** 分享按钮 */
@property (nonatomic, weak) UIButton *shareButton;

/** 底部话题信息 */
@property (nonatomic, weak) UIView *bottomInfoView;

/** 收藏底部话题信息 */
@property (nonatomic, weak) UIView *collectbottomInfoView;

/** 收藏按钮 */
@property (nonatomic, weak) UIButton *favButton;

/** 分享底部话题信息 */
@property (nonatomic, weak) UIView *sharebottomInfoView;


@end



@implementation EyeSubjectsCell


#pragma mark -- life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self configureLayout];
        
    }
    
    return self;
}

- (void)configureLayout
{
    //头像
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.equalTo(self).with.offset(10);
        
        make.size.mas_equalTo(CGSizeMake(45, 45));
        
    }];
    //名字
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        
        make.top.equalTo(self.iconImageView.mas_top);
        
    }];
    //地址
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.nameLabel.mas_left);
        make.bottom.equalTo(self.iconImageView.mas_bottom);
        
    }];
    //话题发布时间
    [self.publishTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.nameLabel.mas_bottom);
        
    }];
    //图片封面
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
        
        make.left.right.equalTo(self);
        
        make.height.equalTo(@(kScreenWidth * 9/16));
        
    }];
    //话题文本
    [self.shorteTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-10);
        
    }];
    
    //底部视图（装有查看评论等按钮）
    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.mas_bottom);
        make.left.with.right.equalTo(self);
        make.height.equalTo(@40);
        
    }];
    
    //查看按钮
    [self.viewCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.bottomInfoView.mas_left).offset(10);
        make.top.bottom.equalTo(self.bottomInfoView);
        make.width.equalTo(@(self.width * 0.2));
        
    }];
    //点赞按钮
    [self.voteCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.viewCountButton.mas_right).offset(10);
        make.top.bottom.equalTo(self.bottomInfoView);
        make.width.equalTo(self.viewCountButton.mas_width);
        
    }];
    
    //评论按钮
    [self.remarkCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.voteCountButton.mas_right).offset(10);
        make.top.bottom.equalTo(self.bottomInfoView);
        make.width.equalTo(self.viewCountButton.mas_width);
        
    }];
    //分享
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bottomInfoView.mas_centerY);
        
        make.right.equalTo(self.bottomInfoView.mas_right).offset(-10);
        
    }];
    //播放
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.coverImageView);
        
    }];
    
}

#pragma mark -- public

-(void)refreshUI:(EyeSubjectsModel *)model
{
   
    
    
    _model = model;
   
    if ([model.subjectKind integerValue]== 3 || [model.subjectKind integerValue] == 5) {
        
        self.playBtn.hidden = NO;
        
    }else{
        self.playBtn.hidden = YES;
    }
    if ([model.subjectKind integerValue] == 4) {
        
        self.coverImageView.clipsToBounds = YES;
        self.coverImageView.contentMode =  UIViewContentModeScaleAspectFill;
    }else
    {
        self.coverImageView.clipsToBounds = NO;
        self.coverImageView.contentMode =  UIViewContentModeScaleToFill;
    
    }
    
    //头像
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.authorPortraitUrl] placeholderImage:[UIImage imageNamed:@"default_header"]];
    
    self.nameLabel.text = model.authorNickName;
    self.addressLabel.text = model.location;
    //发布时间
     self.publishTimeLabel.text = model.publishTime;
    //话题封面
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[model.thumbList[0] thumbUrl]] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
    //话题文本
    self.shorteTextLabel.text = model.title;
    //底部按钮赋值
    [self getButtonValue:model];
    
//    [self layoutSubviews];
//    [self setNeedsLayout];
//
}
/**
 *  底部按钮赋值
 *
 *  @param model model description
 */
- (void)getButtonValue:(EyeSubjectsModel *)model
{
    //查看
    [self.viewCountButton setTitle:model.viewCount forState:UIControlStateNormal];
    [self.shareViewCountButton setTitle:model.viewCount forState:UIControlStateNormal];
    //点赞
    
    if (self.type == EyeSubjectsControllerTypeShare) {
        
        [self.shareVoteCountButton setTitle:model.voteCount forState:UIControlStateNormal];
    }else
    {
        [self.voteCountButton setTitle:model.voteCount forState:UIControlStateNormal];
    }
    
    //是否点赞
    if ([model.voted boolValue]) {
        
        if (self.type == EyeSubjectsControllerTypeShare) {
            
             self.shareVoteCountButton.selected = YES;
        }else
        {
            self.voteCountButton.selected = YES;
        }
        
        
       
    }else{
        
        if (self.type == EyeSubjectsControllerTypeShare) {
            
            self.shareVoteCountButton.selected = NO;
        }else
        {
            self.voteCountButton.selected = NO;
        }
        
        
        
    }
    
    
    //评论
    [self.remarkCountButton setTitle:model.remarkCount forState:UIControlStateNormal];
    [self.shareCommentCountButton setTitle:model.remarkCount forState:UIControlStateNormal];
}


#pragma mark -- super

-(void)setFrame:(CGRect)frame
{
    
    frame.size.height -= 10;
    frame.origin.y += 10;
//    [self layoutIfNeeded];
    [super setFrame:frame];
}


#pragma mark -- 底部按钮的点击

/**
 *  点击分享按钮
 *
 *  @param button button description
 */
- (void)shareBtnClick:(UIButton *)button
{
    self.shareBtnBlock();
}


//  点击评论按钮
- (void)commentBtnClck:(UIButton *)button
{
    
    self.commentBlock();

}


//  点赞
- (void)praiseBtnClick:(UIButton *)button
{
    button.selected = !button.selected;
    //发送 点赞/取消点赞 请求
    
    self.praiseBtnBlock(button.selected);
    
  
}

//取消收藏
- (void)favButtonClick:(UIButton *)btn
{
   
    self.cancelCollectBlock();
}

//删除话题分享
- (void)deleteBtnClck:(UIButton *)btn
{
    if (self.deleteBtnBlock) {
        self.deleteBtnBlock();
    }
    
}

#pragma mark -- property

-(void)setType:(EyeSubjectsControllerType)type
{
    _type = type;
    
    if (type == EyeSubjectsControllerTypeCollect) {
        [self.bottomInfoView removeFromSuperview];
        [self.sharebottomInfoView removeFromSuperview];
        [self.contentView addSubview:self.collectbottomInfoView];
        [self getButtonValue:self.model];
    }else if (type == EyeSubjectsControllerTypeShare){
        [self.bottomInfoView removeFromSuperview];
        [self.collectbottomInfoView removeFromSuperview];
        [self.contentView addSubview:self.sharebottomInfoView];
        
        
        [self getButtonValue:self.model];
    }
    
}


-(void)setModel:(EyeSubjectsModel *)model
{
    _model = model;

}


-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.layer.masksToBounds = YES;
        
        imageView.layer.cornerRadius = 45 * 0.5;
        
        [self addSubview:imageView];
        
        _iconImageView = imageView;
    }
    
    return _iconImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
        
        _nameLabel = label;
    }
    return _nameLabel;
}

-(UILabel *)addressLabel
{
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        
        [self addSubview:label];
        
        _addressLabel = label;
    }
    return _addressLabel;
}

-(UILabel *)publishTimeLabel
{
    if (!_publishTimeLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        
        
        [self addSubview:label];
        
        _publishTimeLabel = label;
    }
    return _publishTimeLabel;
}

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

-(UIView *)bottomInfoView
{
    if (!_bottomInfoView) {
        UIView *bottomView = [UIView new];
        [self addSubview:bottomView];
//        bottomView.backgroundColor = [UIColor purpleColor];
        _bottomInfoView = bottomView;
    }
    
    return _bottomInfoView;
}


-(UIButton *)viewCountButton
{
    if (!_viewCountButton) {
        
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
        [btn setImage:[UIImage imageNamed:@"find_latest_check"]forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
            
            
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.bottomInfoView addSubview:btn];
        _viewCountButton = btn;
        
        
    }
    return _viewCountButton;
}

-(UIButton *)voteCountButton
{
    if (!_voteCountButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"find_latest_praise"] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:@"find_around_praise_Click"] forState:UIControlStateSelected];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(praiseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomInfoView addSubview:btn];
        
        _voteCountButton = btn;
    }
    return _voteCountButton;
}

-(UIButton *)remarkCountButton
{
    if (!_remarkCountButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"find_latest_comment"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(commentBtnClck:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomInfoView addSubview:btn];
        
        _remarkCountButton = btn;
    }
    return _remarkCountButton;
}

-(UIButton *)shareButton
{
    if (!_shareButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"find_track_share"] forState:UIControlStateNormal];
        [btn sizeToFit];
        
        [btn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomInfoView addSubview:btn];
        
        _shareButton = btn;
    }
    return _shareButton;
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
/**
 *  收藏底部按钮视图
 *
 *  @return return value description
 */
-(UIView *)collectbottomInfoView
{
    if (!_collectbottomInfoView) {
        UIView *bottomView = [UIView new];
        [self.contentView addSubview:bottomView];
        //底部视图（装有查看评论等按钮）
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(self.mas_bottom);
            make.left.with.right.equalTo(self);
            make.height.equalTo(@(TABBARHEIGHT));
            
        }];
        
        NSArray *imageArr = @[@"find_latest_check",@"find_latest_praise",@"find_latest_comment",@"find_around_collect",@"find_share"];
        
        for (int i = 0; i < imageArr.count ; i ++) {
            
            EyeCustomBtn *customBtn = [self setupButtonFrame:CGRectMake(i * collectBtnW, 0, collectBtnW, TABBARHEIGHT) imageName:imageArr[i]];
            [bottomView addSubview:customBtn];
            
            
            if (i == 0) {
                
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                 _viewCountButton = customBtn;
            }else if (i == 1){
                //点赞
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [customBtn setImage:[UIImage imageNamed:@"find_around_praise_Click"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(praiseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                self.voteCountButton = customBtn;
                
            }else if (i == 2){
                //评论
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [customBtn addTarget:self action:@selector(commentBtnClck:) forControlEvents:UIControlEventTouchUpInside];
                
                _remarkCountButton = customBtn;
                
            }else if (i == 3){
                //收藏按钮
                [customBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
                
                [customBtn addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                customBtn.backgroundColor = [UIColor lightGrayColor];
                _favButton = customBtn;
                
            }else if (i == 4) {
                //分享
                [customBtn setTitle:@"分享" forState:UIControlStateNormal];
                [customBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [customBtn setBackgroundColor:ZYRGBColor(171, 24, 36)];
                _shareButton = customBtn;
            }
        
        }
//        bottomView.backgroundColor = [UIColor purpleColor];
        
        _collectbottomInfoView = bottomView;
    }
    
    return _collectbottomInfoView;
}
/**
 *  分享底部视图
 *
 *  @return return value description
 */
- (UIView *)sharebottomInfoView
{
    if (!_sharebottomInfoView) {
        UIView *bottomView = [UIView new];
        
        [self.contentView addSubview:bottomView];
        //底部视图（装有查看评论等按钮）
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(self.mas_bottom);
            make.left.with.right.equalTo(self);
            make.height.equalTo(@(TABBARHEIGHT));
            
        }];
        
        NSArray *imageArr = @[@"find_latest_check",@"find_latest_praise",@"find_latest_comment",@"album_average_del1"];
        for (int i = 0; i < imageArr.count ; i ++) {
            
            EyeCustomBtn *customBtn = [self setupButtonFrame:CGRectMake(i * shareBtnW, 0, shareBtnW, TABBARHEIGHT) imageName:imageArr[i]];
            [bottomView addSubview:customBtn];
            
            
            if (i == 0) {
                
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //查看
//                _viewCountButton = customBtn;
                self.shareViewCountButton = customBtn;
            }else if (i == 1){
                //点赞
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [customBtn setImage:[UIImage imageNamed:@"find_around_praise_Click"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(praiseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                self.shareVoteCountButton = customBtn;
                
            }else if (i == 2){
                //评论
                [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [customBtn addTarget:self action:@selector(commentBtnClck:) forControlEvents:UIControlEventTouchUpInside];
                
//                _remarkCountButton = customBtn;
                self.shareCommentCountButton = customBtn;
                
            }else if (i == 3){
                
                //删除
                [customBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [customBtn addTarget:self action:@selector(deleteBtnClck:) forControlEvents:UIControlEventTouchUpInside];
                [customBtn setTitle:@"删除" forState:UIControlStateNormal];
    
                [customBtn setBackgroundColor:ZYRGBColor(239, 101, 100)];
                self.delteButton = customBtn;
            }
            
        }
        
        _sharebottomInfoView = bottomView;
    }
    
    return _sharebottomInfoView;
}


#pragma mark -- Other
- (EyeCustomBtn *)setupButtonFrame:(CGRect)frame imageName:(NSString *)imageName
{
    EyeCustomBtn *customBtn = [EyeCustomBtn buttonWithType:UIButtonTypeCustom];
    customBtn.frame = frame;
//    customBtn.backgroundColor = [UIColor blackColor];
    [customBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [customBtn setTitle:@"0" forState:UIControlStateNormal];
    [customBtn addBorderLineWithColor:ZYRGBColor(209, 209, 209) borderWidth:0.5 direction:kBorderLineDirectionTop];
    return customBtn;
}

@end
