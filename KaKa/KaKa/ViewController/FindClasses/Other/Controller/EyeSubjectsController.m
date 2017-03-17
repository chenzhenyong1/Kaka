//
//  EyeSubjectsController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSubjectsController.h"
#import "EyeLatestCell.h"
#import "EyeTopicDetailController.h"
#import "EyeLatestModel.h"

#import "ThumbList.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ColumnBrief.h"
#import "EyeMediaAccessModel.h"
#import "InteractList.h"//话题交互模型
#import "EyeCommentController.h"//话题评论控制器
#import "MeCollectViewControllerTableViewCell.h"
#import "TMCache.h"
#import "EyeAudioTool.h"

/** 每页话题数量  */
#define pageSize 10


@interface EyeSubjectsController ()<UITableViewDelegate,UITableViewDataSource>

/** 收藏列表数据源 */
@property (nonatomic, strong) NSMutableArray *collectDataArr;

/** 查询的记录数  */
@property (nonatomic, assign) NSUInteger recordCount;

/** 每页话题数量  */
//@property (nonatomic, assign) NSInteger pageSize;

/** 页的序号  */
@property (nonatomic, assign) NSInteger pageIndex;

/** 页的总数  */
@property (nonatomic, assign) NSUInteger pageNum;

/** 点击取消点赞的标注  */
@property (nonatomic, strong) NSIndexPath *indexPath;


/** 视频背景音乐 */
@property (nonatomic, copy) NSString *backgroundMusic;



@end

@implementation EyeSubjectsController


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.playView.musicName) {
        
        [EyeAudioTool stopMusicWithMusicName:self.playView.musicName];
        
    }
    
    if (self.playView.player.currentItem)
    {
//        [self.playView.player.currentItem removeObserver:self.playView forKeyPath:@"status"];
        [self.playView removeFromSuperview];
    }
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    if (self.playView.player.currentItem)
//    {
//        [self.playView.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加刷新控件
    [self setupRefresh];
    //最新页面里取缓存数据
    if (self.type == EyeSubjectsControllerTypeLatest) {
    
        [self loadDataFromCache];
        [NotificationCenter addObserver:self selector:@selector(loadNewLatestData) name:@"deleteSubjectNotification" object:nil];
    }
    
    [self.tableView.mj_header beginRefreshing];
    
    
    
}


/**
 *  最新页面里取缓存数据
 */
- (void)loadDataFromCache
{
    if (self.type == EyeSubjectsControllerTypeLatest) {
        [[TMCache sharedCache] objectForKey:@"latestDataArr"
                                      block:^(TMCache *cache, NSString *key, id object) {
                                          
                                          //通知主线程刷新
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              //回调或者说是通知主线程刷新，  
                                              self.latestDataArr = (NSMutableArray *)object;
                                              
                                              [self.tableView reloadData];
                                          });
                                          
                                          
                                      }];
    }
}

/**
 *  添加刷新控件
 */
- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewLatestData)];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreLatestData)];
}


#pragma mark -- 下载数据
- (void)loadNewLatestData
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"recordCountOnly"] = @"true";
    if (self.type == EyeSubjectsControllerTypeMore) {
        params[@"columnId"] = self.columnBrief.ID;
    }else if (self.type == EyeSubjectsControllerTypeCollect){//收藏
        params[@"collectedBy"] = self.collectedBy;
    }else if (self.type == EyeSubjectsControllerTypeShare){//分享
        params[@"issuedBy"] = self.issuedBy;
    }
    [HttpTool get:Subjects_URL params:params success:^(id responseObj) {
        
        NSString *recordCount = responseObj[@"result"][@"recordCount"];
        
        self.recordCount = [recordCount integerValue];
        
        if (self.recordCount % pageSize != 0) {
            
            self.pageNum = self.recordCount / pageSize == 0 ? 1 : self.recordCount / pageSize + 1;
        }else{
            self.pageNum = self.recordCount / pageSize;
        }
        // 取最新话题数据
        [self loadLatestData];
        
        
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
    }];
    
}
/**
 *  刷新第一页数据
 */
