//
//  AlbumsPhotoViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsPhotoViewController.h"
#import "AlbumsPhotoCollectionViewCell.h"

#import "MyTools.h"
#import "AlbumsModel.h"
#import "FMDBTools.h"
#import "LHPhotoBrowser.h"
@interface AlbumsPhotoViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AlbumsPhotoViewController
{
    UIView *rightBtnBg;//右侧按钮
    BOOL isSelect;//是否选择
}


- (void)dealloc
{
    MMLog(@"释放");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    [self addTitleWithName:@"照片列表" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
//    CameraListModel *model = [SettingConfig shareInstance].currentCameraModel;
    NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
    for (int i = 0; i < pathArr.count; i ++)
    {
        
        AlbumsModel *model = [[AlbumsModel alloc] init];
        model.imageName = [pathArr objectAtIndex:i];
        model.isSelect = NO;
        model.isShow = NO;
        [self.dataSource addObject:model];
    }
    [self newArray:self.dataSource];
    
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
    
    [self.view addSubview:self.collectionView];
    
    
}

//遍历数组，将游戏专题数据按orderNum重新排序
- (void)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(AlbumsModel *obj1, AlbumsModel *obj2) {
        
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
    [self.collectionView reloadData];
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
        [self addActityText:@"请选择照片" deleyTime:1];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要删除照片吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
                [self addActityText:@"请选择照片" deleyTime:1];
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
                    
                    //数据库中是否存在
                    if ([FMDBTools selectContactMember:model.imageName userName:UserName])
                    {
                        [FMDBTools deleteCollectWithimageUrl:model.imageName];
                    }
                    if (isDel) {
                        [self addActityText:@"删除成功" deleyTime:1];
                        MMLog(@"删除成功");
                    }
                    else
                    {
                        [self addActityText:@"删除失败" deleyTime:1];
                        MMLog(@"删除失败");
                    }
                }
            }
            [self.collectionView reloadData];
        }
            break;
            
        default:
            break;
    }
}


- (void)rightButtonAction
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtnBg];
    isSelect = YES;
    for (AlbumsModel *model in self.dataSource)
    {
        model.isShow = YES;
    }
    [self.collectionView reloadData];
}


- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {

        CGFloat margin = 5;
        CGFloat space = 3;
        CGFloat photoWidth = (SCREEN_WIDTH - 2 * (margin + space)) / 3;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = space;
        flowLayout.minimumInteritemSpacing = space;
        flowLayout.itemSize = CGSizeMake(photoWidth, photoWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(12 * PSDSCALE_Y, margin, 12 * PSDSCALE_Y, margin);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = self.view.backgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[AlbumsPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kidentifier = @"Cell";
    
    AlbumsPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kidentifier forIndexPath:indexPath];
    [cell refreshData:self.dataSource[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (isSelect)
    {
        AlbumsModel *model = self.dataSource[indexPath.row];
        if (model.isSelect)
        {
            model.isSelect = NO;
        }
        else
        {
            model.isSelect = YES;
        }
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        NSMutableArray *image_arr = [NSMutableArray array];
        NSMutableArray *image_url_arr = [NSMutableArray array];
        LHPhotoBrowser *bc = [[LHPhotoBrowser alloc] init];
        for (int i=0; i<[_dataSource count]; i++)
        {
            AlbumsModel *model = _dataSource[i];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
            [image_url_arr addObject: model.imageName];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 800*PSDSCALE_Y, SCREEN_WIDTH, 300*PSDSCALE_Y)];
            imageView.image = image;
            [image_arr addObject:imageView];
        }
        AlbumsModel *_model = self.dataSource[indexPath.row];
        NSArray *temp_arr = [_model.imageName componentsSeparatedByString:@"/"];
        for (int i = 0; i < temp_arr.count; i ++) {
            if ([UserName isEqualToString:temp_arr[i]])
            {
                bc.mac_adr = temp_arr[i+1];
                break;
            }
        }
        bc.imgsArray = image_arr;
        bc.albumsPhotoSource = [self.dataSource mutableCopy];
        //    bc.imgUrlsArray = image_url_arr;
        bc.tapImgIndex = (int)indexPath.row;
        bc.hideStatusBar = NO;
        bc.superVc = self;
        bc.block = ^{
            
            [self.dataSource removeAllObjects];
            NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
            for (int i = 0; i < pathArr.count; i ++)
            {
                
                AlbumsModel *model = [[AlbumsModel alloc] init];
                model.imageName = [pathArr objectAtIndex:i];
                model.isSelect = NO;
                model.isShow = NO;
                [self.dataSource addObject:model];
            }
            [self newArray:self.dataSource];
            
        };
        [bc showWithPush:self]; //push方式
        

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
