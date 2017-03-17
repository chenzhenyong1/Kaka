//
//  AlbumsVideoView.m
//  KaKa
//
//  Created by Change_pan on 16/7/30.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsVideoView.h"

@implementation AlbumsVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatCollctionView];
    }
    return self;
}

- (void)creatCollctionView
{
    
    //设置流式布局
    CGFloat margin = 5;
    CGFloat space = 3;
    CGFloat photoWidth = (SCREEN_WIDTH - 2 * (margin + space)) / 3;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //设置item间距（水平情况下为行间距）
    flowLayout.minimumLineSpacing = space;
    //设置item间距（水平情况下为行间距）
    flowLayout.minimumInteritemSpacing = space;
    //设置item的大小
    flowLayout.itemSize = CGSizeMake(photoWidth, photoWidth);
    //设置全局的间距
    flowLayout.sectionInset = UIEdgeInsetsMake(12 * PSDSCALE_Y, margin, 12 * PSDSCALE_Y, margin);
    
    //UICollectionView -- 提供内容
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
//    self.collectionView.pagingEnabled = YES;
    
    [self addSubview:self.collectionView];
}

@end
