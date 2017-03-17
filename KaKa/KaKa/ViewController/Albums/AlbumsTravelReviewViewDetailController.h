//
//  AlbumsTravelReviewViewDetailController.h
//  KaKa
//
//  Created by Change_pan on 16/8/8.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "AlbumsTravelReviewHourModel.h"

@interface AlbumsTravelReviewViewDetailController : BaseViewController

@property (nonatomic, copy) NSString *cameraMac;//摄像头mac地址
@property (nonatomic, strong) AlbumsTravelReviewHourModel *model;
@end
