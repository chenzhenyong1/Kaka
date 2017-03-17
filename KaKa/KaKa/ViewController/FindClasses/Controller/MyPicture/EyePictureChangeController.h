//
//  EyePictureChangeController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"


typedef void(^imageBlock)(NSString *imageName);
@interface EyePictureChangeController : EyeBaseViewController


@property (nonatomic, strong) NSArray *dataArr;

/** 点击完成回调 */
@property (nonatomic, copy) imageBlock imageBlock;

@end
