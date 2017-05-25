//
//  EyeCommentController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/28.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeCommentController.h"
#import "EyeCommentCell.h"
#import "InteractList.h"

#define pageSize 500


@interface EyeCommentController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) UITableView *tableView;

/** 查询的记录数  */
@property (nonatomic, assign) NSUInteger recordCount;

/** 页的序号  */
@property (nonatomic, assign) NSInteger pageIndex;

/** 页的总数  */
@property (nonatomic, assign) NSUInteger pageNum;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *remarkDataArr;

/** 底部发表评论视图 */
@property (nonatomic, weak) UIView *bottomView;

/** textField */
@property (nonatomic, weak) UITextField *commentField;

/** 发送按钮 */
@property (nonatomic, weak) UIButton *sendButton;

@end

@implementation EyeCommentController

#pragma mark -- lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"评论信息";
    self.view.backgroundColor = ZYGlobalBgColor;
    
    [self setupNav];
    
    [self tableView];
    
    [self bottomView];
    
    
    [self commentField];
//    self.commentField.inputAccessoryView = self.bottomView;
    
    //添加刷新控件
    [self setupRefresh];

    [self.tableView.mj_header beginRefreshing];
    
}
- (void)setupNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
    params[@"subjectId"] = self.ID;
    
    [HttpTool get:SubjectRemarks_URL params:params success:^(id responseObj) {
        
        NSString *recordCount = responseObj[@"result"][@"recordCount"];
        
        self.recordCount = [recordCount integerValue];
        ZYLog(@"self.recordCount = %lu",self.recordCount);
        if (self.recordCount % pageSize != 0) {
            
            self.pageNum = self.recordCount / pageSize == 0 ? 1 : self.recordCount / pageSize + 1;
        }else{
            self.pageNum = self.recordCount / pageSize;
        }
        // 取最新话题数据
        [self loadLatestRemarkData];
        
        
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
    }];
    
}
/**
 *  刷新第一页数据
 */
- (void)loadLatestRemarkData
{
    
    self.pageIndex = 1;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"pageSize"] = [NSString stringWithFormat:@"%d",pageSize];
    params[@"pageIndex"] = [NSString stringWithFormat:@"%ld",self.pageIndex];
    params[@"subjectId"] = self.ID;
    
    [HttpTool get:SubjectRemarks_URL params:params success:^(id responseObj) {
        
        ZYLog(@"remark = %@",responseObj);
        
        NSArray *latestDataArr = [InteractList mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"recordList"]];
        //清楚所有的旧数据
        [self.remarkDataArr removeAllObjects];
        //再添加新数据
        [self.remarkDataArr addObjectsFromArray:latestDataArr];
//
        ZYLog(@"remarkDataArr = %ld",self.remarkDataArr.count);
//
        [self.tableView reloadData];
        
        //结束刷新
        [self.tableView.mj_header endRefreshing];
        // 让底部控件结束刷新
        [self checkFooterState];
        
    } failure:^(NSError *error) {
        
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
    params[@"pageIndex"] = [NSString stringWithFormat:@"%ld",self.pageIndex];
    params[@"subjectId"] = self.ID;
    
    
    [HttpTool get:SubjectRemarks_URL params:params success:^(id responseObj) {
        
        NSArray *latestDataArr = [InteractList mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"recordList"]];
        
        [self.remarkDataArr addObjectsFromArray:latestDataArr];
        
//        ZYLog(@"self.latestDataArr = %ld",self.latestDataArr.count);
        
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
    
    if (self.pageIndex == self.pageNum) {// 全部数据已经加载完毕
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        
    }else{
        
        [self.tableView.mj_footer endRefreshing];
    }
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.remarkDataArr.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (0 == indexPath.row) {
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        //        self.data.interactList.count;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"评论 (%lu)",(unsigned long)self.remarkDataArr.count];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.height - 1, self.view.width, 1)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.alpha = 0.3;
        [cell.contentView addSubview:lineView];
        
        return cell;
        
    }else
    {
        EyeCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeCommentCell"];
        InteractList *interactList = self.remarkDataArr[indexPath.row - 1];
        
        cell.floorNumLabel.text = [NSString stringWithFormat:@"%lu楼",self.remarkDataArr.count - indexPath.row + 1];
        
        [cell refreshUI:interactList];
        
        return cell;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44;
    }
    InteractList *interactList = self.remarkDataArr[indexPath.row - 1];
    return interactList.cellHeight;
}

#pragma mark -- tableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if ([self.commentField isFirstResponder]) {
//        
//        [self.commentField canBecomeFirstResponder];
////        [self.commentField canResignFirstResponder];
//        
//    }else{
//       
//        [self.commentField resignFirstResponder];
//    }
    
    
    if (indexPath.row != 0) {
        
        InteractList *interactList = self.remarkDataArr[indexPath.row - 1];
        
        self.commentField.placeholder = [NSString stringWithFormat:@"回复 %@:",interactList.actorNickName];
        
       [self.commentField becomeFirstResponder];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.commentField resignFirstResponder];
    
    
    return YES;
}
#pragma mark -- property

