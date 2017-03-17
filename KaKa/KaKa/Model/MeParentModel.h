//
//  MeParentModel.h
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeParentModel : NSObject
@property (nonatomic, copy) NSString *titleImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;

+(instancetype) itemWithTitle:(NSString *)title titleImage:(NSString *)titleImage detail:(NSString *)detail;
@end
