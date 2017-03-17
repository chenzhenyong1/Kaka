//
//  EyeMyVideoController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EyeMyVideoController : UIViewController

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;


- (NSString *)cyclePhoto_PathChangeCycleVideo_Path:(NSString *)cyclePhoto_Path;

@end
