//
//  EyePictureChangeController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyePictureChangeController.h"
#import "EyePictureChangeControllerCell.h"
#import "EyePictureListModel.h"

@interface EyePictureChangeController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/** 封面 */
@property (nonatomic, weak) UIImageView *coverImageView;
/** 图片选择的collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;
/** 封面图片名字 */
@property (nonatomic, copy) NSString *coverImageName;

@end

@implementation EyePictureChangeController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏
    [self setupNav];
    
    
    
    [self coverImageView];
    
    [self collectionView];
}


/**
 *  设置导航栏
 */
- (void)setupNav
{
    [self setupNavBar];
    
    self.title = @"封面选择";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
    
}

- (void)rightItemClick
{
    ZYLog(@"点击完成");
//    self.imageBlock(self.coverImageView.image);
    
    self.imageBlock(self.coverImageName);
    
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
    return self.dataArr.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EyePictureChangeControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EyePictureChangeControllerCell" forIndexPath:indexPath];
    
    
    EyePictureListModel *model = self.dataArr[indexPath.row];
//    model.isSelect = NO;
    [cell refreshUI:model];
    
    //    cell.isSelected = NO;
    
    
    
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    EyePictureListModel *selectedModel = self.dataArr[indexPath.row];
    for (EyePictureListModel *model in self.dataArr) {
        if ([selectedModel.imageName isEqualToString:model.imageName]) {
            model.isSelect = YES;
        }else
        {
        
            model.isSelect = NO;
        }
    }
    [self.collectionView reloadData];
    
    
    self.coverImageName = selectedModel.imageName;
    //改变封面
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.coverImageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
            self.coverImageView.image = [UIImage imageWithData:imageData];
            
        });
    });
    
    
    
//    selectedModel.isSelect = YES;
    
    
    

}

#pragma mark -- property

-(void)setDataArr:(NSArray *)dataArr
{
    _dataArr = dataArr;
    
    for (EyePictureListModel *model in self.dataArr) {
        
        model.isSelect = NO;

    }

}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        //1.初始化layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.itemSize =CGSizeMake(50, 50);
        
        //2.初始化collectionView
        UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, kScreenWidth * 9/16 + STATUSBARHEIGHT + 30, self.view.width - 30 , 150 * PSDSCALE_Y) collectionViewLayout:layout];
        mainCollectionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:mainCollectionView];
        mainCollectionView.backgroundColor = [UIColor clearColor];
        
        //3.注册collectionViewCell   注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
        [mainCollectionView registerClass:[EyePictureChangeControllerCell class] forCellWithReuseIdentifier:@"EyePictureChangeControllerCell"];
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
        
//        coverImageView.image = self.dataArr[0];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self.dataArr[0] imageName]];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.coverImageView.image = [UIImage imageWithData:imageData];
                
            });
        });
        
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
@end
