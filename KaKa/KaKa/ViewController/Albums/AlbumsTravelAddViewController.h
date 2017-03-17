//
//  AlbumsTravelAddViewController.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/29.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "AlbumsTravelModel.h"

@interface AlbumsTravelAddViewController : BaseViewController

@property (nonatomic, strong) AlbumsTravelModel *model;
// 游记数据源
@property (nonatomic, strong) NSMutableArray *travelDetailArray;
@end