- (void)loadLatestData
{
    
    self.pageIndex = 1;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"pageSize"] = [NSString stringWithFormat:@"%d",pageSize];
    params[@"pageIndex"] = [NSString stringWithFormat:@"%ld",(long)self.pageIndex];
    if (self.type == EyeSubjectsControllerTypeMore) {//更多
        params[@"columnId"] = self.columnBrief.ID;
    }else if (self.type == EyeSubjectsControllerTypeCollect){//收藏
        params[@"collectedBy"] = self.collectedBy;
    }else if (self.type == EyeSubjectsControllerTypeShare){//分享
        params[@"issuedBy"] = self.issuedBy;
    }
    [HttpTool get:Subjects_URL params:params success:^(id responseObj) {
        
        NSArray *latestDataArr = [EyeLatestModel mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"recordList"]];
        
        
        if (self.type == EyeSubjectsControllerTypeCollect) {
            //清楚所有的旧数据
            [self.collectDataArr removeAllObjects];
            //再添加新数据
            [self.collectDataArr addObjectsFromArray:latestDataArr];
        }else
        {
            //清楚所有的旧数据
            [self.latestDataArr removeAllObjects];
            //再添加新数据
            [self.latestDataArr addObjectsFromArray:latestDataArr];
        
        }
        //缓存最新页面
        if (self.type == EyeSubjectsControllerTypeLatest) {
            //缓存对象
            [[TMCache sharedCache] setObject:self.latestDataArr forKey:@"latestDataArr" block:nil];
        }
//         ZYLog(@"Latest_URL responseObj = %@",responseObj);
        
        //刷新数据之前暂停视频
        [self.playView pause];
        
        
        [self.tableView reloadData];
        
        //结束刷新
        [self.tableView.mj_header endRefreshing];
        // 让底部控件结束刷新
        [self checkFooterState];
        
        
        
        
    } failure:^(NSError *error) {
        
        //结束刷新
//        [self addActityText:@"检测网络链接..." deleyTime:1.0];
        [self.tableView.header endRefreshing];
        
        
        ZYLog(@"error = %@",error);
        
    }];
    
}

/**
 *  加载更多数据
 */
- (void)loadMoreLatestData
{
    
    self.pageIndex ++;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"pageSize"] = [NSString stringWithFormat:@"%d",pageSize];
    params[@"pageIndex"] = [NSString stringWithFormat:@"%ld",(long)self.pageIndex];
    if (self.type == EyeSubjectsControllerTypeMore) {
        params[@"columnId"] = self.columnBrief.ID;
    }else if (self.type == EyeSubjectsControllerTypeCollect){//收藏
        params[@"collectedBy"] = self.collectedBy;
    }else if (self.type == EyeSubjectsControllerTypeShare){//分享
        params[@"issuedBy"] = self.issuedBy;
    }
    
    
    [HttpTool get:Subjects_URL params:params success:^(id responseObj) {
        
        NSArray *latestDataArr = [EyeLatestModel mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"recordList"]];
        
       
        if (self.type == EyeSubjectsControllerTypeCollect) {
            [self.collectDataArr addObjectsFromArray:latestDataArr];
        }else
        {
             [self.latestDataArr addObjectsFromArray:latestDataArr];
        }
        
        
        
        
//        ZYLog(@"Latest_URL responseObj = %@",responseObj);
        
        //刷新数据之前暂停视频
        [self.playView pause];
        
        
        [self.tableView reloadData];
        
        // 让底部控件结束刷新
        [self checkFooterState];
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
    }];
    
}

/**
 * 时刻监测footer的状态
 */
