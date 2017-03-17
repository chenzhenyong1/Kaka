//
//  ColumnBrief.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/18.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColumnBrief : NSObject<NSCoding>


/** 话题栏目ID */
@property (nonatomic, copy) NSString *ID;
/** 话题栏目名称 */
@property (nonatomic, copy) NSString *name;
/** 话题栏目简述 */
@property (nonatomic, copy) NSString *descrption;


//{
//    id : 23,
//    name : 违章举报,
//    descrption : 这是违章举报栏目
//}
@end
