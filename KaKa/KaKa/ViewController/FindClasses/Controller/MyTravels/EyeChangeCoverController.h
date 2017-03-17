//
//  EyeChangeCoverController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"


typedef void(^coverImageBlock)(AlbumsTravelDetailModel *coverModel);
@interface EyeChangeCoverController : EyeBaseViewController


@property (nonatomic, strong) AlbumsTravelModel *model;

/** 更换封面完成后的回调 */
@property (nonatomic, copy) coverImageBlock imageBlock;


@end
