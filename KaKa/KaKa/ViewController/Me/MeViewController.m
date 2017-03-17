//
//  MeViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeViewController.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
#import "MeViewControllerTableViewCell.h"
#import "MePersonalDetailViewController.h"
#import "MeCollectViewController.h"
#import "MeShareViewController.h"
#import "MeNewsViewController.h"
#import "MeAboutUsViewController.h"
#import "MeTrajectoryViewController.h"
#import "MeSettingViewController.h"
#import "MessageModel.h"
#import "FMDBTools.h"
#import "MyTools.h"
@interface MeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

// 消息数组
@property (nonatomic, strong) NSMutableArray *msgArrays;

@end

@implementation MeViewController
{
    UIView *bg_top_view;//顶部view
    UIImageView *user_imageView;//用户头像
    UILabel *user_name_lab;//用户姓名
    UILabel *all_integral_lab;//总积分
    UILabel *week_integral_lab;//周积分
    UILabel *collect_lab;//收藏
    UILabel *share_lab;//分享
    UILabel *news_lab;//消息
}



#pragma mark - 懒加载
- (NSMutableArray *)msgArrays {
    
    if (!_msgArrays) {
        _msgArrays = [NSMutableArray array];
    }
    
    return _msgArrays;
}

-(NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
        MeParentModel *me_trajectory = [MeParentModel itemWithTitle:@"轨迹" titleImage:@"me_trajectory" detail:@"暂无"];
        MeParentModel *me_setting = [MeArrowItemModel itemWithTitle:@"设置" titleImage:@"me_setting" detail:nil];
        MeParentModel *me_about = [MeArrowItemModel itemWithTitle:@"关于我们" titleImage:@"me_about" detail:nil];
        [_dataSource addObject:me_trajectory];
        [_dataSource addObject:me_setting];
        [_dataSource addObject:me_about];
    }
    return _dataSource;
}

-(UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 610*PSDSCALE_Y, SCREEN_WIDTH, 300*PSDSCALE_Y) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        
    }
    return _tableView;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        // 注册获取用户信息通知
        [NotificationCenter addObserver:self selector:@selector(getUserInfo) name:@"GetUserInfoNoti" object:nil];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self getUserMessages];
    
    if (self.dataSource.count)
    {
        NSMutableArray *path_arr = [MyTools getAllDataWithPath:Path_Photo(nil) mac_adr:nil];
        
        if (path_arr.count)
        {
            MeParentModel *me_trajectory = [MeArrowItemModel itemWithTitle:@"轨迹" titleImage:@"me_trajectory" detail:nil];
            [self.dataSource replaceObjectAtIndex:0 withObject:me_trajectory];
        }
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBSTRING(@"f5f8fa");
    [self initUI];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    [self refreshUserInfoUI];
    
}



