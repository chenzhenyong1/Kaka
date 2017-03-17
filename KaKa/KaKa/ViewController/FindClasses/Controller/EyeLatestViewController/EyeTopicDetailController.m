//
//  EyeTopicDetailController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/21.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeTopicDetailController.h"
#import "EyeTopicDetailCell.h"
#import "EyeCommentCell.h"
#import "EyeCustomBtn.h"
#import "EyeCommentController.h"
#import "EyeLatestModel.h"
#import "EyeSubjectDetailResultModel.h"
#import "EyeDetailInfoCell.h"
#import "EyeDetailMediaCell.h"
#import "MediaList.h"
#import "EyePlayView.h"
#import "EyeCommentCell.h"
#import "InteractList.h"
#import "Subject.h"
#import "EyeMediaAccessModel.h"
#import "TrafficViolation.h"
#import "Subject.h"


@interface EyeTopicDetailController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** 底部视图 */
@property (nonatomic, weak) UIView *bottomView;

/** 数据源 */
@property (nonatomic, strong) EyeSubjectDetailResultModel *data;

/** cell的视频播放器 */
@property (nonatomic, strong) EyePlayView *playView;
/** 查看按钮 */
@property (nonatomic, weak) EyeCustomBtn *viewButton;
/** 收藏按钮 */
@property (nonatomic, weak) EyeCustomBtn *favButton;
/** 点赞按钮 */
@property (nonatomic, weak) EyeCustomBtn *voteButton;
/** 评论按钮 */
@property (nonatomic, weak) EyeCustomBtn *commentButton;
/** 分享按钮 */
@property (nonatomic, weak) EyeCustomBtn *shareButton;

/** 话题类型 */
@property (nonatomic, copy) NSString *subjectKind;

@end

@implementation EyeTopicDetailController

//- (void)viewWillAppear:(BOOL)animated
//{
//    if (self.playView.player.currentItem)
//    {
//        [self.playView.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    }
//
//}

-(void)viewWillDisappear:(BOOL)animated
{
//    if (self.playView.player.currentItem)
//    {
//        [self.playView.player.currentItem removeObserver:self.playView forKeyPath:@"status"];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    self.view.backgroundColor = ZYGlobalBgColor;
    self.title = @"详细信息";
  
    
    [self tableView];
    
    [self bottomView];
    
    // 联网取得数据
    [self loadData];
    
}

- (void)setupNav
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  联网取得数据
 */
- (void)loadData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"subjectId"] = self.ID;
    [HttpTool get:SubjectDetail_URL params:params success:^(id responseObj) {
        
        ZYLog(@"SubjectDetail_URL responseObj = %@",responseObj);
        
        EyeSubjectDetailResultModel *model =[EyeSubjectDetailResultModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        self.data = model;
        self.subjectKind = responseObj[@"result"][@"subject"][@"subjectKind"];
        
        [self bottomButtonCount:self.data.subject];
        
        [self.tableView reloadData];
        
        // 是否发送查看
        if (![self.data.subject.viewed boolValue]) {
            //发送话题查看请求
            [self checkTopic];
        }
        //是否收藏
        if ([self.data.subject.favSet boolValue]) {
            self.favButton.selected = YES;
        }else{
            self.favButton.selected = NO;
        }
        
        //是否点赞
        if ([self.data.subject.voted boolValue]) {
            self.voteButton.selected = YES;
        }else{
            self.voteButton.selected = NO;
        }
        
        ZYLog(@"model subject = %@",model.subject);
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];


}



#pragma mark -- 底部按钮赋值
- (void)bottomButtonCount:(Subject *)subject
{
    [self.viewButton setTitle:subject.viewCount forState:UIControlStateNormal];
    [self.favButton setTitle:subject.setFavCount forState:UIControlStateNormal];
    [self.voteButton setTitle:subject.voteCount forState:UIControlStateNormal];
    [self.commentButton setTitle:subject.remarkCount forState:UIControlStateNormal];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1 + self.data.mediaList.count;
    }
    return self.data.interactList.count + 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (0 == indexPath.section) {//第一组
        
        if (0 == indexPath.row) {
            
            EyeDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeDetailInfoCell"];
            
            Subject *subject = self.data.subject;
            [cell refreshUI:subject];
            if (self.data.trafficViolation) {//如果有违章信息
                
                TrafficViolation *trafficViolation = self.data.trafficViolation;
                
                [cell refreshBreakRulesUI:trafficViolation];
            }
            
            return cell;
        }else
        {
            EyeDetailMediaCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell == nil) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EyeDetailMediaCell"];
            }
            
            MediaList *mediaList = self.data.mediaList[indexPath.row - 1];
            cell.subjectKind = self.data.subject.subjectKind;
            [cell refreshUI:mediaList];
            
            [cell.playBtn addTarget:self action:@selector(clickBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.playBtn.tag = 100 + indexPath.row;
            
            return cell;
        }
    }else//第二组
    {
        if (0 == indexPath.row) {
            
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            //        self.data.interactList.count;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = [NSString stringWithFormat:@"评论 (%lu)",[self.data.subject.remarkCount integerValue] ];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.height - 1, self.view.width, 1)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            lineView.alpha = 0.3;
            [cell.contentView addSubview:lineView];
            
            return cell;
            
        }else
        {
            EyeCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeCommentCell"];
            InteractList *interactList = self.data.interactList[indexPath.row - 1];

            cell.floorNumLabel.text = [NSString stringWithFormat:@"%lu楼",[self.data.subject.remarkCount integerValue] - indexPath.row + 1];
            
            [cell refreshUI:interactList];
            
            return cell;
        }
        
    }
    
}

