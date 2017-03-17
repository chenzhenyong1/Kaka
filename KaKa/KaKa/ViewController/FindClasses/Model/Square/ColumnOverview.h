//
//  ColumnOverview.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColumnBrief.h"


@interface ColumnOverview : NSObject<NSCoding>

/** ColumnBrief */
@property (nonatomic, strong) ColumnBrief *columnBrief;

/** imgViews数组 */
@property (nonatomic, strong) NSArray *imgViews;

@end