- (void)initUI
{
    bg_top_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 590*PSDSCALE_Y)];
    bg_top_view.backgroundColor = RGBSTRING(@"eeeeee");
    [self.view addSubview:bg_top_view];
    
    UIView *user_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 470*PSDSCALE_Y)];
    user_view.backgroundColor = [UIColor blackColor];
    [bg_top_view addSubview:user_view];
    
    //用户头像
    user_imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-180*PSDSCALE_X)/2, 126*PSDSCALE_Y, 180*PSDSCALE_Y, 180*PSDSCALE_Y)];
    user_imageView.backgroundColor = [UIColor whiteColor];
    user_imageView.layer.masksToBounds = YES;
    user_imageView.userInteractionEnabled = YES;
    user_imageView.layer.cornerRadius = 90*PSDSCALE_Y;
    user_imageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(push_click)];
    [user_imageView addGestureRecognizer:tap];
    
    [user_view addSubview:user_imageView];
    
    //用户姓名
    user_name_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(user_imageView)+19*PSDSCALE_Y, SCREEN_WIDTH, 37*PSDSCALE_Y)];
    user_name_lab.text = @"Greace";
    user_name_lab.textAlignment = NSTextAlignmentCenter;
    user_name_lab.userInteractionEnabled = YES;
    user_name_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    user_name_lab.textColor = RGBSTRING(@"b11c22");
    [user_view addSubview:user_name_lab];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(push_click)];
    [user_name_lab addGestureRecognizer:tap1];
    
    //总积分
    all_integral_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(user_name_lab)+55*PSDSCALE_Y, (SCREEN_WIDTH-100*PSDSCALE_X)/2, 32*PSDSCALE_Y)];
    all_integral_lab.text = @"总积分:123456";
    all_integral_lab.textAlignment = NSTextAlignmentRight;
    all_integral_lab.textColor = [UIColor whiteColor];
    all_integral_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [user_view addSubview:all_integral_lab];
    
    //周积分
    week_integral_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_integral_lab)+100*PSDSCALE_X, VIEW_Y(all_integral_lab), VIEW_W(all_integral_lab), 32*PSDSCALE_Y)];
    week_integral_lab.textAlignment = NSTextAlignmentLeft;
    week_integral_lab.text = @"周积分:123456";
    week_integral_lab.textColor = [UIColor whiteColor];
    week_integral_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [user_view addSubview:week_integral_lab];
    
    NSArray *images = @[@"me_collect",@"me_share",@"me_news"];
    for (int i = 0; i < images.count; i ++)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(248*PSDSCALE_X*i+2*PSDSCALE_X*i, VIEW_H_Y(user_view), 248*PSDSCALE_X, 120*PSDSCALE_Y)];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(22*PSDSCALE_Y, 0, 64*PSDSCALE_Y, 0)];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn setImage:GETYCIMAGE(images[i]) forState:UIControlStateNormal];
        [bg_top_view addSubview:btn];
        btn.tag = 1+i;
        [btn addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0)
        {
            collect_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 75*PSDSCALE_Y, VIEW_W(btn), 32*PSDSCALE_Y)];
            collect_lab.textAlignment = NSTextAlignmentCenter;
            collect_lab.textColor = RGBSTRING(@"666666");
            collect_lab.text = @"收藏";
            collect_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
            [btn addSubview:collect_lab];
        }
        else if (i == 1)
        {
            share_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 75*PSDSCALE_Y, VIEW_W(btn), 32*PSDSCALE_Y)];
            share_lab.textAlignment = NSTextAlignmentCenter;
            share_lab.textColor = RGBSTRING(@"666666");
            share_lab.text = @"分享";
            share_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
            [btn addSubview:share_lab];
        }
        else
        {
            news_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 75*PSDSCALE_Y, VIEW_W(btn), 32*PSDSCALE_Y)];
            news_lab.textAlignment = NSTextAlignmentCenter;
            news_lab.textColor = RGBSTRING(@"666666");
            news_lab.text = @"消息(0)";
            news_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
            [btn addSubview:news_lab];
        }
        
    }
}


#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeViewControllerTableViewCell *cell = [MeViewControllerTableViewCell cellWithTableView:tableView];
    cell.item = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100*PSDSCALE_Y;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        MeTrajectoryViewController *trajectoryVC = [[MeTrajectoryViewController alloc] init];
        trajectoryVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:trajectoryVC animated:YES];
    }
    else if (indexPath.row ==1)
    {
        MeSettingViewController *settingVC = [[MeSettingViewController alloc] init];
        settingVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    else
    {
        MeAboutUsViewController *aboutUsVC = [[MeAboutUsViewController alloc] init];
        aboutUsVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutUsVC animated:YES];
    }
}





#pragma mark- 点击事件

- (void)btn_click:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:
        {
            MMLog(@"收藏");
            MeCollectViewController *collectVC = [[MeCollectViewController alloc] init];
            collectVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collectVC animated:YES];
        }
            break;
        case 2:
        {
            MMLog(@"分享");
            MeShareViewController *shareVC = [[MeShareViewController alloc] init];
            
            shareVC.type = EyeSubjectsControllerTypeShare;
            NSDictionary *userInfo = UserInfo;
            shareVC.issuedBy = VALUEFORKEY(userInfo, @"userId");
            
            shareVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:shareVC animated:YES];
        }
            break;
        case 3:
        {
            MMLog(@"消息");
            MeNewsViewController *newsVC = [[MeNewsViewController alloc] init];
            newsVC.dataSource = self.msgArrays;
            newsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newsVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)push_click
{
    MePersonalDetailViewController *mePersonalDetailVC = [[MePersonalDetailViewController alloc] init];
    mePersonalDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mePersonalDetailVC animated:YES];
}

