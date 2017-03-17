//
//  EyeCheckTravelsController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeCheckPictureController.h"

@class AlbumsTravelModel;
@interface EyeCheckTravelsController : EyeCheckPictureController

@property (nonatomic, strong) AlbumsTravelModel *model;

/** 封面图片名字 */
@property (nonatomic, copy) NSString *coverImageName;
@end