- (void)checkFooterState{
    
    ZYLog(@"self.pageIndex = %ld ,self.pageNum = %lu",(long)self.pageIndex,(unsigned long)self.pageNum);
    
    if (self.pageIndex >= self.pageNum) {// 全部数据已经加载完毕
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        
        
        
    }else{
        
        [self.tableView.mj_footer endRefreshing];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == EyeSubjectsControllerTypeCollect) {
        return  self.collectDataArr.count;
    }
    return self.latestDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    EyeLatestCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if (cell == nil) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"EyeLatestCell"];
        
    }
    EyeLatestModel *model ;
    if (self.type == EyeSubjectsControllerTypeCollect) {
        model = self.collectDataArr[indexPath.row];
        [cell refreshUI:model];
    }else{
        model = self.latestDataArr[indexPath.row];
        [cell refreshUI:model];
    }
    
    
    
    //cell的播放按钮
    [cell.playBtn addTarget:self action:@selector(clickBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 100 + indexPath.row;
    
    //点击点赞按钮
    __weak typeof(cell) weakCell = cell;
    
    cell.praiseBtnBlock = ^(BOOL isVote){
        
        ZYLog(@"点赞按钮");
        [self voteTopic:isVote withSubjectId:model.ID success:^(id responseObj) {
            ZYLog(@"responseObj = %@",responseObj);
            NSString *voteCount = responseObj[@"result"][@"voteCount"];
            EyeLatestModel *model;
            if (weakCell.type == EyeSubjectsControllerTypeCollect) {
                model = self.collectDataArr[indexPath.row];
            }else
            {
                
                model = self.latestDataArr[indexPath.row];
            }
            
            
            model.voteCount = [NSString stringWithFormat:@"%@",responseObj[@"result"][@"voteCount"]] ;
            model.voted = responseObj[@"result"][@"voted"];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (isVote) {
                    if (weakCell.type == EyeSubjectsControllerTypeShare) {
                        
                        [weakCell.shareVoteCountButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateSelected];
                    }else
                    {
                    
                        [weakCell.voteCountButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateSelected];
                    }
                }else
                {
                    if (weakCell.type == EyeSubjectsControllerTypeShare) {
                        
                        [weakCell.shareVoteCountButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
                    }else
                    {
                        
                        [weakCell.voteCountButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
                    }
                    
                    
                    
                }
                
                
                
            });
            
            
            
        } failure:^(NSError *error) {
            ZYLog(@"error = %@",error);
        }];
    
    };
    
    //点击评论按钮的回调block
    cell.commentBlock = ^(){
        
        //跳转到评论页面
        EyeCommentController *commentCtl = [[EyeCommentController alloc] init];
        
        commentCtl.ID = model.ID;
        
        [self.navigationController pushViewController:commentCtl animated:YES];
    };
    
    cell.shareBtnBlock = ^(){
        //点击分享
        [self shareClick:self withSubjectID:model.ID title:model.title];
        
    };
    
    
    cell.cancelCollectBlock = ^(){
        
        ZYLog(@"点击取消收藏");
        
        self.indexPath= indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定取消收藏" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        
        [alert show];
       
    
    };
    
    cell.deleteBtnBlock = ^(){
        
        ZYLog(@"点击删除");
        self.indexPath= indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除分享" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        
        [alert show];
    
    };
    
    cell.type = self.type;
    
    return cell;
}
//友盟分享回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        ZYLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.type == EyeSubjectsControllerTypeCollect) {
        if (buttonIndex == 0) {//确认
            [self cancelCollectTopic];//发送取消收藏链接
        }
    }else if (self.type == EyeSubjectsControllerTypeShare)
    {
        if (buttonIndex == 0) {//确认
            [self deleteSubjectTopic];//发送删除话题链接
            ZYLog(@"删除分享");
        }
    }
}

/**
 *  发送删除话题链接
 */
- (void)deleteSubjectTopic
{
    [self addActityLoading:nil subTitle:nil];
    
    EyeLatestModel *model = self.latestDataArr[self.indexPath.row];
    
    //发送删除话题请求
    [self deleteSubjectWithSubjectId:model.ID success:^(id responseObj) {
        
        
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
        [NotificationCenter postNotificationName:@"deleteSubjectNotification" object:nil];
        
        ZYLog(@"responseObj = %@",responseObj);
        [self addActityText:@"删除成功" deleyTime:2.0];
        [self.latestDataArr removeObjectAtIndex:self.indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView reloadData];
//        [self.tableView scrollsToTop];
    } failure:^(NSError *error) {
        [self addActityText:@"网络有误，取消失败" deleyTime:0.5];
        ZYLog(@"error = %@",error);
    }];
    
}

/**
 *  发送取消收藏链接
 */
