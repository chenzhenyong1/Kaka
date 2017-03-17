//
//  AlbumsTravelReviewTableHeaderBtn.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/30.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsTravelReviewTableHeaderBtn : UIButton

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, assign) BOOL isStartAndEndSame;// 开始和结束是否在同一天

@end
