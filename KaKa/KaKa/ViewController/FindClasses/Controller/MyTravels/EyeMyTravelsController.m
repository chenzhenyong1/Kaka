//
//  EyeMyTravelsController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeMyTravelsController.h"
#import "EyeTravelsCell.h"
#import "AlbumsTravelReviewViewController.h"

@interface EyeMyTravelsController ()
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;


@end

@implementation EyeMyTravelsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置TableView
    [self setupTableView];
    //数据库获取数据
    [self loadDataFromDB];
    [NotificationCenter addObserver:self selector:@selector(loadDataFromDB) name:@"TravelDeleteSuccess" object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadDataFromDB) name:@"TravelAddSuccess" object:nil];
}

- (void)loadDataFromDB
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[CacheTool queryTravelsWithUserName:UserName]];
    [self.tableView reloadData];

}

/**
 *  设置TableView
 */
- (void)setupTableView
{
    self.title = @"游记列表";
    self.view.backgroundColor = ZYGlobalBgColor;
    self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
}





#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kIdentifier = @"Cell";
    
    EyeTravelsCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[EyeTravelsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    
    cell.model = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
    
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //跳转到游记编辑页面
    AlbumsTravelReviewViewController *travelCtl = [[AlbumsTravelReviewViewController alloc] init];
    travelCtl.model = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:travelCtl animated:YES];
    
}

#pragma mark -- property
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        
        _dataSource = [NSMutableArray array];
        
    }
    
    return _dataSource;
}


@end