- (void)cancelCollectTopic
{
    
    [self addActityLoading:nil subTitle:nil];
    
    EyeLatestModel *model = self.collectDataArr[self.indexPath.row];
    
    //发送话题 收藏/取消收藏 请求
    [self favTopic:NO withSubjectId:model.ID success:^(id responseObj) {
        
        if (self.playView) {//如果存在有播放的视频，移出
            [self.playView removeFromSuperview];
        }
        
        
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
        ZYLog(@"responseObj = %@",responseObj);
        [self addActityText:@"取消成功" deleyTime:2.0];
        
        [self.collectDataArr removeObjectAtIndex:self.indexPath.row];
        
        [self.tableView reloadData];
        
        
    } failure:^(NSError *error) {
        
        [self addActityText:@"网络有误，取消失败" deleyTime:0.5];
        ZYLog(@"error = %@",error);
    }];
    
}



-(void)clickBtnClick:(UIButton *)btn
{
    

    NSInteger index = btn.tag - 100;
    EyeLatestCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    self.playView.frame = CGRectMake(0, cell.y + 65 , kScreenWidth, kScreenWidth * 9/16 );
    
//     ZYLog(@"index = %ld   self.playView.heigth = %f",index,model.cellHeight);
    
    self.playView.index = index;
    self.playView.hidden = NO;
    [self acquireMediaAccess];
    
}
/**
 *  请求媒体访问授权
 */
- (void)acquireMediaAccess
{
    EyeLatestModel *model;
    if (self.type == EyeSubjectsControllerTypeCollect) {
        model = self.collectDataArr[self.playView.index];
        
    }else{
        model = self.latestDataArr[self.playView.index];
    }
    ThumbList *list = model.thumbList[0];
    NSString *mediaId = list.mediaId;
    
    //1.参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"mediaId"] = mediaId;
    params[@"access"] = @"play";
    [HttpTool post:MediaAccess_URL params:params success:^(id responseObj) {
        
        ZYLog(@"MediaAccess_URL = %@",responseObj);
        EyeMediaAccessModel *model = [EyeMediaAccessModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        [self playMovie:model];
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];
}
-(void)playMovie: (EyeMediaAccessModel *) model{
    
    [self.playView refreshUIWithMovieResouceUrl:[NSURL URLWithString:model.url] showImage:[UIImage imageNamed:@"find_videoPlay"]];
    
    self.playView.musicName = model.backgroundMusic;
    if ([model.mute boolValue]) {//是否静音
        
        self.playView.player.volume = 0;
    }
//    self.playView.playTapCount = 1;
    
    
}



#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == EyeSubjectsControllerTypeCollect) {
        EyeLatestModel *model = self.collectDataArr[indexPath.row];
        
        return model.cellHeight;
    }
    EyeLatestModel *model = self.latestDataArr[indexPath.row];
    
    return model.cellHeight;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //跳转之前暂停视频

    [self.playView pause];
    
    //跳转到详细信息界面
    EyeLatestModel *model;
    if (self.type == EyeSubjectsControllerTypeCollect) {
        model = self.collectDataArr[indexPath.row];
        
    }else{
        model = self.latestDataArr[indexPath.row];
    }
    
    
    EyeTopicDetailController *detailCtl = [[EyeTopicDetailController alloc] init];
    
    detailCtl.ID = model.ID;
    
    [self.navigationController pushViewController:detailCtl animated:YES];
    
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.playView.index) {
        [self.playView pause];
    }
    
}



#pragma mark -- property
-(UITableView *)tableView
{
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] init];
        
        tableView.backgroundColor = ZYGlobalBgColor;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        //注册cell
        [tableView registerClass:[EyeLatestCell class] forCellReuseIdentifier:@"EyeLatestCell"];
       
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        _tableView = tableView;
        
    }
    
    return _tableView;
}


-(NSMutableArray *)latestDataArr
{
    if (!_latestDataArr) {
        _latestDataArr = [NSMutableArray array];
    }
    
    return _latestDataArr;
}

-(NSMutableArray *)collectDataArr
{
    if (!_collectDataArr) {
        _collectDataArr = [NSMutableArray array];
    }
    
    return _collectDataArr;
}


-(EyePlayView *)playView
{
    if (!_playView) {
        EyePlayView *playView = [[EyePlayView alloc] init];
        
        _playView = playView;
        
        [self.tableView addSubview:_playView];
    }
    
    return _playView;
}

@end
