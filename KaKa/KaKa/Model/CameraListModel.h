//
//  CameraListModel.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/23.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraListModel : NSObject

@property (nonatomic, copy) NSString *macAddress; // mac地址

@property (nonatomic, copy) NSString *ipAddress; // ip地址

@property (nonatomic, copy) NSString *name; // 摄像头名字

@property (nonatomic, copy) NSString *userName; // 登录用户名

@property (nonatomic, copy) NSString *bgImage; // 摄像头图片

@property (nonatomic, copy) NSString *addTime; // 添加时间
@property (nonatomic, assign) BOOL is_on_line;//是否在线
@end
