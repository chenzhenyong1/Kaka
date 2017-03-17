//
//  EyeChangeCoverController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeChangeCoverController.h"
#import "EyeChangeCoverControllerCell.h"
#import "EyeChangeSelectedPicModel.h"

@interface EyeChangeCoverController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/** 封面 */
@property (nonatomic, weak) UIImageView *coverImageView;
/** 图片选择的collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 封面数据 */
@property (nonatomic, strong) AlbumsTravelDetailModel *coverModel;

/** 过滤掉的detailModel数组 */
@property (nonatomic, strong) NSArray *travelDetailArray;

@end

@implementation EyeChangeCoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取数据源
    [self dataSource];
    
    [self coverImageView];
    
    [self collectionView];
    
   
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置导航栏
    [self setupNav];
}

/**
 *  设置导航栏
 */
- (void)setupNav
{
    self.title = @"封面选择";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemClick
{
    ZYLog(@"点击完成");
    self.imageBlock(self.coverModel);
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EyeChangeCoverControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EyeChangeCoverControllerCell" forIndexPath:indexPath];
    EyeChangeSelectedPicModel *model = self.dataSource[indexPath.row];
    //    cell.backgroundColor = [UIColor purpleColor];
    [cell refreshUI: model];
    
//    cell.isSelected = NO;
    __weak typeof (self)weakSelf = self;
    cell.touchBlock = ^(EyeChangeCoverControllerCell *selectedCell){
        
        
        for (UIView *view in collectionView.subviews) {
            
            if ([view isKindOfClass:[EyeChangeCoverControllerCell class]]) {
                
                EyeChangeCoverControllerCell *cell = (EyeChangeCoverControllerCell *)view;
                
                cell.selectedBtn.selected = NO;
                
            }
            
        }
        
        for (EyeChangeSelectedPicModel *model in self.dataSource) {
            model.isSelected = NO;
        }
        
        EyeChangeSelectedPicModel *model = self.dataSource[indexPath.row];
        weakSelf.coverImageView.image = model.image;
        
//         NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
        
        weakSelf.coverModel = self.travelDetailArray[indexPath.row];
        
//        EyeChangeCoverControllerCell *cell = (EyeChangeCoverControllerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        
        
        
    };
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(150 * PSDSCALE_X, 150 * PSDSCALE_Y);
}
//间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    
   //    self.playView.musicName = self.musicNameArr[indexPath.row];
//    
//    
//    ZYLog(@"indexPath = %ld",(long)indexPath.row);
}


#pragma mark -- 获取游记图片

- (UIImage *)getTraverlPicture:(AlbumsTravelDetailModel *)detailModel
{
    
    NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    
//    ZYLog(@"imagePath = %@",imagePath);
    return image;
}


#pragma mark -- property

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        //1.初始化layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        
        //2.初始化collectionView
        UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, kScreenWidth * 9/16 + STATUSBARHEIGHT + 30, self.view.width - 30 , 150 * PSDSCALE_Y) collectionViewLayout:layout];
        mainCollectionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:mainCollectionView];
        mainCollectionView.backgroundColor = [UIColor clearColor];
        
        //3.注册collectionViewCell   注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
        [mainCollectionView registerClass:[EyeChangeCoverControllerCell class] forCellWithReuseIdentifier:@"EyeChangeCoverControllerCell"];
        //4.设置代理
        mainCollectionView.delegate = self;
        mainCollectionView.dataSource = self;
        
        _collectionView = mainCollectionView;
        
        
    }
    
    return _collectionView;

}


-(UIImageView *)coverImageView
{
    if (!_coverImageView) {
        
        UIImageView *coverImageView = [[UIImageView alloc] init];
        
        EyeChangeSelectedPicModel *model = self.dataSource[0];
        coverImageView.image = model.image;
        
        [self.view addSubview:coverImageView];
        
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.equalTo(self.view);
            
            make.top.equalTo(self.view).offset(STATUSBARHEIGHT);
            
            make.height.equalTo(@(kScreenWidth * 9/16));
        }];
        
        _coverImageView = coverImageView;
    }
    
    return _coverImageView;
}


-(NSMutableArray *)dataSource{

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
        NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
        
        NSMutableArray *arr = [travelDetailArray mutableCopy];
        for (AlbumsTravelDetailModel *detailModel in arr) {
            if (!detailModel.shared) {
                [travelDetailArray removeObject:detailModel];
            }
        }
        self.travelDetailArray = travelDetailArray;
        self.coverModel = travelDetailArray[0];
        
        for (AlbumsTravelDetailModel *detailModel in travelDetailArray)
        {
            
            EyeChangeSelectedPicModel *model = [EyeChangeSelectedPicModel new];
            
            UIImage *image = [self getTraverlPicture:detailModel];
            model.image = image;
            model.isSelected = NO;
            
            [_dataSource addObject:model];
        }

        
    }
    
    return _dataSource;
}

@end