/**
 *  点击播放视频
 *
 *  @param btn <#btn description#>
 */
-(void)clickBtnClick:(UIButton *)btn
{
    NSInteger index = btn.tag - 100 - 1;
    MediaList *mediaList = self.data.mediaList[index];
    
    if ([self.data.subject.subjectKind integerValue] == 5) {
        
        self.playView.frame = CGRectMake(0, mediaList.cellHeight * index + self.data.subject.cellHeight + 100 + 10, kScreenWidth, kScreenWidth * 9/16 );
        
    }else
    {
        
        self.playView.frame = CGRectMake(0, mediaList.cellHeight * index + self.data.subject.cellHeight + 10, kScreenWidth, kScreenWidth * 9/16 );
    }
    
    
    

    
    self.playView.index = index;
    self.playView.hidden = NO;
    [self acquireMediaAccess];
    
}

/**
 *  请求媒体访问授权
 */
- (void)acquireMediaAccess
{
    MediaList *mediaList = self.data.mediaList[self.playView.index];

    NSString *mediaId = mediaList.mediaId;
    
    //1.参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"mediaId"] = mediaId;
    
    ZYLog(@"mediaId = %@",mediaId);
    
    params[@"access"] = @"play";
    [HttpTool post:MediaAccess_URL params:params success:^(id responseObj) {
        
        ZYLog(@"MediaAccess_URL = %@",responseObj);
        EyeMediaAccessModel *model = [EyeMediaAccessModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        [self playMovie:model];
        
        
        
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


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 || indexPath.row == 0) {
        return;
    }
    //跳转到评论页面
    EyeCommentController *commentCtl = [[EyeCommentController alloc] init];
    
    commentCtl.ID = self.data.subject.ID;
    [self.navigationController pushViewController:commentCtl animated:YES];

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            Subject *subject = self.data.subject;
            
            if ([subject.subjectKind integerValue] == 5) {
                return subject.cellHeight + 100;
            }
            return subject.cellHeight;
        }else{
            
            MediaList *mediaList = self.data.mediaList[indexPath.row - 1];
            
             return mediaList.cellHeight;
        }
        
       
    }else if (indexPath.section == 1 && indexPath.row >= 1){
         InteractList *mediaList = self.data.interactList[indexPath.row - 1];
        return mediaList.cellHeight;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section) {
        return 10;
    }
    return 0;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark -- property

-(UITableView *)tableView
{
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.view addSubview:tableView];
        //注册cell
        [tableView registerClass:[EyeDetailInfoCell class] forCellReuseIdentifier:@"EyeDetailInfoCell"];
        [tableView registerClass:[EyeDetailMediaCell class] forCellReuseIdentifier:@"EyeDetailMediaCell"];
        [tableView registerClass:[EyeCommentCell class] forCellReuseIdentifier:@"EyeCommentCell"];
        
       
        
        //约束
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
        
        _tableView = tableView;

    }
    
    return _tableView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - NAVIGATIONBARHEIGHT - TABBARHEIGHT, self.view.width, TABBARHEIGHT)];
        bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:bottomView];
        _bottomView = bottomView;
        
        CGFloat buttonW = self.view.width / 5.0;
        CGFloat buttonH = bottomView.height;
        
        NSArray *imageArr = @[@"find_around_check",@"find_around_collect",@"find_latest_praise",@"find_latest_comment",@"find_share"];
       
        for (int i = 0; i < imageArr.count ; i ++) {
            
            EyeCustomBtn *customBtn = [self setupButtonFrame:CGRectMake(i * buttonW, 0, buttonW, buttonH) imageName:imageArr[i]];
            
            if (i == 0) {
                _viewButton = customBtn;
                
            }else if (i == 1){
                //收藏按钮
                [customBtn setImage:[UIImage imageNamed:@"ic_shouchang_press(1)"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                _favButton = customBtn;
            
            }else if (i == 2){
                //点赞
                [customBtn setImage:[UIImage imageNamed:@"find_around_praise_Click"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(voteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                _voteButton = customBtn;
            
            }else if (i == 3){
                //评论
                [customBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
                
                _commentButton = customBtn;
                
            }else if (i == 4) {
                //分享
                [customBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
                [customBtn setTitle:@"分享" forState:UIControlStateNormal];
                [customBtn setBackgroundColor:ZYRGBColor(171, 24, 36)];
                _shareButton = customBtn;
            }
            
            
            
            [bottomView addSubview:customBtn];
        }
        
    }

    return _bottomView;
}

-(EyePlayView *)playView
{
    if (!_playView) {
        _playView = [[EyePlayView alloc] init];
        
        [self.tableView addSubview:_playView];
    }
    
    return _playView;
}



#pragma mark -- 话题按钮交互事件

/**
 *  发送话题查看请求
 */
- (void)checkTopic
{
    //发送话题查看请求
    [self checkTopicWithSubjectID:self.ID success:^(id responseObj) {
        
        ZYLog(@"查看成功 responseObj = %@",responseObj);
        NSString *viewCount = responseObj[@"result"][@"viewCount"];
        
        [self.viewButton setTitle:[NSString stringWithFormat:@"%ld",[viewCount integerValue]] forState:UIControlStateNormal];
        
    } failure:^(NSError *error) {
        [self addActityText:@"请求失败,网络连接错误" deleyTime:0.5];
        ZYLog(@"发送查看请求 error = %@",error);
    }];
    

}


//点击点赞
- (void)voteButtonClick:(UIButton *)button
{
    ZYLog(@"voteButtonClick");
    
    button.selected = !button.selected;
    //发送 点赞/取消点赞 请求
    [self voteTopic:button.selected withSubjectId:self.ID success:^(id responseObj) {
        ZYLog(@"favTopic responseObj = %@",responseObj);
        NSString *voteCount = responseObj[@"result"][@"voteCount"];
        [self.voteButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        [self addActityText:@"请求失败,网络连接错误" deleyTime:0.5];
        ZYLog(@"发送 点赞/取消点赞 失败 error = %@",error);
    }];

    
}


//点击收藏
- (void)favButtonClick:(UIButton *)button
{
    ZYLog(@"favButtonClick");

    button.selected = !button.selected;
    //发送 收藏/取消收藏 请求
    [self favTopic:button.selected withSubjectId:self.ID success:^(id responseObj) {
        
        ZYLog(@"favTopic responseObj = %@",responseObj);
        NSString *voteCount = responseObj[@"result"][@"setFavCount"];
        [self.favButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
        
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
    } failure:^(NSError *error) {
        [self addActityText:@"请求失败,网络连接错误" deleyTime:0.5];
        ZYLog(@"发送 收藏/取消收藏 失败 error = %@",error);
    }];


}


//点击评论按钮
-(void)commentClick
{
    //跳转到评论页面
    EyeCommentController *commentCtl = [[EyeCommentController alloc] init];
    
    commentCtl.ID = self.data.subject.ID;
    
    [self.navigationController pushViewController:commentCtl animated:YES];
}
//点击分享
-(void)shareClick
{
    ZYLog(@"点击话题详细分享");
    [self shareClick:self withSubjectID:self.data.subject.ID title:self.data.subject.title];

}


@end
