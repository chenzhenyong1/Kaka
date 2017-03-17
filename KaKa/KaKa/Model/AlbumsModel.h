//
//  AlbumsModel.h
//  KaKa
//
//  Created by Change_pan on 16/8/3.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumsModel : NSObject
@property (nonatomic, assign) BOOL isSelect;//是否选择
@property (nonatomic, assign) BOOL isShow;//是否显示按钮
@property (nonatomic, strong) NSString *imageName;
@end
