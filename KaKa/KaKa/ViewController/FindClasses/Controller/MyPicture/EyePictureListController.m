//
//  EyePictureListController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyePictureListController.h"

#import "MyTools.h"
#import "EyeMyPictureController.h"

@interface EyePictureListController ()<UICollectionViewDataSource, UICollectionViewDelegate>




@end

@implementation EyePictureListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = ZYGlobalBgColor;
    
    NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
    for (int i = 0; i < pathArr.count; i ++)
    {
        
        EyePictureListModel *model = [[EyePictureListModel alloc] init];
        model.imageName = [pathArr objectAtIndex:i];
        model.isSelect = NO;
        
        [self.dataSource addObject:model];
    }
    [self newArray:self.dataSource];

    [self.view addSubview:self.collectionView];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNav];
}

- (void)setupNav
{
    [self setupNavBar];
    
    self.title = @"图片列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
}


- (void)rightItemClick
{
    //跳到图片分享页面
    
    if (self.shareSource.count == 0) {
        [self addActityText:@"请选择图片" deleyTime:0.5];
        
        return;
    }
    
    
    EyeMyPictureController *picCtl = [EyeMyPictureController new];
    
    picCtl.picArr = self.shareSource;
    
    [self.navigationController pushViewController:picCtl animated:YES];
}


//遍历数组，将游戏专题数据按orderNum重新排序
- (void)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(EyePictureListModel *obj1, EyePictureListModel *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj2.imageName] longLongValue]] compare:[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj1.imageName] longLongValue]]];
        return result;
    }];
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:sortedArray];
    
    [self.collectionView reloadData];
    
}

//获取时间
- (NSString *)getTimeWithFilePath:(NSString *)filePath
{
    
    NSString *file_path = [filePath componentsSeparatedByString:@"/"].lastObject;
    file_path = [file_path componentsSeparatedByString:@"."].firstObject;
    if ([file_path hasPrefix:@"G"])
    {
        file_path = [file_path substringFromIndex:1];
    }
    return file_path;
    
}

#pragma mark -- property

- (NSMutableArray *)shareSource {
    
    if (!_shareSource) {
        _shareSource = [NSMutableArray array];
    }
    
    return _shareSource;
}


- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        CGFloat minimumInteritemSpacing = (SCREEN_WIDTH - 3 * 240 * PSDSCALE_X) / 6;
        CGFloat margin = 2 * minimumInteritemSpacing;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(240 * PSDSCALE_X, 240 * PSDSCALE_X);
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing;
        flowLayout.minimumLineSpacing = minimumInteritemSpacing;
        flowLayout.sectionInset = UIEdgeInsetsMake(12 * PSDSCALE_Y, margin, 12 * PSDSCALE_Y, margin);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = self.view.backgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[EyePictureListCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    
    return _collectionView;
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kidentifier = @"Cell";
    
    EyePictureListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kidentifier forIndexPath:indexPath];
    [cell refreshData:self.dataSource[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
   
    
    EyePictureListModel *model = self.dataSource[indexPath.row];
    if (model.isSelect) {
        model.isSelect = NO;
        
        [self.shareSource removeObject:model];
        
    }
    else
    {
        model.isSelect = YES;
        if (self.shareSource.count == 9) {
            
            [self addActityText:@"最多只能分享9张图片" deleyTime:0.5];
            
            return;
        }
        
        [self.shareSource addObject:model];
    }

    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    

    
}

@end
