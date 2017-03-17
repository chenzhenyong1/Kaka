//
//  CameraAccelerationSensorSensitivityViewController.h
//  KaKa
//
//  Created by Change_pan on 16/8/11.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^RefreshBlock)(NSString *str);

@interface CameraAccelerationSensorSensitivityViewController : BaseViewController
@property (nonatomic, strong) NSString *detailString;
@property (nonatomic, copy) RefreshBlock block;
@end
