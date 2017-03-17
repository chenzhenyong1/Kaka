//
//  EyeTextView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeTextView.h"


@interface EyeTextView()
@property(nonatomic, weak)UILabel *placeholderLabel;
@end

@implementation EyeTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //添加一个显示占位文字的Label
        UILabel *placeholderLabel = [[UILabel alloc]init];
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.numberOfLines = 0;
        [self addSubview:placeholderLabel];
        
        self.placeholderLabel = placeholderLabel;
        
        //设置占位文字颜色
        self.placeholderColor = [UIColor lightGrayColor];
        //设置默认字体
        self.font = [UIFont systemFontOfSize:15];
        
        //设置监听通知，不要设置自己的代理为本身
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

/**
 *  移除通知监听
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  文字内容改变时调用的方法
 */
- (void)textChange {
    self.placeholderLabel.hidden = (self.text.length != 0);
    
}

/**
 *  布局子控件
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat placeholderLabelX = 5;
    CGFloat placeholderLabelY = 8;
    CGFloat placeholderLabelWidth = self.width - 2 * placeholderLabelX;
    CGFloat placeholderLabelHeight = [self.placeholder boundingRectWithSize:CGSizeMake(placeholderLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeholderLabel.font}  context:nil].size.height;
    self.placeholderLabel.frame = CGRectMake(placeholderLabelX, placeholderLabelY, placeholderLabelWidth, placeholderLabelHeight);
    
}

- (void)setPlaceholder:(NSString *)placeholder {
    
    //copy策略的话setter应该这样写
    _placeholder = [placeholder copy];
    self.placeholderLabel.text = placeholder;
    //由于字符数变化，需要重新布局
    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = font;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self textChange];
}

@end
