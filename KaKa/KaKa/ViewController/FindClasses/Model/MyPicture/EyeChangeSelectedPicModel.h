//
//  EyeChangeSelectedPicModel.h
//  KaKa
//
//  Created by 陈振勇 on 16/10/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EyeChangeSelectedPicModel : NSObject

/** 图片 */
@property (nonatomic, strong) UIImage *image;

/** 是否选中  */
@property (nonatomic, assign) BOOL isSelected;

@end
