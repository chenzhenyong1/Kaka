//
//  EyeSelectedAdressController.h
//  KaKa
//
//  Created by 陈振勇 on 16/10/19.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"

typedef void(^getAddressBlock)(NSString *address);
@interface EyeSelectedAdressController : EyeBaseViewController

@property (nonatomic, copy) getAddressBlock addressBlock;

@end
