//
//  EyeMyVideoController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeMyVideoController.h"
#import "EyeVideoEditController.h"
#import "EyeMyVideoControllerCellCollectionViewCell.h"
#import "MyTools.h"
#import "VideoListModel.h"
#import "EyeVideoListView.h"

@interface EyeMyVideoController ()<UICollectionViewDataSource, UICollectionViewDelegate>



@property(nonatomic, strong) EyeVideoListView *videoListView;

@end

static NSString * const videoCellId = @"EyeMyVideoControllerCellCollectionViewCell";

@implementation EyeMyVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频列表";
    self.view.backgroundColor = ZYGlobalBgColor;

    
    //创建UI布局
    [self createUI];
    
    
}


#pragma mark -- private
/**
 *  创建瀑布流
 */
- (void)createUI
{
    self.videoListView = [[EyeVideoListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //注册cell
    [self.videoListView.collectionView registerClass:[EyeMyVideoControllerCellCollectionViewCell class] forCellWithReuseIdentifier:videoCellId];
    self.videoListView.collectionView.delegate = self;
    self.videoListView.collectionView.dataSource = self;
    [self.view addSubview:self.videoListView];

}



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
    EyeMyVideoControllerCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoCellId forIndexPath:indexPath];

    VideoListModel *model = self.dataSource[indexPath.row];
    [cell refreshData:model];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    VideoListModel *model = self.dataSource[indexPath.row];
    NSString *fileName = model.imageName;
    if ([fileName containsString:@"CyclePhoto"]) {
        
        fileName = [self cyclePhoto_PathChangeCycleVideo_Path:fileName];
        
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
    
    
    
    // 跳转到视频编辑页面
    EyeVideoEditController *videoEditCtl = [[EyeVideoEditController alloc] init];
    
    videoEditCtl.originalVideoPath = fileName;
    
    [self.navigationController pushViewController:videoEditCtl animated:YES];
    
    
}

#pragma mark -- property

-(NSArray *)dataSource
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

- (NSString *)cyclePhoto_PathChangeCycleVideo_Path:(NSString *)cyclePhoto_Path
{
    cyclePhoto_Path = [cyclePhoto_Path componentsSeparatedByString:@"/"].lastObject;
    cyclePhoto_Path = [cyclePhoto_Path componentsSeparatedByString:@"."][0];
    cyclePhoto_Path = [cyclePhoto_Path stringByAppendingString:@".MP4"];
    NSArray *pathArr =[MyTools getAllDataWithPath:CycleVideo_Path(nil) mac_adr:nil];
    
    for (NSString *str in pathArr)
    {
        
        if ([str containsString:cyclePhoto_Path])
        {
            cyclePhoto_Path = str;
            break;
        }
    }
    return cyclePhoto_Path;
}

@end
