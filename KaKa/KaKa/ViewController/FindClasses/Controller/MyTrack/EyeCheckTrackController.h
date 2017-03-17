//
//  EyeCheckTrackController.h
//  KaKa
//
//  Created by 陈振勇 on 16/10/10.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeBaseViewController.h"

@class EyeAddressModel;
@class AlbumsPathModel;
@interface EyeCheckTrackController : EyeBaseViewController

/** AlbumsPathModel */
@property (nonatomic, strong) AlbumsPathModel *model;
/** 地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;



@end
