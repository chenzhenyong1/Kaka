//
//  EyePictureChangeControllerCell.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EyePictureListModel;
@interface EyePictureChangeControllerCell : UICollectionViewCell


- (void)refreshUI:(EyePictureListModel *)model;

@end
