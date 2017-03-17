//
//  EyeCheckPictureController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"

@class EyeAddressModel;
@interface EyeCheckPictureController : EyeBaseViewController

/** 数据源 */
@property (nonatomic, strong) NSArray *dataArr;

/** 地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;

@end
