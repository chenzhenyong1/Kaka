//
//  BreakRuleCell.h
//  Test
//
//  Created by Jim on 16/7/27.
//  Copyright © 2016年 JIm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EyeBreakRuleModel;

@interface EyeBreakRuleCell : UITableViewCell

- (void)refreshUIWithModel:(EyeBreakRuleModel *)model;

/** 是否显示向右的箭头，默认显示 */
- (void)isShowRightArrow:(BOOL)show;

@end
