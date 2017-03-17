//
//  EyeBreakRuleTextFieldCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/13.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EyeBreakRuleModel;
@interface EyeBreakRuleTextFieldCell : UITableViewCell


- (void)refreshUIWithModel:(EyeBreakRuleModel *)model;

/** 是否显示向右的箭头，默认显示 */
- (void)isShowRightArrow:(BOOL)show;

/** 输入的文字回调 */
@property (nonatomic, copy) void (^textfieldBlock)(NSString *text);

@end
