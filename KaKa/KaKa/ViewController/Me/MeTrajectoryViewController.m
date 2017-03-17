//
//  MeTrajectoryViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeTrajectoryViewController.h"
#import "MeTrajectoryViewControllerTableViewCell.h"
#import "FMDBTools.h"
#import "AlbumsPathDetailViewController.h"
#import "MyTools.h"
@interface MeTrajectoryViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MeTrajectoryViewController

#pragma mark - 懒加载
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        
        
        NSArray *path_photos = [MyTools getAllDataWithPath:Path_Photo(nil) mac_adr:nil];
        
        if (path_photos.count)
        {
            
            NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
            if (sql_arr.count)
            {
                NSMutableArray *temp_arr = [NSMutableArray array];
                for (AlbumsPathModel *model in sql_arr)
                {
                    if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                        [temp_arr addObject:model];
                    }
                }
                _dataSource = [temp_arr mutableCopy];
                
            }
        }
        
        
        
    
    }
    return _dataSource;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = RGBSTRING(@"f5f8fa");
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    [self addTitleWithName:@"我的轨迹" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"f5f8fa");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
}

#pragma mark -UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeTrajectoryViewControllerTableViewCell *cell = [MeTrajectoryViewControllerTableViewCell cellWithTableView:tableView];
    [cell refreshData:self.dataSource[indexPath.row]];
    return cell;
}

#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 622*PSDSCALE_Y;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlbumsPathDetailViewController *albumsPathDetailVC = [[AlbumsPathDetailViewController alloc] init];
    albumsPathDetailVC.num = indexPath.row;
    albumsPathDetailVC.superVC = self;
    albumsPathDetailVC.model = self.dataSource[indexPath.row];
    albumsPathDetailVC.block = ^{
        
        NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
        if (sql_arr.count)
        {
            [self.dataSource removeAllObjects];
            NSMutableArray *temp_arr = [NSMutableArray array];
            for (AlbumsPathModel *model in sql_arr)
            {
                if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                    [temp_arr addObject:model];
                }
            }
            self.dataSource = [temp_arr mutableCopy];
            [self.tableView reloadData];
        }
        
    };
    [self.navigationController pushViewController:albumsPathDetailVC animated:YES];
}




@end
