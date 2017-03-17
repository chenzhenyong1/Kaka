//
//  EyeAddPictureController.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyePictureListController.h"

typedef void(^addPicBlock)(NSArray *picArr);
@interface EyeAddPictureController : EyePictureListController


/** 图片数组 */
@property (nonatomic, strong) NSArray *dataArr;


/** 点击确定返回图片数组 */
@property (nonatomic, copy) addPicBlock addPicCtlBlock;

@end
