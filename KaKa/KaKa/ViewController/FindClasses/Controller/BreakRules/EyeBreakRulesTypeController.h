//
//  EyeBreakRulesTypeController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/16.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EyeBreakRulesTypeController : UITableViewController

/** 违章类型选择 */
@property (nonatomic, copy) void(^breakRulesTypeBlock)(NSString *typeStr);


@end
