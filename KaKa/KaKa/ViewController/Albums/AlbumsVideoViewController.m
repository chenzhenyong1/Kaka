//
//  AlbumsVideoViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsVideoViewController.h"
#import "AlbumsVideoView.h"
#import "AlbumsVideoViewControllerCell.h"
#import "AlbumsModel.h"
#import "MyTools.h"
#import "MoviePlayerViewController.h"
#import "FMDBTools.h"
@interface AlbumsVideoViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>

@property(nonatomic, strong) AlbumsVideoView *albumsVideoView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation AlbumsVideoViewController
{
    UIView *rightBtnBg;//右侧按钮
    BOOL isSelect;//是否选择
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
         NSArray *video_PathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
        if (video_PathArr.count)
        {
            NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
            for (int i = 0; i < pathArr.count; i ++)
            {
                
                AlbumsModel *model = [[AlbumsModel alloc] init];
                model.imageName = [pathArr objectAtIndex:i];
                model.isSelect = NO;
                model.isShow = NO;
                
                NSString *fileName = model.imageName;
                fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                fileName = [fileName componentsSeparatedByString:@"_"][0];
                
                NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
                
                for (NSString *str in pathArr)
                {
                    
                    if ([str containsString:fileName])
                    {
                        fileName = str;
                        break;
                    }
                }
                if ([fileName hasSuffix:@".mp4"])
                {
                    [self.dataSource addObject:model];
                }
                
            }
            
        }
        //循环视频
        NSArray *cycleVideo_PathArr =[MyTools getAllDataWithPath:CycleVideo_Path(nil) mac_adr:nil];
        if (cycleVideo_PathArr.count) {
            NSArray *cyclePhoto_PathArr =[MyTools getAllDataWithPath:CyclePhoto_Path(nil) mac_adr:nil];
            for (int i = 0; i < cyclePhoto_PathArr.count; i ++){
                AlbumsModel *model = [[AlbumsModel alloc] init];
                model.imageName = [cyclePhoto_PathArr objectAtIndex:i];
                model.isSelect = NO;
                model.isShow = NO;
                [self.dataSource addObject:model];
            }
                
        }
        self.dataSource = [self newArray:self.dataSource];
    }
    return _dataSource;
}


//遍历数组，将数据按时间重新排序
- (NSMutableArray *)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(AlbumsModel *obj1, AlbumsModel *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj2.imageName] longLongValue]] compare:[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj1.imageName] longLongValue]]];
        return result;
    }];
    [arr removeAllObjects];
    [arr addObjectsFromArray:sortedArray];
    
    return arr;
    
}

//获取时间
- (NSString *)getTimeWithFilePath:(NSString *)filePath
{
    NSString *file_path = [filePath componentsSeparatedByString:@"/"].lastObject;
    file_path = [file_path componentsSeparatedByString:@"."].firstObject;
    file_path = [file_path componentsSeparatedByString:@"_"].firstObject;
    
    return file_path;
}









- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    [self addTitleWithName:@"视频列表" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
    if (pathArr.count)
    {
        CGRect frame = [@"选择" boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:NULL];
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, frame.size.width+10, 30)];
        [rightButton setTitle:@"选择" forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        [self createRightBtnBg];
    }
    [self createUI];
    
    
   

}

- (void)rightButtonAction
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtnBg];
    isSelect = YES;
    for (AlbumsModel *model in self.dataSource)
    {
        model.isShow = YES;
    }
    [self.albumsVideoView.collectionView reloadData];
}

- (void)createRightBtnBg
{
    rightBtnBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180*PSDSCALE_X, 60*PSDSCALE_Y)];
    
    UIButton *cancel_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90*PSDSCALE_X, 60*PSDSCALE_Y)];
    [cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    cancel_btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancel_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel_btn addTarget:self action:@selector(cancel_btn_click) forControlEvents:UIControlEventTouchUpInside];
    [rightBtnBg addSubview:cancel_btn];
    
    UIButton *del_btn = [[UIButton alloc] initWithFrame:CGRectMake(90*PSDSCALE_X, 0, 90*PSDSCALE_X, 60*PSDSCALE_Y)];
    [del_btn setTitle:@"删除" forState:UIControlStateNormal];
    del_btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [del_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [del_btn addTarget:self action:@selector(del_btn_click) forControlEvents:UIControlEventTouchUpInside];
    [rightBtnBg addSubview:del_btn];
}

#pragma mark - 点击事件

- (void)cancel_btn_click
{
    isSelect = NO;
    CGRect frame = [@"选择" boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:NULL];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, frame.size.width+10, 30)];
    [rightButton setTitle:@"选择" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    for (AlbumsModel *model in self.dataSource)
    {
        model.isShow = NO;
        if (model.isSelect)
        {
            model.isSelect = NO;
        }
    }
    [self.albumsVideoView.collectionView reloadData];
}