-(UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - NAVIGATIONBARHEIGHT - TABBARHEIGHT)];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[EyeCommentCell class] forCellReuseIdentifier:@"EyeCommentCell"];
        
        [self.view addSubview:tableView];
        
        _tableView = tableView;
    }
    return _tableView;
}

-(NSMutableArray *)remarkDataArr
{
    if (!_remarkDataArr) {
        _remarkDataArr = [NSMutableArray array];
    }
    
    return _remarkDataArr;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        
        UIView *view = [[UIView alloc] init];
        
//        view.backgroundColor = [UIColor purpleColor];
        
        [self.view addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.with.bottom.equalTo(self.view);
            
            make.height.equalTo(@49);
            
        }];
        
        _bottomView = view;
    }
    return _bottomView;
}

-(UITextField *)commentField
{
    if (!_commentField) {
     
        UITextField *textField = [[UITextField alloc] init];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        [textField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型 
        textField.placeholder = @"写评论.....";
        
        [self.bottomView addSubview:textField];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self.bottomView.mas_centerY);
            
            make.left.equalTo(self.bottomView).offset(20);
            
            make.right.equalTo(self.sendButton.mas_left).offset(-20);
            
            make.height.equalTo(@35);
            
        }];
        
        _commentField = textField;
        
    }
    
    return _commentField;
}

-(UIButton *)sendButton
{
    if (!_sendButton) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [btn addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.bottomView.mas_right).offset(-10);
            
            make.centerY.equalTo(self.bottomView.mas_centerY);
            
//            make.left.equalTo(self.commentField.mas_right).offset(20);
            make.width.equalTo(@(self.view.width * 0.1));
        }];
        
        _sendButton = btn;
    }
    
    return _sendButton;
}

#pragma mark -- sendMessage

- (void)sendButton:(UIButton *)btn
{
    if (self.commentField.text.length) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if (indexPath.row  == 0) {
            
            [self sendMessage:nil];    //发表评论
            
        }else
        {
            //回复评论
            InteractList *interactList =  self.remarkDataArr[indexPath.row-1];
            ZYLog(@"indexPath = %ld",(long)indexPath.row);
            [self sendMessage:interactList.ID];
        }
        
    }else
    {
        [self addActityText:@"请输入评论..." deleyTime:1];
    }
    
    
    
    
//    
//
    
    

}


- (void)sendMessage:(NSString *)replyToId
{
    
    [self addActityLoading:nil subTitle:nil];
    
    NSMutableDictionary *interactParams = [NSMutableDictionary dictionary];
    interactParams[@"subjectId"] = self.ID;
    interactParams[@"actType"] = @"4";//
    interactParams[@"shortText"] = self.commentField.text;
    
    if (replyToId != nil) {
        
        interactParams[@"replyToId"] = replyToId;
        
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"interact"] = interactParams;
   
    
    
    [HttpTool post:subjectInteractive_URL params:params success:^(id responseObj) {
       
        ZYLog(@"SubjectInteractive_URL responseObj = %@",responseObj);
        [self.commentField endEditing:YES];
        self.commentField.text = @"";
        [self.tableView.mj_header beginRefreshing];
        if (replyToId != nil) {
            [self addActityText:@"回复成功" deleyTime:1.0];
        }else{
        
            [self addActityText:@"发表成功" deleyTime:1.0];
        }
        
    } failure:^(NSError *error) {
        if (replyToId != nil) {
            [self addActityText:@"回复失败" deleyTime:1.0];
        }else{
            
            [self addActityText:@"发表失败" deleyTime:1.0];
        }
    }];

}



@end
