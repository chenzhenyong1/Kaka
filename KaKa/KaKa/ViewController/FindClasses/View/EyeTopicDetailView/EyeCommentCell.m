//
//  EyeCommentCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeCommentCell.h"
#import "InteractList.h"

@interface EyeCommentCell ()

/** 头像 */
@property (nonatomic, weak) UIImageView *iconImageView;
/** 姓名 */
@property (nonatomic, weak) UILabel *nameLabel;

/** 发表时间 */
@property (nonatomic, weak) UILabel *publishTimeLabel;
/** 评论 */
@property (nonatomic, weak) UILabel *commentLabel;
/** 分割线 */
@property (nonatomic, weak) UIView *lineView;
/** 评论按钮 */
@property (nonatomic, weak) UIButton *commentBtn;

@end



@implementation EyeCommentCell

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
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.with.top.equalTo(self).offset(10);
        
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        
        make.top.equalTo(self.iconImageView.mas_top);
        
    }];
    
    [self.publishTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.nameLabel.mas_left);
        
        make.bottom.equalTo(self.iconImageView.mas_bottom);
        
    }];
    
    [self.floorNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self).offset(-10);
        
        make.top.equalTo(self).offset(10);
    }];
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_left);
        
        make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
        
        make.right.equalTo(self.floorNumLabel.mas_right);
        
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.bottom.equalTo(self).offset(-10);
        
    }];
    
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self);
        
        make.bottom.equalTo(self).offset(-1);
        
        make.height.equalTo(@1);
        
    }];
    
}


#pragma mark -- public


-(void)refreshUI:(InteractList *)interactList
{

    //头像
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:interactList.actorPortraitUrl] placeholderImage:[UIImage imageNamed:@"default_header"]];
  
    self.nameLabel.text = interactList.actorNickName;
    
    self.publishTimeLabel.text = interactList.actTime;
    

    if (interactList.replyToNickName) {
        
        NSString *string = [NSString stringWithFormat:@"回复 %@ %@",interactList.replyToNickName ,interactList.shortText];
        // 创建对象.
        NSMutableAttributedString *mAttStri = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange range = [string rangeOfString:interactList.replyToNickName];
        
        [mAttStri addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        self.commentLabel.attributedText = mAttStri;
        
    }else{
        
        self.commentLabel.text = interactList.shortText;
    }


}



#pragma mark -- property

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
        label.textColor = ZYRGBColor(239, 183, 135);
        [self addSubview:label];
        
        _nameLabel = label;
    }
    return _nameLabel;
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
-(UILabel *)floorNumLabel
{
    if (!_floorNumLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        
        
        [self addSubview:label];
        
        _floorNumLabel = label;
    }
    return _floorNumLabel;
}

-(UILabel *)commentLabel
{
    if (!_commentLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor darkGrayColor];
        label.numberOfLines = 0;
        
        [self addSubview:label];
        
        _commentLabel = label;
    }
    return _commentLabel;

}

-(UIView *)lineView
{
    if (!_lineView) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.alpha = 0.3;
        [self.contentView addSubview:lineView];
        
        _lineView = lineView;
    }
    
    return _lineView;
}

-(UIButton *)commentBtn
{
    if (!_commentBtn) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"find_latest_comment"] forState:UIControlStateNormal];
        [btn sizeToFit];
        
        [self.contentView addSubview:btn];
        
        _commentBtn = btn;
    }
    return _commentBtn;
}

@end
