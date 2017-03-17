//
//  AlbumsTravelDetailModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsTravelDetailModel : NSObject

@property (nonatomic, assign) NSInteger travelId;//游记Id 跟游记id对应
@property (nonatomic, assign) NSInteger detailId;//游记详情Id
@property (nonatomic, copy) NSString *date;//游记日期
@property (nonatomic, copy) NSString *time;//游记时间
@property (nonatomic, copy) NSString *type;//游记类型 photo、video、Gphoto
@property (nonatomic, copy) NSString *gps;//游记经纬度
@property (nonatomic, copy) NSString *fileName;//对应的文件名

@property (nonatomic, copy) NSString *mood;//心情
@property (nonatomic, assign) BOOL shared;// 是否分享 默认分享
@end
