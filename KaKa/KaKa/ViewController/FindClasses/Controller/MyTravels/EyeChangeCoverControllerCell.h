//
//  EyeChangeCoverControllerCell.h
//  KaKa
//
//  Created by 陈振勇 on 16/9/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EyeChangeCoverControllerCell;
@class EyeChangeSelectedPicModel;
typedef void(^selectedBlock)(EyeChangeCoverControllerCell *cell);
@interface EyeChangeCoverControllerCell : UICollectionViewCell


///** 选中cell */
@property (nonatomic, copy) selectedBlock touchBlock;

/** 是否选中  */
//@property (nonatomic, assign) BOOL isSelected;

/** 封面选择按钮 */
@property (nonatomic, weak) UIButton *selectedBtn;
- (void)refreshUI:(EyeChangeSelectedPicModel *)model;

@end
