//
//  AlbumsTravelReviewModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsTravelReviewModel : NSObject

@property (nonatomic, assign) BOOL isOpen; // 是否打开

@property (nonatomic, copy) NSString *time; // 时间
@property (nonatomic, strong) NSMutableArray *dataSource; // 数据

@property (nonatomic, assign) NSInteger index; // 坐标 0开始 2结束 1其他
@end
