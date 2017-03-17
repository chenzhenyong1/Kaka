//
//  AlbumsPathModel.h
//  KaKa
//
//  Created by Change_pan on 16/8/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsPathModel : NSObject
@property (nonatomic, copy) NSString *endMileage;//结束里程
@property (nonatomic, copy) NSString *fileName;//文件名  用作图片名称
@property (nonatomic, copy) NSNumber *index;//
@property (nonatomic, copy) NSString *startMileage;//开始里程
@property (nonatomic, copy) NSString *tirpMileage;//结束里程
@property (nonatomic, copy) NSString *tirpTime;//行驶时长
@property (nonatomic, copy) NSString *user_name;//用户名
@property (nonatomic, copy) NSString *mac_adr;//mac地址
@property (nonatomic, copy) NSString *collect;//是否收藏 0未收藏 1收藏
@property (nonatomic, copy) NSString *del;//是否删除
@property (nonatomic, copy) NSString *start_lat;//开始纬度
@property (nonatomic, copy) NSString *start_long;//开始经度
@property (nonatomic, copy) NSString *end_lat;//结束纬度
@property (nonatomic, copy) NSString *end_long;//结束经度
@property (nonatomic, copy) NSString *start_address;//开始地址

@end
