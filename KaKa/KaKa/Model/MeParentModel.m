//
//  MeParentModel.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeParentModel.h"

@implementation MeParentModel

+(instancetype) itemWithTitle:(NSString *)title titleImage:(NSString *)titleImage detail:(NSString *)detail
{
    MeParentModel *model = [[self alloc] init];
    model.title = title;
    model.titleImage = titleImage;
    model.detail = detail;
    return model;
}
@end
