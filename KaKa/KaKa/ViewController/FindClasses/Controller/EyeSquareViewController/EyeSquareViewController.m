//
//  EyeSquareViewController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/19.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeSquareViewController.h"
#import "ZYInfiniteScrollView.h"
#import "EyeSquareCell.h"
#import "EyeTopicDetailController.h"
#import "EyeMoreViewController.h"
#import "EyeSquareModel.h"
#import "ColumnOverview.h"
#import "ColumnBrief.h"
#import "ImgView.h"
#import "EyeAdsModel.h"
#import "TMCache.h"


@interface EyeSquareViewController ()<EyeSquareCellDelegate,UITableViewDelegate,UITableViewDataSource>


/** tableView */
@property (nonatomic, weak) UITableView *tableView;

/** 广告 */
@property (nonatomic, strong) ZYInfiniteScrollView *adsHeadView;
/** 广告数据源 */
@property (nonatomic, strong) NSArray *adsDataArr;
/** 广场栏目数组源 */
@property (nonatomic, strong) NSMutableArray *squareDataArr;

@end

@implementation EyeSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //初始化tableView
    [self setupTableView];
    
    
    //添加刷新控件
    [self setupRefresh];
    
    //缓存里去数据
    [self loadDataFromCache];
    
    [self.tableView.header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginStatusNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusNotification:) name:@"loginStatusNotification" object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadNewData) name:@"deleteSubjectNotification" object:nil];
    
    
}
/**
 *  缓存里取数据
 */
- (void)loadDataFromCache
{
    [[TMCache sharedCache] objectForKey:@"adsDataArr"
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      //通知主线程刷新
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          //回调或者说是通知主线程刷新，
                                          
                                          
                                          self.adsDataArr = (NSArray *)object;
                                          
                                          // 设置广告栏
                                          if (self.adsDataArr.count) {
                                              
                                              self.adsHeadView.dataArr = self.adsDataArr;
                                              
                                              self.tableView.tableHeaderView = self.adsHeadView;
                                          }
                                          
                                      });
                                      
                                  }];
    
    [[TMCache sharedCache] objectForKey:@"squareDataArr"
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      //通知主线程刷新
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          //回调或者说是通知主线程刷新，  
                                          self.squareDataArr =(NSMutableArray *)object;
                                          
                                          [self.tableView reloadData];
                                      });
                                  }];
}

- (void)loginStatusNotification:(NSNotification *)notification{
    if (![notification.object boolValue]) {
        
    }else{
        [self.tableView.mj_header beginRefreshing];
        [self loadAdsData];
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    ZYLog(@"EyeSquareViewController viewDidAppear ");
    [super viewDidAppear:animated];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.tableView.contentInset = UIEdgeInsetsZero;
}

/**
 *  初始化tableView
 */
- (void)setupTableView
{

    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)setupRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];

}


#pragma mark -- 联网下载数据
- (void)loadNewData
{
    //下载广告数据
    [self loadAdsData];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    
    [HttpTool get:SubjectPiazza_URL params:params success:^(id responseObj) {
       
        EyeSquareModel *model = [EyeSquareModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        //清楚旧数据
        [self.squareDataArr removeAllObjects];
        
        [self.squareDataArr addObjectsFromArray:model.columnOverviews];
       
        //缓存对象
        [[TMCache sharedCache] setObject:self.squareDataArr forKey:@"squareDataArr" block:nil];
        
        [self.tableView reloadData];
        
        [self.tableView.header endRefreshing];
        
//        ZYLog(@"responseObj = %@",responseObj);
        
    } failure:^(NSError *error) {
        
//        [self addActityText:@"请检查网络连接" deleyTime:1];
        [self.tableView.header endRefreshing];
        ZYLog(@"error = %@",error);
    }];
}
/**
 *  广告栏数据
 */
- (void)loadAdsData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    [HttpTool get:Ads_URL params:params success:^(id responseObj) {
        
        self.adsHeadView = nil;
        
//        ZYLog(@"Ads_URL responseObj = %@",responseObj);
        
        NSArray *adsDataArr = [EyeAdsModel mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"advertisements"]];
        //缓存对象
        [[TMCache sharedCache] setObject:adsDataArr forKey:@"adsDataArr" block:nil];
        
        self.adsDataArr = adsDataArr;
        
        // 设置广告栏
        if (self.adsDataArr.count) {
            
            self.adsHeadView.dataArr = self.adsDataArr;
            
            self.tableView.tableHeaderView = self.adsHeadView;
        }
        
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.squareDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EyeSquareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeSquareCell"];
    
    cell.delegate = self;

    
    ColumnOverview *columnOverview = self.squareDataArr[indexPath.row];
    
    [cell refreshUI:columnOverview];
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ColumnOverview *columnOverview = self.squareDataArr[indexPath.row];
    ImgView *imgView =columnOverview.imgViews[0];
    
    return imgView.cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EyeMoreViewController *more = [[EyeMoreViewController alloc] init];
    
    more.type = EyeSubjectsControllerTypeMore;
    
    ColumnOverview *columnOverview = self.squareDataArr[indexPath.row];
    
    more.columnBrief = columnOverview.columnBrief;
    [self.navigationController pushViewController:more animated:YES];
}



#pragma mark - EyeSquareCellDelegate

-(void) squareCellDidClick:(EyeSquareCell *)squareCell clickEnum:(EyeSquareCellClickEnum)clickEnum
{
    
    if (clickEnum == EyeSquareCellClickImageLeft) {
        ZYLog(@"选中左边图片");
         //跳转到详细信息界面
         ColumnOverview *columnOverview = self.squareDataArr[squareCell.indexPath.row];
         EyeTopicDetailController *detailCtl = [[EyeTopicDetailController alloc] init];
         
         detailCtl.ID = [columnOverview.imgViews[0] subjectId];
         
         [self.navigationController pushViewController:detailCtl animated:YES];
    } else if (clickEnum == EyeSquareCellClickImageRight){
    
        ZYLog(@"选中右边图片");
        //跳转到详细信息界面
        ColumnOverview *columnOverview = self.squareDataArr[squareCell.indexPath.row];
        EyeTopicDetailController *detailCtl = [[EyeTopicDetailController alloc] init];

        detailCtl.ID = [columnOverview.imgViews[1] subjectId];
        
        [self.navigationController pushViewController:detailCtl animated:YES];
        
    }else if (clickEnum == EyeSquareCellClickMoreButton){
        
        ZYLog(@"点击更多按钮");
        
        EyeMoreViewController *more = [[EyeMoreViewController alloc] init];
        more.type = EyeSubjectsControllerTypeMore;
        more.columnBrief = squareCell.columnOverview.columnBrief;
        [self.navigationController pushViewController:more animated:YES];
        
    }
 
}

#pragma mark -- property

-(UITableView *)tableView
{
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        //注册cell
        [tableView registerClass:[EyeSquareCell class] forCellReuseIdentifier:@"EyeSquareCell"];
        
        //约束
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        _tableView = tableView;
        
    }
    
    return _tableView;
}


-(ZYInfiniteScrollView *)adsHeadView
{
    if (!_adsHeadView) {
        ZYInfiniteScrollView *headView = [[ZYInfiniteScrollView alloc] init];
        headView.frame = CGRectMake(0, 64, self.view.width, self.view.width * 9/16);
        headView.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        headView.pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
               
        
        
        _adsHeadView = headView;
    }
    
    return _adsHeadView;
}



-(NSMutableArray *)squareDataArr
{
    if (!_squareDataArr) {
        
        _squareDataArr = [NSMutableArray array];
        
    }
    return _squareDataArr;
}

@end
