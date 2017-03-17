//
//  CameraSettingViewController.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^recordBlock)(NSString *text);

@interface CameraSettingViewController : BaseViewController
@property (nonatomic, strong) UIViewController *superVC;

@property (nonatomic, copy) recordBlock block;

@end
