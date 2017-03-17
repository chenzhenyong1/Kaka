//
//  AlbumsTravelViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/29.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelViewController.h"
#import "AlbumsTravelListTableViewCell.h"
#import "AlbumsTravelReviewViewController.h"
#import "MyTools.h"
#import "CameraTime_lineModel.h"
#import "AlbumsTravelModel.h"

@interface AlbumsTravelViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    BOOL isFirstLoad;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSMutableArray *XMLDataArray;
@end

@implementation AlbumsTravelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isFirstLoad = YES;
    
    [self addTitle:@"游记列表"];
    
    [self addBackButtonWith:nil];
    
    [self.view addSubview:self.tableView];
    [self loadDataFromDB];
    
    // 注册通知，当游记删除、添加图片、编辑都需要刷新UI
    [NotificationCenter addObserver:self selector:@selector(loadDataFromDB) name:@"TravelDeleteSuccess" object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadDataFromDB) name:@"TravelAddSuccess" object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadDataFromDB) name:@"TravelPrettifiedNoti" object:nil];
}


/**
 从数据库加载游记
 */
- (void)loadDataFromDB {
    
    [self.dataSource removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dataSource addObjectsFromArray:[CacheTool queryTravelsWithUserName:UserName]];
        // 第一次进来时，遍历游记列表，把没有图片的游记删除
        if (isFirstLoad) {
            isFirstLoad = NO;
            for (AlbumsTravelModel *model in self.dataSource) {
                NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:model.travelId];
                for (AlbumsTravelDetailModel *detailModel in travelDetailArray) {
                    NSString *path = [Travel_Path(model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
                    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                        // 图片不存在，删除详情
                        [CacheTool deleteTravelDetailWithDetailId:detailModel.detailId];
                    }
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        }); 
        
    });
    
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT)];
        _tableView.contentInset = UIEdgeInsetsMake(6, 0, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = RGBSTRING(@"f5f8fa");
        _tableView.separatorColor = RGBSTRING(@"cccccc");
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"Cell";
    
    AlbumsTravelListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[AlbumsTravelListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    
    cell.model = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 145;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 点击进入游记详情
    AlbumsTravelReviewViewController *reviewVC = [[AlbumsTravelReviewViewController alloc] init];
    reviewVC.model = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:reviewVC animated:YES];
}

@end
