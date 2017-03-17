//
//  BreakRuleCell.m
//  Test
//
//  Created by Jim on 16/7/27.
//  Copyright © 2016年 JIm. All rights reserved.
//

#import "EyeBreakRuleCell.h"

#import "EyeBreakRuleModel.h"

@interface EyeBreakRuleCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *desLabel;
@property (nonatomic, weak) UIImageView *rightArrowImageView;

@end

@implementation EyeBreakRuleCell

#pragma mark -- life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor whiteColor];
        [self configureLayout];
    }
    return self;
}


- (void)configureLayout{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(13);
//        make.right.equalTo(self.desLabel.mas_left).offset(-20);
    }];
    
    [self.rightArrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-13);
//        make.left.equalTo(self.desLabel.mas_right).offset(10);
    }];
    
    [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.rightArrowImageView.mas_left).offset(-10);
//        make.width.equalTo(self.mas_width).offset(self.titleLabel.width);
//        make.left.equalTo(self.titleLabel.mas_right).offset(20);
    }];
}

// 不显示右边箭头的
- (void)updateLayout{
    [self.rightArrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [self.rightArrowImageView removeFromSuperview];
    
    [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-10);
        
    }];
}

#pragma mark -- public
- (void)refreshUIWithModel:(EyeBreakRuleModel *)model{
    self.titleLabel.text = model.title;
    
    self.desLabel.text = model.des;
    self.desLabel.width = self.width * 0.5;
    
//    CGSize titleSize =[model.des boundingRectWithSize:CGSizeMake(self.width * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
//    self.desLabel.size = titleSize;
}

- (void)isShowRightArrow:(BOOL)show{
    if (show){
        [self configureLayout];
    }else{
        [self updateLayout];
    }
}

#pragma mark -- properties
- (UILabel *)titleLabel {
    if (!_titleLabel){
        UILabel *titleLbel = [[UILabel alloc] init];
        titleLbel.font = [UIFont systemFontOfSize:12];
        [self addSubview:titleLbel];
        _titleLabel = titleLbel;
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel){
        UILabel *desLabel = [[UILabel alloc] init];
        desLabel.textAlignment = NSTextAlignmentRight;
        desLabel.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:desLabel];
        _desLabel = desLabel;
    }
    return _desLabel;
}

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView){
        UIImageView *rightArrowImageView = [[UIImageView alloc] init];
        rightArrowImageView.image = [UIImage imageNamed:@"find_breakRules_rightArrow"];
        [self addSubview:rightArrowImageView];
        _rightArrowImageView = rightArrowImageView;
    }
    return _rightArrowImageView;
}

@end
