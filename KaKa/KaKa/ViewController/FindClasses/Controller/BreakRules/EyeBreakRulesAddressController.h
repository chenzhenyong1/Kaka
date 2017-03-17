//
//  EyeBreakRulesAddressController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/13.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章地点的选择页面

#import "EyeBaseViewController.h"
@class EyeAddressModel;
@interface EyeBreakRulesAddressController : EyeBaseViewController

/** 违章位置选择 */
@property (nonatomic, copy) void(^changeAddressBlock)(EyeAddressModel *addressModel);

@end
