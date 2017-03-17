//
//  EyePopView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/20.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyePopMenu.h"


@interface EyePopMenu ()
/** 具体显示的内容 */
@property (nonatomic, strong) UIView *contentView;
/** 最底部的遮盖：屏蔽除菜单以外的控件的事件 */
@property (nonatomic, weak) UIButton *cover;
/** 容器：容纳具体要显示的内容 */
@property (nonatomic, weak) UIImageView *container;
@end


@implementation EyePopMenu

#pragma mark - 初始化方法
- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        /** 添加菜单内部的2个子控件 */
        // 添加一个遮盖按钮
        UIButton *cover = [[UIButton alloc] init];
        cover.backgroundColor = [UIColor clearColor];
        [cover addTarget:self action:@selector(coverClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cover];
        self.cover = cover;
        
        // 添加带箭头的菜单图片
        UIImageView *container = [[UIImageView alloc] init];
        container.userInteractionEnabled = YES;
#warning 补充图片
        container.image = [UIImage resizeImage:@"find_pop"];
        [self addSubview:container];
        self.container = container;
    }
    return self;
}

- (instancetype) initWithContentView:(UIView *)contentView
{
    if (self = [super init]) {
        self.contentView = contentView;
    }
    return self;
}

+ (instancetype) popMenuWithContentView:(UIView *)contentView
{
    return [[self alloc] initWithContentView:contentView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cover.frame = self.bounds;
}



#pragma mark - 内部方法
- (void)coverClick
{
    [self dismiss];
}

#pragma mark - 公共方法

-(void)setDimBackground:(BOOL)dimBackground
{
    _dimBackground = dimBackground;
    
    if (dimBackground) {
        self.cover.backgroundColor = [UIColor blackColor];
        self.cover.alpha = 0.3;
    }else {
    
        self.cover.backgroundColor = [UIColor clearColor];
        self.cover.alpha = 1.0;
    }
    
    
}

-(void)setBackground:(UIImage *)backgroundImage
{
    self.container.image = backgroundImage;
}

-(void)showInRect:(CGRect)rect
{
    // 添加菜单整体到窗口上
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
    
    //设置容器的frame
    self.container.frame = rect;
    [self.container addSubview:self.contentView];
    // 设置容器里面内容的frame
    CGFloat topMargin = 8;
    
    self.contentView.y = topMargin;
    self.contentView.x = 0;
    self.contentView.width = self.container.width;
    self.contentView.height = self.container.height - topMargin ;
}

- (void)dismiss
{
    [self removeFromSuperview];
}

@end
