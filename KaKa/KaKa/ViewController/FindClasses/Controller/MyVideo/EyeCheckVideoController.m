//
//  EyeCheckVideoController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeCheckVideoController.h"
#import "EyeDetailInfoCell.h"
#import "EyePlayView.h"
@interface EyeCheckVideoController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;


@property (nonatomic, strong) EyePlayView *playView;

/** 文字高度  */
@property (nonatomic, assign) CGFloat textH;
@end

@implementation EyeCheckVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"浏览";
    
    self.view.backgroundColor = ZYGlobalBgColor;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
}

- (void)back
{
    [self.playView pause];
    [self.playView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.playView insertSubview:self.videoCoverImageView belowSubview:self.playView.subviews[self.playView.subviews.count - 1]];
    [self tableView];
    [self setupNavBar];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  1 ;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
        
    EyeDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeDetailInfoCell"];
    
    cell.mood = self.mood;
    
    [cell refreshCheckUI:self.addressModel];
        
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 10 + 45 + 10 + self.textH + 10;
    
}

#pragma mark -- property

-(CGFloat)textH
{
    if (!_textH) {
        
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(kScreenWidth - 20 , MAXFLOAT);
        CGFloat textH = [self.mood boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
        
        _textH = textH;
    }
    
    return _textH;
    
}

-(void)setCoverImage:(UIImage *)coverImage
{
    _coverImage = coverImage;
    
    self.videoCoverImageView.image = coverImage;
}


- (EyePlayView *)playView {
    if (!_playView){
        _playView = [[EyePlayView alloc] initWithFrame:CGRectMake(0, 75 + self.textH, kScreenWidth, kScreenWidth * 9/16)];
        
        if (self.videoPath) {
            
            NSURL *videoFileUrl = [NSURL fileURLWithPath:self.videoPath];
            [_playView refreshUIWithMovieResouceUrl:videoFileUrl showImage:[UIImage imageNamed:@"find_breakRules_play"]];
            _playView.musicName = self.musicName;
            _playView.playTapCount++;
             _playView.player.volume = self.mute ? 0 : 1;
            //点击视频画面的时候，隐藏封面
            __weak typeof (self) weakSelf = self;
            _playView.touchBlock = ^{
                
                weakSelf.videoCoverImageView.hidden = YES;
            };
            
        }
        _playView.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:_playView];
    }
    return _playView;
}



//视频封面
-(UIImageView *)videoCoverImageView
{
    if (!_videoCoverImageView) {
        
        UIImageView *videoCoverImageView = [UIImageView new];
        
        videoCoverImageView.image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:1.0/30];
        
        videoCoverImageView.frame = self.playView.bounds;
        
        [self.playView insertSubview:videoCoverImageView belowSubview:self.playView.subviews[self.playView.subviews.count - 1]];
        
        _videoCoverImageView = videoCoverImageView;
        
        
        
    }
    
    return _videoCoverImageView;
}


-(UITableView *)tableView
{
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:tableView];
        //注册cell
        [tableView registerClass:[EyeDetailInfoCell class] forCellReuseIdentifier:@"EyeDetailInfoCell"];
                //约束
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(@(75 + self.textH + 10));
            
        }];
        
        _tableView = tableView;
        
    }
    
    return _tableView;
}



@end
