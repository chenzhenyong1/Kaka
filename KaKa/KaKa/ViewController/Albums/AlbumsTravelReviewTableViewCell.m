//
//  AlbumsTravelReviewTableViewCell.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/30.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelReviewTableViewCell.h"
#import "UIView+addBorderLine.h"
#import "AlbumsTravelReviewHourModel.h"

@implementation AlbumsTravelReviewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(104*PSDSCALE_X, 10*PSDSCALE_Y, 2*PSDSCALE_X, 60*PSDSCALE_Y)];
//        line1.backgroundColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:line1];
//        
//        UILabel *time1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70*PSDSCALE_Y, 91*PSDSCALE_X, 32*PSDSCALE_Y)];
//        time1.text = @"12:00";
//        time1.textAlignment = NSTextAlignmentRight;
//        time1.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
//        time1.textColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:time1];
//        
//        UIView *point1 = [[UIView alloc] initWithFrame:CGRectMake(100*PSDSCALE_X, VIEW_H_Y(line1)+10*PSDSCALE_Y, 10*PSDSCALE_X, 10*PSDSCALE_Y)];
//        point1.layer.masksToBounds = YES;
//        point1.layer.cornerRadius = 5*PSDSCALE_Y;
//        point1.backgroundColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:point1];
//        
//        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(104*PSDSCALE_X, VIEW_H_Y(point1)+10*PSDSCALE_Y, 2*PSDSCALE_X, 120*PSDSCALE_Y)];
//        line2.backgroundColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:line2];
//        
//        
//        UILabel *time2 = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(time1)+120*PSDSCALE_Y, 91*PSDSCALE_X, 32*PSDSCALE_Y)];
//        time2.text = @"15:00";
//        time2.textAlignment = NSTextAlignmentRight;
//        time2.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
//        time2.textColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:time2];
//        
//        UIView *point2 = [[UIView alloc] initWithFrame:CGRectMake(100*PSDSCALE_X, VIEW_H_Y(line2)+10*PSDSCALE_Y, 10*PSDSCALE_X, 10*PSDSCALE_Y)];
//        point2.layer.masksToBounds = YES;
//        point2.layer.cornerRadius = 5*PSDSCALE_Y;
//        point2.backgroundColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:point2];
//        
//        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(104*PSDSCALE_X, VIEW_H_Y(point2)+10*PSDSCALE_Y, 2*PSDSCALE_X, 60*PSDSCALE_Y)];
//        line3.backgroundColor = RGBSTRING(@"777777");
//        [self.contentView addSubview:line3];
//        
//        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(point1)+20*PSDSCALE_X, 20*PSDSCALE_Y, 620*PSDSCALE_X, 134*PSDSCALE_Y)];
//        [btn1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 385*PSDSCALE_Y)];
//        [btn1 setImage:GETYCIMAGE(@"albums_youji_bg") forState:UIControlStateNormal];
//        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(235*PSDSCALE_X, 50*PSDSCALE_Y, 320*PSDSCALE_X, 35*PSDSCALE_Y)];
//        lab.text = @"共5张图片";
//        lab.textAlignment = NSTextAlignmentRight;
//        lab.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
//        lab.textColor = RGBSTRING(@"333333");
//        [btn1 addSubview:lab];
//        UIImageView *jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(lab)+16*PSDSCALE_X, 50*PSDSCALE_Y, 17*PSDSCALE_X, 30*PSDSCALE_Y)];
//        jiantou.image = GETYCIMAGE(@"albums_jiantou");
//        [btn1 addSubview:jiantou];
//        [btn1 addTarget:self action:@selector(btn_click_action) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:btn1];
//        
//        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(point1)+20*PSDSCALE_X, VIEW_H_Y(btn1)+16*PSDSCALE_Y, 620*PSDSCALE_X, 134*PSDSCALE_Y)];
//        [btn2 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 385*PSDSCALE_Y)];
//        [btn2 setImage:GETYCIMAGE(@"albums_youji_bg") forState:UIControlStateNormal];
//        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(235*PSDSCALE_X, 50*PSDSCALE_Y, 320*PSDSCALE_X, 35*PSDSCALE_Y)];
//        lab1.text = @"共5张图片";
//        lab1.textAlignment = NSTextAlignmentRight;
//        lab1.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
//        lab1.textColor = RGBSTRING(@"333333");
//        [btn2 addSubview:lab1];
//        UIImageView *jiantou1 = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(lab1)+16*PSDSCALE_X, 50*PSDSCALE_Y, 17*PSDSCALE_X, 30*PSDSCALE_Y)];
//        jiantou1.image = GETYCIMAGE(@"albums_jiantou");
//        [btn2 addSubview:jiantou1];
//        [btn2 addTarget:self action:@selector(btn_click_action) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:btn2];
    }
    
    return self;
}

- (void)setDataSource:(NSArray *)dataSource {
    
    _dataSource = dataSource;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        AlbumsTravelReviewTableViewCellSubview *subview = [[AlbumsTravelReviewTableViewCellSubview alloc] initWithFrame:CGRectMake(0, 20 * PSDSCALE_Y + i * 150 * PSDSCALE_Y, SCREEN_WIDTH, 150 * PSDSCALE_Y)];
        subview.cameraMac = self.cameraMac;
        subview.model = [_dataSource objectAtIndex:i];
        subview.tag = i + 1;
        subview.delegate = self;
        [self.contentView addSubview:subview];
    }
}

#pragma mark - AlbumsTravelReviewTableViewCellSubviewDelegate
- (void)didClickBtnWithModel:(AlbumsTravelReviewHourModel *)model {
    
    if (_delegate && [_delegate respondsToSelector:@selector(btn_clickWithModel:)]) {
        [_delegate btn_clickWithModel:model];
    }
}


@end
