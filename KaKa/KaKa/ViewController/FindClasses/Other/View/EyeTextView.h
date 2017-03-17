//
//  EyeTextView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/23.
//  Copyright © 2016年 陈振勇. All rights reserved.

//  自定义带有placeHolder的UITextView

#import <UIKit/UIKit.h>

@interface EyeTextView : UITextView

@property(nonatomic, copy)NSString *placeholder;
@property(nonatomic, strong)UIColor *placeholderColor;

@end
