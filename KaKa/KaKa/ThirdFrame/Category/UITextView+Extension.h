//
//  UITextView+Extension.h
//  DuoBaoDai
//
//  Created by 深圳市 秀软科技有限公司 on 16/4/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Extension)

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@end
