//
//  AlbumsPathDetailViewController.h
//  KaKa
//
//  Created by Change_pan on 16/8/3.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "AlbumsPathModel.h"

typedef void(^RefreshDataBlock)();

@interface AlbumsPathDetailViewController : BaseViewController
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) AlbumsPathModel *model;
@property (nonatomic, weak) UIViewController *superVC;
@property (nonatomic, copy) RefreshDataBlock block;
@end
