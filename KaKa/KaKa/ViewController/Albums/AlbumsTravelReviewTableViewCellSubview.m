//
//  AlbumsTravelReviewTableViewCellSubview.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelReviewTableViewCellSubview.h"

@implementation AlbumsTravelReviewTableViewCellSubview
{
    UILabel *_timeLabel;
    UILabel *_countLabel;
    UIButton *_btn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(104*PSDSCALE_X, 0, 2*PSDSCALE_X, 60*PSDSCALE_Y)];
        line1.backgroundColor = RGBSTRING(@"777777");
        [self addSubview:line1];
        
        UILabel *time1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 58*PSDSCALE_Y, 91*PSDSCALE_X, 32*PSDSCALE_Y)];
        time1.text = @"12:00";
        time1.textAlignment = NSTextAlignmentRight;
        time1.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        time1.textColor = RGBSTRING(@"777777");
        [self addSubview:time1];
        _timeLabel = time1;
        
        UIView *point1 = [[UIView alloc] initWithFrame:CGRectMake(100*PSDSCALE_X, VIEW_H_Y(line1)+10*PSDSCALE_Y, 10*PSDSCALE_X, 10*PSDSCALE_Y)];
        point1.layer.masksToBounds = YES;
        point1.layer.cornerRadius = 5*PSDSCALE_Y;
        point1.backgroundColor = RGBSTRING(@"777777");
        [self addSubview:point1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(104*PSDSCALE_X, VIEW_H_Y(point1)+10*PSDSCALE_Y, 2*PSDSCALE_X, 60*PSDSCALE_Y)];
        line2.backgroundColor = RGBSTRING(@"777777");
        [self addSubview:line2];
        
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(point1)+20*PSDSCALE_X, 10*PSDSCALE_Y, 620*PSDSCALE_X, 134*PSDSCALE_Y)];
        [btn1 setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 385*PSDSCALE_Y)];
        [btn1 setImage:GETYCIMAGE(@"albums_youji_bg") forState:UIControlStateNormal];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(235*PSDSCALE_X, 45*PSDSCALE_Y, 320*PSDSCALE_X, 35*PSDSCALE_Y)];
        lab.text = @"共1张图片";
        lab.textAlignment = NSTextAlignmentRight;
        lab.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
        lab.textColor = RGBSTRING(@"333333");
        [btn1 addSubview:lab];
        _countLabel = lab;
        UIImageView *jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(lab)+16*PSDSCALE_X, 48*PSDSCALE_Y, 17*PSDSCALE_X, 30*PSDSCALE_Y)];
        jiantou.image = GETYCIMAGE(@"albums_jiantou");
        [btn1 addSubview:jiantou];
        [btn1 addTarget:self action:@selector(btn_click_action) forControlEvents:UIControlEventTouchUpInside];
        btn1.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn1.imageView.clipsToBounds = YES;
        [self addSubview:btn1];
        _btn = btn1;

    }
    
    return self;
}

- (void)setModel:(AlbumsTravelReviewHourModel *)model {
    
    _model = model;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSDate *date = [formatter dateFromString:_model.time];
    
    _timeLabel.text = [MyTools getDateStringWithDateFormatter:@"HH:mm" date:date];
    _countLabel.text = [NSString stringWithFormat:@"共%ld张图片", (long)_model.dataSource.count];
    
    AlbumsTravelDetailModel *datailModel = [_model.dataSource lastObject];
    // 从本地读取数据
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)datailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", datailModel.fileName]];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    [_btn setImage:image forState:UIControlStateNormal];
}

- (void)btn_click_action {
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClickBtnWithModel:)]) {
        [_delegate didClickBtnWithModel:_model];
    }
}

@end
