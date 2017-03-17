//
//  MeSettingViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeSettingViewController.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
#import "MeGroupModel.h"
#import "MeSwitchItemModel.h"
#import "MeSettingViewCotrollerTableViewCell.h"
#import "CameraSettingViewController.h"
#import "MeAppCacheViewController.h"
@interface MeSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MeSettingViewController

#pragma mark - 懒加载
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        
        NSString *cameraSettingDetail = @"未连接";
        if ([SettingConfig shareInstance].deviceLoginToken.length) {
            cameraSettingDetail = @"已连接";
        }
        MeParentModel *cameraSetting = [MeArrowItemModel itemWithTitle:@"摄像机设置" titleImage:nil detail:cameraSettingDetail];
        MeGroupModel *group0 = [[MeGroupModel alloc] init];
        group0.items = @[cameraSetting];
        
        MeParentModel *appCache = [MeArrowItemModel itemWithTitle:@"APP存储管理" titleImage:nil detail:nil];
        MeGroupModel *group1 = [[MeGroupModel alloc] init];
        group1.items = @[appCache];
        
        MeParentModel *download = [MeSwitchItemModel itemWithTitle:@"自动下载拍照文件" titleImage:nil detail:nil];
        
        MeParentModel *show = [MeSwitchItemModel itemWithTitle:@"仪表盘显示" titleImage:nil detail:nil];
        MeGroupModel *group2 = [[MeGroupModel alloc] init];
        group2.items = @[download,show];
        
        [_dataSource addObject:group0];
        [_dataSource addObject:group1];
        [_dataSource addObject:group2];
        
        
    }
    return _dataSource;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = RGBSTRING(@"eeeeee");
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    [self addTitleWithName:@"高级设置" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];

}

#pragma mark -UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MeGroupModel *group = self.dataSource[section];
    
    return group.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeSettingViewCotrollerTableViewCell *cell = [MeSettingViewCotrollerTableViewCell cellWithTableView:tableView];
    MeGroupModel *group = self.dataSource[indexPath.section];
    MeParentModel *model = group.items[indexPath.row];
    cell.item = model;
    return cell;
}

#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100*PSDSCALE_Y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22*PSDSCALE_Y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if ([SettingConfig shareInstance].deviceLoginToken.length)
        {
            CameraSettingViewController *settingVC = [[CameraSettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
        else
        {
            [self addActityText:@"未登录摄像头" deleyTime:1];
        }
    }
    else if (indexPath.section == 1)
    {
        MeAppCacheViewController *appCacheVC = [[MeAppCacheViewController alloc] init];
        [self.navigationController pushViewController:appCacheVC animated:YES];
    }
    
}





@end
