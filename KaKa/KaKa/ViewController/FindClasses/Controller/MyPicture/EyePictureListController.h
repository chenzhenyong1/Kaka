//
//  EyePictureListController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"
#import "EyePictureListCell.h"
#import "EyePictureListModel.h"

@interface EyePictureListController : EyeBaseViewController


@property (nonatomic, strong) NSMutableArray *dataSource;

/** 要分享的图片数组 */
@property (nonatomic, strong) NSMutableArray *shareSource;

@property (nonatomic, strong) UICollectionView *collectionView;


@end
