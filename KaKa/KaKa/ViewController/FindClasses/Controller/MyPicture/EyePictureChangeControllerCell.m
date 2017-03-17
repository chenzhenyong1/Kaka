//
//  EyePictureChangeControllerCell.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyePictureChangeControllerCell.h"
#import "EyePictureListModel.h"

@interface  EyePictureChangeControllerCell()

/** 图片 */
@property (nonatomic, strong) UIImageView *imgView;

/** 封面选择按钮 */
@property (nonatomic, strong) UIButton *selectedBtn;

@end


@implementation EyePictureChangeControllerCell

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


#pragma mark --- public
- (void)refreshUI:(EyePictureListModel *)model;
{
//    self.imgView.image = ;
    
    self.selectedBtn.selected = model.isSelect;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imgView.image = [UIImage imageWithData:imageData];
            
        });
    });
}

#pragma mark -- property

-(UIImageView *)imgView
{
    if (!_imgView) {
        
        _imgView = [[UIImageView alloc] init];
        
        _imgView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:_imgView];
        
    }
    
    return _imgView;
}

-(UIButton *)selectedBtn
{
    if (!_selectedBtn) {
        
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"cover_selected"] forState:UIControlStateSelected];
        [_selectedBtn setBackgroundImage:nil forState:UIControlStateNormal];
//        [_selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _selectedBtn.userInteractionEnabled = NO;
        
        [self.imgView addSubview:_selectedBtn];
    }
    
    return _selectedBtn;
}

@end
