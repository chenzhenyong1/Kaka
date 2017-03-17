//
//  EyeChangeCoverControllerCell.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeChangeCoverControllerCell.h"
#import "EyeChangeSelectedPicModel.h"

@interface EyeChangeCoverControllerCell ()

/** 图片 */
@property (nonatomic, weak) UIImageView *imgView;

///** 封面选择按钮 */
//@property (nonatomic, weak) UIButton *selectedBtn;

/** 选中的model */
@property (nonatomic, strong) EyeChangeSelectedPicModel *model;
@end


@implementation EyeChangeCoverControllerCell

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
        
        make.edges.equalTo(self);
    }];
    
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.imgView);
    }];
   
}

#pragma maek -- 点击事件

- (void)selectedBtnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    self.touchBlock(self);
    self.selectedBtn.selected = YES;
    self.model.isSelected = YES;
}

#pragma mark --- public
-(void)refreshUI:(EyeChangeSelectedPicModel *)model
{
    self.imgView.image = model.image;
    self.selectedBtn.selected = model.isSelected;
    self.model = model;
}

#pragma mark -- property

//-(void)setIsSelected:(BOOL)isSelected
//{
//    if (isSelected) {
//        
//        self.selectedBtn.selected = YES;
//        
//    }else
//    {
//    
//        self.selectedBtn.selected = NO;
//    }
//}


-(UIImageView *)imgView
{
    if (!_imgView) {
        
        UIImageView *imgView = [[UIImageView alloc] init];
        
        imgView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:imgView];
        
        _imgView = imgView;
        
    }
    
    return _imgView;
}

-(UIButton *)selectedBtn
{
    if (!_selectedBtn) {
        
        UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [selectedBtn setBackgroundImage:[UIImage imageNamed:@"cover_selected"] forState:UIControlStateSelected];
        
        [selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _selectedBtn = selectedBtn;
        
        [self.imgView addSubview:selectedBtn];
    }
    
    return _selectedBtn;
}

@end
