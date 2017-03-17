//
//  CameraCarBrandViewController.h
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
@class CarBrandModel;
typedef void(^RefreshDataBlock)(CarBrandModel *model);

@interface CameraCarBrandViewController : BaseViewController

@property (nonatomic, copy) RefreshDataBlock block;

@end
