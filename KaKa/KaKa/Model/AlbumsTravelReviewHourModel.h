//
//  AlbumsTravelReviewHourModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/31.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsTravelReviewHourModel : NSObject

@property (nonatomic, copy) NSString *date;//游记日期
@property (nonatomic, copy) NSString *time; // 时间
@property (nonatomic, strong) NSArray *dataSource; // 数据
@end
