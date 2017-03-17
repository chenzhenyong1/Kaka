//
//  EyeAroundDetailScrollView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAroundDetailScrollView.h"
#import "MediaList.h"
#import "EyePlayView.h"
#import "EyeMediaAccessModel.h"


@interface EyeAroundDetailScrollView ()<UIScrollViewDelegate>

/** UIScrollView */
@property (nonatomic, strong) UIScrollView *scrollView;

/** cell的视频播放器 */
@property (nonatomic, strong) EyePlayView *playView;

@end

@implementation EyeAroundDetailScrollView

+(instancetype)detailScrollView
{
    return [[self alloc] init];
}
/**
 *  布局子控件
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置scrollView的frame
    self.scrollView.frame = self.bounds;
    
    // 获得scrollview的尺寸
    CGFloat scrollW = self.scrollView.width;
    CGFloat scrollH = self.scrollView.height;
    
    // 设置内容大小
    self.scrollView.contentSize = CGSizeMake(self.mediaListArr.count * scrollW, 0);
    
    // 设置所有View的frame
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIView *view = self.scrollView.subviews[i];
        view.frame = CGRectMake(i * scrollW, 0, scrollW, scrollH);
        
        MediaList *mediaList = self.mediaListArr[i];
        
        //播放按钮
        //如果是视频类型,加个播放按钮
        if ([mediaList.mediaType isEqualToString:@"v"]) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"find_videoPlay"] forState:UIControlStateNormal];
            [btn sizeToFit];
            
            [view addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.equalTo(view.mas_top).offset(kScreenWidth * 9/16 * 0.5);
                make.centerX.equalTo(view.mas_centerX);
            }];
            //把要传递的mediaId放到btn.titleLabel里
            btn.titleLabel.text = mediaList.mediaId;
            
            [btn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }

        
        
        for (int i = 0; i < view.subviews.count; i ++) {
            
            UIImageView *imageView = view.subviews[0];
            UITextView *textView = view.subviews[1];
            //封面
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.top.equalTo(view.mas_top);
                
                make.left.right.equalTo(view);
                
                make.height.equalTo(@(kScreenWidth * 9/16));
                
//                make.width.equalTo(view.mas_width);
                
            }];
            //话题文本
            [textView mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.left.equalTo(view).offset(10);
                
                make.top.equalTo(imageView.mas_bottom).offset(10);
                
                make.right.equalTo(view).offset(-10);
                
                make.bottom.equalTo(view.mas_bottom);
                
            }];
            
            
        }
        
    }
    
}

/**
 *  点击播放按钮
 *
 *  @param btn btn description
 */
- (void)playBtnClick:(UIButton *)btn
{
    UIView *view = [btn superview];
    
    [view addSubview:self.playView];
    //添加播放器
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(view);
        
        make.centerY.equalTo(btn.mas_centerY);
        
        make.height.equalTo(@(kScreenWidth * 9/16));
    }];
    //请求媒体访问授权(btn.titleLabel.text 是媒体ID)
    [self acquireMediaAccess:btn.titleLabel.text];
}

/**
 *  请求媒体访问授权
 */
- (void)acquireMediaAccess:(NSString *)mediaID
{
    
    //1.参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"mediaId"] = mediaID;
    params[@"access"] = @"play";
    
    [HttpTool post:MediaAccess_URL params:params success:^(id responseObj) {
        
        ZYLog(@"MediaAccess_URL = %@",responseObj);
        EyeMediaAccessModel *model = [EyeMediaAccessModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        [self playMovie:model];;
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
}
-(void)playMovie: (EyeMediaAccessModel *) model{
    
    [self.playView refreshUIWithMovieResouceUrl:[NSURL URLWithString:model.url] showImage:[UIImage imageNamed:@"find_videoPlay"]];
    
    self.playView.musicName = model.backgroundMusic;
    if ([model.mute boolValue]) {//是否静音
        
        self.playView.player.volume = 0;
    }

    
    
}

#pragma mark - setter方法的重写

-(void)setMediaListArr:(NSArray *)mediaListArr
{
    _mediaListArr = mediaListArr;
    // 让subviews数组中的所有对象都执行removeFromSuperview方法
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < mediaListArr.count; i ++) {
        
        MediaList *mediaList = mediaListArr[i];
        // 把图片和话题文字放到此View
        UIView *view = [[UIView alloc] init];
        
        [self.scrollView addSubview:view];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        if ([self.subjectKind integerValue]== 4) {//如果是轨迹
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
        }else
        {
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.clipsToBounds = NO;
        }
        
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:mediaList.thumbUrl] placeholderImage:[UIImage imageNamed:@"bg_loadimg_fail"]];
        
        [view addSubview:imageView];
       
        
        
        UITextView *textView = [[UITextView alloc] init];
        textView.font = [UIFont systemFontOfSize:14];
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor whiteColor];
        textView.editable = NO;
        textView.bounces = NO;
        
        
        textView.text = mediaList.shortText;
        [view addSubview:textView];
    }
    
    if (self.trackListArr.count) {
        
        MediaList *mediaList = self.mediaListArr[0];
        
        TrackList *tracklist = self.trackListArr[[mediaList.attachToTrackSeqNum integerValue]];
        self.aroundDetailBlock(tracklist);
        
    }
    
    
    
    [self layoutIfNeeded];
}

#pragma mark --UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.trackListArr.count) {
        
        int index = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
        
       
        MediaList *mediaList = self.mediaListArr[index];
        
        TrackList *tracklist = self.trackListArr[[mediaList.attachToTrackSeqNum integerValue]];
        self.aroundDetailBlock(tracklist);
    
    }
    
    
//    ZYLog(@"tracklist.lon = %@",tracklist.seqNum);
//    for (TrackList *tracklist in self.trackListArr) {
//        ZYLog(@"tracklist.lon = %@",tracklist.lon);
//    }
}

- (void)deleteAndPause
{
    if (self.playView) {
        [self.playView pause];
        [self.playView removeFromSuperview];
    }
}


#pragma mark -- property

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

-(EyePlayView *)playView
{
    if (!_playView) {
        _playView = [[EyePlayView alloc] init];
        
//        [self addSubview:_playView];
    }
    
    return _playView;
}


@end
