//
//  EyeBreakRuleTextFieldCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/13.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBreakRuleTextFieldCell.h"
#import "EyeBreakRuleModel.h"

@interface EyeBreakRuleTextFieldCell ()<UITextFieldDelegate>

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIImageView *rightArrowImageView;

@end


@implementation EyeBreakRuleTextFieldCell

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
    }];
    
    [self.rightArrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-13);
    }];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.rightArrowImageView.mas_left).offset(-10);
//        make.width.equalTo(@100);
    }];
}

// 不显示右边箭头的
- (void)updateLayout{
    [self.rightArrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [self.rightArrowImageView removeFromSuperview];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-10);
    }];
}
#pragma mark -- public
- (void)refreshUIWithModel:(EyeBreakRuleModel *)model{
    self.titleLabel.text = model.title;
    self.textField.placeholder = model.des;
}

- (void)isShowRightArrow:(BOOL)show{
    if (show){
        [self configureLayout];
    }else{
        [self updateLayout];
    }
}

#pragma mark -- UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
   
    self.textfieldBlock(textField.text);

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

- (UITextField *)textField {
    if (!_textField){
        UITextField *textField = [[UITextField alloc] init];
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:12];
        textField.delegate = self;
        [self addSubview:textField];
        _textField = textField;
    }
    return _textField;
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
