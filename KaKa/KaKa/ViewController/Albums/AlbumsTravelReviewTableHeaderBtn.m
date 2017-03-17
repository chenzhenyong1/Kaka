//
//  AlbumsTravelReviewTableHeaderBtn.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/30.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelReviewTableHeaderBtn.h"

@interface AlbumsTravelReviewTableHeaderBtn ()

@end

@implementation AlbumsTravelReviewTableHeaderBtn

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, (self.frame.size.height - 25) / 2, 25, 25)];
    _leftImageView.image = GETNCIMAGE(@"albums_travel_start_icon.png");
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_leftImageView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(_leftImageView) + 6, 0, SCREEN_WIDTH - (VIEW_W_X(_leftImageView) + 6) - 45, self.frame.size.height)];
    _textLabel.text = @"2016-06-07";
    _textLabel.textColor = RGBSTRING(@"333333");
    _textLabel.font = [UIFont systemFontOfSize:28 * FONTCALE_Y];
    [self addSubview:_textLabel];
    
    UIImage *arrowImage = GETNCIMAGE(@"albums_travel_bottom_arrow.png");
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 14 - arrowImage.size.width, (self.frame.size.height - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
    _arrowImageView.image = arrowImage;
    _arrowImageView.highlightedImage = GETNCIMAGE(@"albums_travel_top_arrow.png");
    [self addSubview:_arrowImageView];
    
}

- (void)setIsStartAndEndSame:(BOOL)isStartAndEndSame {
    /// 如果开始和结束在同一天的，开始和结束图标在同一列
    _isStartAndEndSame = isStartAndEndSame;
    
    UIImageView *endImageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(_leftImageView) + 6, (self.frame.size.height - 25) / 2, 25, 25)];
    endImageView.image = GETNCIMAGE(@"albums_travel_end_icon.png");
    endImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:endImageView];
    
    _textLabel.frame = CGRectMake(VIEW_W_X(endImageView) + 6, 0, SCREEN_WIDTH - (VIEW_W_X(endImageView) + 6) - 45, self.frame.size.height);
}

@end
