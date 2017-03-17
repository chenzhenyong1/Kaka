//
//  EyeSquareCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/20.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSquareCell.h"
#import "ColumnOverview.h"
#import "ColumnBrief.h"
#import "ImgView.h"

@interface EyeSquareCell ()


/** 话题栏目名称 */
@property (nonatomic, weak) UIButton *titleBtn;

/** 左边缩略图片 */
@property (nonatomic, weak) UIImageView *leftImageView;

/** 右边缩略图片 */
@property (nonatomic, weak) UIImageView *rightImageView;

/** 左边图片描述 */
@property (nonatomic, copy) UILabel *leftImageDes;
/** 右边图片描述 */
@property (nonatomic, copy) UILabel *rightImageDes;

/** 更多按钮 */
@property (nonatomic, weak) UIButton *moreBtn;


@end


@implementation EyeSquareCell

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
    [self.titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.centerX.equalTo(self.mas_centerX);
        
        make.top.equalTo(self.mas_top).offset(10);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.titleBtn.mas_bottom);
        
        make.right.equalTo(self.mas_right).offset(-10);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(10);
        
        make.top.equalTo(self.titleBtn.mas_bottom).offset(10);
        
        make.height.equalTo(@(kScreenWidth * 0.3));
        
        make.right.equalTo(self.rightImageView.mas_left).offset(-10);
        
        make.width.equalTo(self.rightImageView.mas_width);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.leftImageView.mas_top);
        
        make.height.equalTo(@(kScreenWidth * 0.3));
        
        make.right.equalTo(self.mas_right).offset(-10);
        
        make.left.equalTo(self.leftImageView.mas_right).offset(10);
        make.width.equalTo(self.leftImageView.mas_width);
        
        
    }];
    
    [self.leftImageDes mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.leftImageView.mas_left);
        
        make.top.equalTo(self.leftImageView.mas_bottom).offset(10);
        
        make.right.equalTo(self.leftImageView.mas_right);
        
    }];
    
    [self.rightImageDes mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.rightImageView.mas_left);
        
        make.centerY.equalTo(self.leftImageDes.mas_centerY);
        
        make.right.equalTo(self.rightImageView.mas_right);
        
    }];
    
}

#pragma mark -- public

- (void)refreshUI:(ColumnOverview *)columnOverview
{
    self.columnOverview = columnOverview;
    
    [self.titleBtn setImage:[UIImage imageNamed:@"find_square_hotGossip"] forState:UIControlStateNormal];
    [self.titleBtn setTitle:columnOverview.columnBrief.name forState:UIControlStateNormal];
    
    NSArray *imageArr = columnOverview.imgViews;
    
    if (imageArr.count != 2) {
        self.leftImageView.image = [UIImage imageNamed:@"bg_loadimg_fail"];
        self.rightImageView.image = [UIImage imageNamed:@"bg_loadimg_fail"];
    }else
    {
    
        ImgView *leftImgView = imageArr[0];
        
        ImgView *rightImgView = imageArr[1];
        
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImgView.imgUrl] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
        
        [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImgView.imgUrl] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
        
        
        
        self.leftImageDes.text = leftImgView.subjectTitle;
        self.rightImageDes.text = rightImgView.subjectTitle;
    }
    
    
}

-(void)setColumnOverview:(ColumnOverview *)columnOverview
{
    _columnOverview = columnOverview;
}

#pragma mark -- 点击事件
/**
 *  点击左边图片
 *
 *  @param tap tap description
 */
- (void)leftImageTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(squareCellDidClick:clickEnum:)]) {
        
        [self.delegate squareCellDidClick:self clickEnum:EyeSquareCellClickImageLeft];
        
    }
}

/**
 *  点击右边图片
 *
 *  @param tap tap description
 */
- (void)rightImageTap:(UITapGestureRecognizer *)tap
{
    
    if ([self.delegate respondsToSelector:@selector(squareCellDidClick:clickEnum:)]) {
        
        [self.delegate squareCellDidClick:self clickEnum:EyeSquareCellClickImageRight];
        
    }
}


/**
 *  点击更多按钮
 *
 *  @param btn btn description
 */
- (void)moreBtnClick:(UIButton *)btn
{
   
    if ([self.delegate respondsToSelector:@selector(squareCellDidClick:clickEnum:)]) {
        
        [self.delegate squareCellDidClick:self clickEnum:EyeSquareCellClickMoreButton];
        
    }
    
}

//+(instancetype)cellWithTableView:(UITableView *)tableView
//{
//    static NSString *ID = @"EyeSquareCell";
//    EyeSquareCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil]lastObject];
//    }
//    return cell;
//}
//
//
//



#pragma mark -- properties
-(UIButton *)titleBtn
{
    if (!_titleBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.userInteractionEnabled = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn sizeToFit];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:ZYRGBColor(176, 23, 23) forState:UIControlStateNormal];
        [self addSubview:btn];
        
        _titleBtn = btn;
        
    }
    return _titleBtn;
}

-(UIImageView *)leftImageView
{
    if (!_leftImageView) {
        UIImageView *leftImageView = [[UIImageView alloc] init];
        UITapGestureRecognizer *leftImageTap = [[UITapGestureRecognizer alloc] init];
        
        leftImageView.userInteractionEnabled = YES;
        [leftImageTap addTarget:self action:@selector(leftImageTap:)];
        [leftImageView addGestureRecognizer:leftImageTap];
        
        
        [self addSubview:leftImageView];
        _leftImageView = leftImageView;
        
    }
    return _leftImageView;
}
-(UIImageView *)rightImageView
{
    if (!_rightImageView) {
        UIImageView *rightImageView = [[UIImageView alloc] init];
        
         UITapGestureRecognizer *rightImageTap = [[UITapGestureRecognizer alloc] init];
        rightImageView.userInteractionEnabled = YES;
        [rightImageTap addTarget:self action:@selector(rightImageTap:)];
        [rightImageView addGestureRecognizer:rightImageTap];
        
        [self addSubview:rightImageView];
        _rightImageView = rightImageView;
        
    }
    return _rightImageView;
}

-(UILabel *)leftImageDes
{
    if (!_leftImageDes) {
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        _leftImageDes = label;
    }
    return _leftImageDes;
}

-(UILabel *)rightImageDes
{
    if (!_rightImageDes) {
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        _rightImageDes = label;
    }
    return _rightImageDes;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"find_jump_more"] forState:UIControlStateNormal];
        [btn setTitle:@"更多" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
       
        [btn sizeToFit];
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.width, 0, -btn.width);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.width, 0, btn.imageView.width);
        
        [btn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        _moreBtn = btn;
    }
    return _moreBtn;
}

@end
