//
//  FindViewController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/19.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeFindViewController.h"
#import "EyeSquareViewController.h"
#import "EyeLatestViewController.h"
#import "EyeAroundViewController.h"
#import "EyePopMenu.h"

#import "EyeMyPictureController.h"
#import "EyeMyVideoController.h"
#import "EyeMyTrackController.h"
#import "EyeMyTravelsController.h"

#import "EyeBreakRulesVideoListController.h"
#import "EyePictureListController.h"
#import "TZImagePickerController.h"

@interface EyeFindViewController ()<UITableViewDataSource,UITableViewDelegate,TZImagePickerControllerDelegate>
@property (nonatomic, strong) UISegmentedControl *segCtl;

/** 弹出视图 */
@property (nonatomic, strong) EyePopMenu *popView;

/** 弹出的tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 弹出的标题数组 */
@property (nonatomic, strong) NSArray *titleArr;
/** 图片数组 */
@property (nonatomic, strong) NSArray *imageArr;

@end

@implementation EyeFindViewController

-(UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.scrollEnabled = NO;
        tableView.rowHeight = 40;

        //分割线从最左侧开始
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [tableView setSeparatorInset:UIEdgeInsetsZero];
            
        }
        
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [tableView setLayoutMargins:UIEdgeInsetsZero];
            
        }
        
        
        
        _tableView = tableView;
        _titleArr = @[@"我的图片",@"我的视频",@"我的轨迹",@"我的游记",@"违章举报"];
        _imageArr = @[@"find_myPicure",@"find_myVideo",@"find_myTrack",@"find_myTravel",@"find_breakRules"];

    }
    
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
//     self.automaticallyAdjustsScrollViewInsets = NO;
    
    //初始化子控制器
    [self setupChildCtls];

    // 设置导航栏
    [self setupNav];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [NotificationCenter addObserver:self selector:@selector(setupNav) name:@"FindCtlSetupNavNotification" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

/**
 *  初始化子控制器
 */
-(void)setupChildCtls
{
    //广场
    EyeSquareViewController *squareCtl = [[EyeSquareViewController alloc] init];
    [self addChildViewController:squareCtl];
    
    //最新
    EyeLatestViewController *latestCtl = [[EyeLatestViewController alloc] init];
    latestCtl.type = EyeSubjectsControllerTypeLatest;
    [self addChildViewController:latestCtl];
    
    //附近
    EyeAroundViewController *aroundCtl = [[EyeAroundViewController alloc] init];
    [self addChildViewController:aroundCtl];
    
   
}

/**
 *  设置导航栏
 */
-(void)setupNav
{
    self.title = @"发现";
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //设置titleView
    
    self.segCtl = [[UISegmentedControl alloc] initWithItems:@[@"广场",@"最新",@"附近"]];
    [self.segCtl addTarget:self action:@selector(selectedSegIndex:) forControlEvents:UIControlEventValueChanged];
    self.segCtl.tintColor = ZYRGBColor(167, 27, 36) ;
    // 改变选中颜色
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.segCtl setTitleTextAttributes:dic forState:UIControlStateSelected];
    
    // 设置宽度
    for (int i = 0; i < self.segCtl.numberOfSegments; i ++) {
        
        [self.segCtl setWidth:70 forSegmentAtIndex:i];
    }
    //默认选中第一个
    self.segCtl.selectedSegmentIndex = 0;
    [self selectedSegIndex:self.segCtl];
    self.navigationItem.titleView = self.segCtl;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:GETTABIMAGE(@"find_share") style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
}


-(void)rightClick:(UIBarButtonItem *)barItem
{
    // 弹出菜单
    
    self.popView = [EyePopMenu popMenuWithContentView:self.tableView];
    [self.popView showInRect:CGRectMake(self.view.width - 150 - 10, 64, 150, 208 )];
}

/**
 *  点击segCtl
 */
-(void)selectedSegIndex:(UISegmentedControl *)segCtl
{
    
    // 取出子控制器
    UIViewController *vc = self.childViewControllers[segCtl.selectedSegmentIndex];
    vc.view.x = 0;
    
//    vc.view.y = 0;
    vc.view.height = self.view.height - TABBARHEIGHT;
    
    [self.view addSubview:vc.view];
    

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];

    }
    cell.imageView.image = [UIImage imageNamed:_imageArr[indexPath.row]];
    cell.textLabel.text = _titleArr[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.popView dismiss];
    
    switch (indexPath.row) {
        case 0:{   //跳转到相册
            
            EyePictureListController *pictureListCtl = [EyePictureListController new];
            
            [self.navigationController pushViewController:pictureListCtl animated:YES];
            
//            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXFLOAT delegate:self];
//            imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
//            imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
//
//            
//            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//                
//                // 选中相片后返回到分享图片页面
//                 EyeMyPictureController *pictureCtl = [[EyeMyPictureController alloc] init];
//                [self.navigationController pushViewController:pictureCtl animated:NO];
//            }];
//            
//            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
            break;
        case 1:{    //跳转到我的视频
            EyeMyVideoController *videoCtl = [[EyeMyVideoController alloc] init];
            [self.navigationController pushViewController:videoCtl animated:YES];
        }
            break;
        case 2:{    //跳转到我的轨迹
            EyeMyTrackController *trackCtl = [[EyeMyTrackController alloc] init];
            [self.navigationController pushViewController:trackCtl animated:YES];
        }
            break;
        case 3:{    //跳转到我的游记
            EyeMyTravelsController *travelsCtl = [[EyeMyTravelsController alloc] init];
            [self.navigationController pushViewController:travelsCtl animated:YES];
        }
            break;
        case 4:{    //跳转到违章举报
            EyeBreakRulesVideoListController *breakRulesCtl = [[EyeBreakRulesVideoListController alloc] init];
            [self.navigationController pushViewController:breakRulesCtl animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
}

@end