- (void)del_btn_click
{
    
    NSMutableArray *select_arr = [NSMutableArray array];
    for (AlbumsModel *model in self.dataSource) {
        if (model.isSelect)
        {
            [select_arr addObject:model];
        }
    }
    if (!select_arr.count)
    {
        [self addActityText:@"请选择视频" deleyTime:1];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要删除视频吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            NSMutableArray *select_arr = [NSMutableArray array];
            for (AlbumsModel *model in self.dataSource) {
                if (model.isSelect)
                {
                    [select_arr addObject:model];
                }
            }
            if (!select_arr.count)
            {
                [self addActityText:@"请选择视频" deleyTime:1];
                return;
            }
            isSelect = NO;
            CGRect frame = [@"选择" boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:NULL];
            
            UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, frame.size.width+10, 30)];
            [rightButton setTitle:@"选择" forState:UIControlStateNormal];
            rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
            rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
            self.navigationItem.rightBarButtonItem = rightButtonItem;
            
            
            NSMutableArray *temp_arr = [self.dataSource mutableCopy];
            for (AlbumsModel *model in temp_arr)
            {
                model.isShow = NO;
                if (model.isSelect)
                {
                    [self.dataSource removeObject:model];
                    BOOL isDel = [self deleteDirInCache:model.imageName];
                    if (isDel)
                    {
                        NSString *fileName = model.imageName;
                        if ([fileName containsString:@"CyclePhoto"]) {
                            
                            fileName = [self cyclePhoto_PathChangeCycleVideo_Path:fileName];//取得视频路径
                            
                        }else{
                            fileName = [fileName componentsSeparatedByString:@"_"][0];
                            fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                            NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
                            
                            for (NSString *str in pathArr)
                            {
                                
                                if ([str containsString:fileName])
                                {
                                    fileName = str;
                                    break;
                                }
                            }
                        }
                        
                        BOOL isdeleteVideo = [self deleteDirInCache:fileName];
                        if (isdeleteVideo)
                        {
                            if ([FMDBTools selectContactMember:model.imageName userName:UserName])
                            {
                                // 有收藏，先删除收藏
                                BOOL isDeleteSuccess = [FMDBTools deleteCollectWithimageUrl:model.imageName];
                                if (isDeleteSuccess)
                                {
                                    [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
                                }
                            }
                            MMLog(@"删除成功");
                            [self addActityText:@"删除成功" deleyTime:1];
                            
                        }
                        else
                        {
                            MMLog(@"删除失败");
                            [self addActityText:@"删除失败" deleyTime:1];
                        }
                            
    
                        
                        
            
                    }
                }
            }
            [self.albumsVideoView.collectionView reloadData];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - =============== collectionView控件创建方法 ==============

- (void)createUI
{
    self.albumsVideoView = [[AlbumsVideoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //注册cell
    [self.albumsVideoView.collectionView registerClass:[AlbumsVideoViewControllerCell class] forCellWithReuseIdentifier:@"cell"];
    self.albumsVideoView.collectionView.delegate = self;
    self.albumsVideoView.collectionView.dataSource = self;
    [self.view addSubview:self.albumsVideoView];
    
}

#pragma mark - ================= 各协议方法 ================
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每一段有多少个item


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //1.从复用队列中获取可以服用的cell
    AlbumsVideoViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    AlbumsModel *model = self.dataSource[indexPath.row];
    [cell refreshData:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (isSelect)
    {
        AlbumsModel *model = self.dataSource[indexPath.row];
        if (model.isSelect) {
            model.isSelect = NO;
        }
        else
        {
            model.isSelect = YES;
        }
        
        [self.albumsVideoView.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        AlbumsModel *model = self.dataSource[indexPath.row];
        NSString *fileName = model.imageName;
        
        if ([fileName containsString:@"CyclePhoto"]) {

            fileName = [self cyclePhoto_PathChangeCycleVideo_Path:fileName];//取得视频路径
            
        }else{
        
            fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
            fileName = [fileName componentsSeparatedByString:@"_"][0];
            
            NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
            
            for (NSString *str in pathArr)
            {
                
                if ([str containsString:fileName])
                {
                    fileName = str;
                    break;
                }
            }
            if (![fileName hasSuffix:@".mp4"])
            {
                [self addActityText:@"视频未下载完成,请稍后重试" deleyTime:1];
                return;
            }
        
        }
        
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
        MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        playVC.block = ^{
            
            [weakSelf.dataSource removeAllObjects];
            NSArray *video_PathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
            if (video_PathArr.count)
            {
                NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
                for (int i = 0; i < pathArr.count; i ++)
                {
                    
                    AlbumsModel *model = [[AlbumsModel alloc] init];
                    model.imageName = [pathArr objectAtIndex:i];
                    model.isSelect = NO;
                    model.isShow = NO;
                    
                    NSString *fileName = model.imageName;
                    fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                    fileName = [fileName componentsSeparatedByString:@"_"][0];
                    
                    NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
                    
                    for (NSString *str in pathArr)
                    {
                        
                        if ([str containsString:fileName])
                        {
                            fileName = str;
                            break;
                        }
                    }
                    if ([fileName hasSuffix:@".mp4"])
                    {
                        [weakSelf.dataSource addObject:model];
                    }
                    
                }
                //循环视频
                NSArray *cycleVideo_PathArr =[MyTools getAllDataWithPath:CycleVideo_Path(nil) mac_adr:nil];
                if (cycleVideo_PathArr.count) {
                    NSArray *cyclePhoto_PathArr =[MyTools getAllDataWithPath:CyclePhoto_Path(nil) mac_adr:nil];
                    for (int i = 0; i < cyclePhoto_PathArr.count; i ++){
                        AlbumsModel *model = [[AlbumsModel alloc] init];
                        model.imageName = [cyclePhoto_PathArr objectAtIndex:i];
                        model.isSelect = NO;
                        model.isShow = NO;
                        [self.dataSource addObject:model];
                    }
                    
                }
                
                weakSelf.dataSource = [weakSelf newArray:weakSelf.dataSource];
            }

            [self.albumsVideoView.collectionView reloadData];
        };
        playVC.videoURL = sourceMovieURL;
        playVC.imageURL = model.imageName;
        playVC.superVC = self;
        [self.navigationController pushViewController:playVC animated:YES];
    }
}

//删除文件

-(BOOL)deleteDirInCache:(NSString *)dirName
{
    BOOL isDeleted = NO;
    //不存在就下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirName])
    {
        isDeleted = [[NSFileManager defaultManager] removeItemAtPath:dirName error:nil];

        return isDeleted;
    }
    return isDeleted;
}


@end
