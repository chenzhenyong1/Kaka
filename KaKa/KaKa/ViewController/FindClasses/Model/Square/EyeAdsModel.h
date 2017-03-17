//
//  EyeAdsModel.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/29.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EyeAdsModel : NSObject<NSCoding>

/** 广告ID */
@property (nonatomic, copy) NSString *ID;
/** 封面宽度 */
@property (nonatomic, copy) NSString *coverWidth;
/** 封面高度 */
@property (nonatomic, copy) NSString *coverHeight;
/** 封面URL */
@property (nonatomic, copy) NSString *coverUrl;
/** 封面类型，为以下常量之一：
 代码	意义
 img	图片
 page	页面
 */
@property (nonatomic, copy) NSString *coverType;
/** 点击封面后的跳转URL */
@property (nonatomic, copy) NSString *jumpUrl;

/** 图片描述 */
@property (nonatomic, copy) NSString *desc;


@end
