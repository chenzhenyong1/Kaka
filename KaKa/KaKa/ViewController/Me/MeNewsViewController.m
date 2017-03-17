//
//  MeNewsViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeNewsViewController.h"
#import "MeNewsViewControllerTableViewCell.h"
#import "MeNewsDetailViewController.h"
@interface MeNewsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation MeNewsViewController

#pragma mark - 懒加载
-(NSMutableArray *)datas
{
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
        
        
    }
    return _datas;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) style:UITableViewStylePlain];
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
    [self addTitleWithName:@"我的消息" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    _datas = [self.dataSource mutableCopy];
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
}

#pragma mark -UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeNewsViewControllerTableViewCell *cell = [MeNewsViewControllerTableViewCell cellWithTableView:tableView];
    
    cell.msgModel = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150*PSDSCALE_Y;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //点击单元格隐藏红点并修改消息为已读
    MeNewsViewControllerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.pointView.hidden = YES;
    
    MessageModel *msgModel = [self.dataSource objectAtIndex:indexPath.row];
    msgModel.readed = YES;
    // 更新已读属性
    [self updateMsgReadAttsWithSelectedMsg:msgModel];
    
    MeNewsDetailViewController *newDetailVC = [[MeNewsDetailViewController alloc] init];
    newDetailVC.msgModel = msgModel;
    [self.navigationController pushViewController:newDetailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self delMsg:[self.dataSource objectAtIndex:indexPath.row] atIndexPath:indexPath];
    }
}

// 更新消息已读属性
- (void)updateMsgReadAttsWithSelectedMsg:(MessageModel *)msgModel {
    
    [RequestManager updateMsgAttrsWithMsgId:msgModel.msgId readed:YES Succeed:^(id responseObject) {
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
        } err_block:^(NSDictionary *resultDic) {
            
        }];
    } failed:^(NSError *error) {
        
    }];
}

// 删除消息
- (void)delMsg:(MessageModel *)msgModel atIndexPath:(NSIndexPath *)indexPath {
    
    [self addActityLoading:nil subTitle:nil];
    
    __weak typeof(self) weakSelf = self;
    [RequestManager delMsgWithMsgIdsArray:@[FORMATSTRING(msgModel.msgId)] Succeed:^(id responseObject) {
        
        [weakSelf removeActityLoading];
        
        [weakSelf resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
            [weakSelf.dataSource removeObject:msgModel];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } err_block:^(NSDictionary *resultDic) {
            [weakSelf addActityText:@"消息删除失败" deleyTime:1];
        }];
    } failed:^(NSError *error) {
        [weakSelf removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];
}

@end
