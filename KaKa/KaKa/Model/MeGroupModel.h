//
//  MeGroupModel.h
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeGroupModel : NSObject
@property (nonatomic, copy) NSString *header;//头
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *footer;//尾
@end
