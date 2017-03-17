//
//  MeSettingAppCaCheViewController.h
//  KaKa
//
//  Created by Change_pan on 16/7/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CaCheBlock)(NSString *text);

@interface MeSettingAppCaCheViewController : BaseViewController

@property (nonatomic, copy) CaCheBlock block;

@end