/**
 *  获取个人信息
 */
- (void)getUserInfo {
    
    [RequestManager qryUserInfoSucceed:^(id responseObject) {
        
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
            NSDictionary *result = VALUEFORKEY(resultDic, @"result");
            NSDictionary *userInfo = VALUEFORKEY(result, @"userInfo");
            
            if (userInfo) {
                [UserDefaults setObject:userInfo forKey:@"UserInfo"];
                [UserDefaults synchronize];
            }
            
            [self refreshUserInfoUI];
            
        } err_block:^(NSDictionary *resultDic) {
            
        }];
        
    } failed:^(NSError *error) {
        REQUEST_FAILED_ALERT;
    }];
}


- (void)refreshUserInfoUI {
    
    if (!_tableView) {
        return;
    }
    NSDictionary *userInfo = UserInfo;
    // 头像
    [user_imageView sd_setImageWithURL:[NSURL URLWithString:FORMATSTRING(VALUEFORKEY(userInfo, @"portraitImgUrl"))] placeholderImage:GETYCIMAGE(@"default_headImage_big.png")];
    
    // 用户名
    NSString *nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"nickName"));
//    if (nickName.length == 0) {
//        // 昵称没有取用户名
//        nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"userName"));
//    }
    user_name_lab.text = nickName;
    
    all_integral_lab.text = [NSString stringWithFormat:@"总积分:%@", VALUEFORKEY(userInfo, @"userPoints")];
    week_integral_lab.text = [NSString stringWithFormat:@"周积分:%@", VALUEFORKEY(userInfo, @"userWeekPoints")];
    
    
    
    collect_lab.text = [NSString stringWithFormat:@"收藏(%lu)",[FMDBTools getImageUrlsFromDataBaseWithName:UserName].count + [FORMATSTRING(VALUEFORKEY(userInfo, @"collectionCount")) intValue]];
    
    NSString *submitCount = FORMATSTRING(VALUEFORKEY(userInfo, @"submitCount"));
    if (submitCount.length)
    {
        share_lab.text = [NSString stringWithFormat:@"分享(%@)",FORMATSTRING(VALUEFORKEY(userInfo, @"submitCount"))];
    }
    else
    {
        share_lab.text = @"分享(0)";
    }
    
}

// 获取用户消息列表
- (void)getUserMessages {
    
    if (self.msgArrays && self.msgArrays.count) {
        [self.msgArrays removeAllObjects];
    }
    [RequestManager qryUserMessagesWithLastMsgTime:@"0" msgId:nil Succeed:^(id responseObject) {
        
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
            NSDictionary *result = VALUEFORKEY(resultDic, @"result");
            NSArray *msgList = VALUEFORKEY(result, @"msgList");
            
            if ([msgList isKindOfClass:[NSArray class]]) {
//                NSInteger msgCount = msgList.count;
//                news_lab.text = [NSString stringWithFormat:@"消息(%ld)", (long)msgCount];
                NSArray *msgArrays = [MessageModel mj_objectArrayWithKeyValuesArray:msgList];
                
                // 是否有未读消息
                BOOL hasUnReaded = NO;
                // 未读消息数
                NSInteger unReadedMsgCount = 0;
                for (MessageModel *msgModel in msgArrays) {
                    if (!msgModel.readed) {
                        hasUnReaded = YES;
                        unReadedMsgCount++;
                    }
                    
                    [self.msgArrays addObject:msgModel];
                }
                
                news_lab.text = [NSString stringWithFormat:@"消息(%ld)", (long)unReadedMsgCount];

                // 如果有未读
                UIButton *newBtn = [bg_top_view viewWithTag:3];
                if (hasUnReaded) {
                    [newBtn setImage:GETNCIMAGE(@"me_news_unreaded.png") forState:UIControlStateNormal];
                } else {
                    [newBtn setImage:GETNCIMAGE(@"me_news.png") forState:UIControlStateNormal];
                }
            }
            
            
        } err_block:^(NSDictionary *resultDic) {
            
        }];
    } failed:^(NSError *error) {
        REQUEST_FAILED_ALERT;
    }];
    
}


@end
