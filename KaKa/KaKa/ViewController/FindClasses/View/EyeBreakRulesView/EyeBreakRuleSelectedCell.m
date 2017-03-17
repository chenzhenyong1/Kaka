//
//  BreakRuleSelectedCell.m
//  Test
//
//  Created by Jim on 16/7/27.
//  Copyright © 2016年 JIm. All rights reserved.
//

#import "EyeBreakRuleSelectedCell.h"

#import "EyeBreakRuleModel.h"
#import "EyeSelectButton.h"

@interface EyeBreakRuleSelectedCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) EyeSelectButton *bigCarBtn;
@property (nonatomic, weak) EyeSelectButton *smallCarBtn;

@property (nonatomic, weak) UIButton *lastSelectedBtn;

@end

@implementation EyeBreakRuleSelectedCell

#pragma mark -- life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor whiteColor];
        [self configureLayout];
        self.lastSelectedBtn = self.smallCarBtn;
    }
    return self;
}


- (void)configureLayout{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(13);
    }];
    
    [self.smallCarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    [self.bigCarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.smallCarBtn.mas_left).offset(-10);
    }];
}

#pragma mark -- events
- (void)btnDidClick:(UIButton *)btn{
    
    if (btn == self.lastSelectedBtn) {
        return;
    }
    
    btn.selected = YES;
    self.lastSelectedBtn.selected = NO;
    self.lastSelectedBtn = btn;
    
    if (btn == self.smallCarBtn) {
        self.btnClickBlock(EyeBreakRuleSelectedCellButtonClickRight);
    }else if (btn == self.bigCarBtn){
    
        self.btnClickBlock(EyeBreakRuleSelectedCellButtonClickLeft);
    }
}

#pragma mark -- public
- (void)refreshUIWithModel:(EyeBreakRuleModel *)model{
    self.titleLabel.text = model.title;
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

- (EyeSelectButton *)bigCarBtn {
    if (!_bigCarBtn){
        EyeSelectButton *bigCarBtn = [[EyeSelectButton alloc] init];
        [bigCarBtn setTitle:@"大车" forState:UIControlStateNormal];
        [bigCarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bigCarBtn setImage:[UIImage imageNamed:@"find_breakRules_blackCire"] forState:UIControlStateNormal];
        [bigCarBtn setImage:[UIImage imageNamed:@"find_breakRules_redCircle"] forState:UIControlStateSelected];
        
        bigCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        
        [bigCarBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:bigCarBtn];
        _bigCarBtn = bigCarBtn;
    }
    return _bigCarBtn;
}

- (EyeSelectButton *)smallCarBtn {
    if (!_smallCarBtn){
        EyeSelectButton *smallCarBtn = [[EyeSelectButton alloc] init];
        [smallCarBtn setTitle:@"小车" forState:UIControlStateNormal];
        [smallCarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [smallCarBtn setImage:[UIImage imageNamed:@"find_breakRules_blackCire"] forState:UIControlStateNormal];
        [smallCarBtn setImage:[UIImage imageNamed:@"find_breakRules_redCircle"] forState:UIControlStateSelected];
        
        [smallCarBtn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        smallCarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        smallCarBtn.selected = YES;
        
        [self addSubview:smallCarBtn];
        _smallCarBtn = smallCarBtn;
    }
    return _smallCarBtn;
}

@end
