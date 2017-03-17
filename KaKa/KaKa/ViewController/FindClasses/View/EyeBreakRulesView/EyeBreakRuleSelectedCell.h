//
//  BreakRuleSelectedCell.h
//  Test
//
//  Created by Jim on 16/7/27.
//  Copyright © 2016年 JIm. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    
    EyeBreakRuleSelectedCellButtonClickLeft,   //左边
    EyeBreakRuleSelectedCellButtonClickRight   //右边
    
}EyeBreakRuleSelectedCellButtonClick;

@class EyeBreakRuleModel;

@interface EyeBreakRuleSelectedCell : UITableViewCell

- (void)refreshUIWithModel:(EyeBreakRuleModel *)model;

/** 点击按钮Block */
@property (nonatomic, copy) void (^btnClickBlock)(EyeBreakRuleSelectedCellButtonClick btnClick);

@end
