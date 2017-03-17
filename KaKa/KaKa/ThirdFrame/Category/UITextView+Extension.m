//
//  UITextView+Extension.m
//  DuoBaoDai
//
//  Created by 深圳市 秀软科技有限公司 on 16/4/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "UITextView+Extension.h"
#import <objc/runtime.h>

@interface UITextView (ExtensionPrivate)

@property (nonatomic, strong) UILabel *placeHolderLabel;

@end

@implementation UITextView (ExtensionPrivate)

- (void)setPlaceHolderLabel:(UILabel *)placeHolderLabel
{
    return objc_setAssociatedObject(self, @selector(placeHolderLabel), placeHolderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)placeHolderLabel
{
    return objc_getAssociatedObject(self, @selector(placeHolderLabel));
}

@end

@implementation UITextView (Extension)

- (void)setPlaceholder:(NSString *)placeholder
{
    if (!self.placeHolderLabel) {
        [self addPlaceholder];
    }
    self.placeHolderLabel.text = placeholder;
    [self.placeHolderLabel sizeToFit];
    
    return objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)placeholder
{
    return objc_getAssociatedObject(self, @selector(placeholder));
}

- (void)addPlaceholder
{
    UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/12, self.frame.size.width, 0)];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textContainerInset, UIEdgeInsetsZero)) {
        placeHolder.frame = CGRectMake(self.textContainerInset.left+5, self.textContainerInset.top, self.frame.size.width-self.textContainerInset.left-self.textContainerInset.right-5, self.frame.size.height-self.textContainerInset.top-self.textContainerInset.bottom);
    }
    
    
    placeHolder.font = self.font;
    placeHolder.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:206/255.0 alpha:1];
    [self addSubview:placeHolder];
    self.placeHolderLabel = placeHolder;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange) name:UITextViewTextDidChangeNotification object:nil];
    [self addObserver:self forKeyPath:@"textContainerInset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)textViewTextDidChange
{
    if (self.text.length == 0) {
        self.placeHolderLabel.text = self.placeholder;
    } else {
        self.placeHolderLabel.text = nil;
    }
}

- (void)setLeftView:(UIView *)leftView
{
    CGRect leftViewFrame = leftView.frame;
    leftViewFrame.origin.x = 0;
    leftViewFrame.origin.y = 0;
    leftViewFrame.size.height = self.frame.size.height;
    leftView.frame = leftViewFrame;
    [self addSubview:leftView];
    self.clipsToBounds = YES;
    
    self.textContainerInset = UIEdgeInsetsMake(0, leftViewFrame.size.width, 0, self.rightView.frame.size.width);
    
    return objc_setAssociatedObject(self, @selector(leftView), leftView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)leftView
{
    return objc_getAssociatedObject(self, @selector(leftView));
}

- (void)setRightView:(UIView *)rightView
{
    
    CGRect rightViewFrame = rightView.frame;
    rightViewFrame.origin.x = self.frame.size.width-rightViewFrame.size.width;
    rightViewFrame.origin.y = 0;
    rightViewFrame.size.height = self.frame.size.height;
    rightView.frame = rightViewFrame;
    [self addSubview:rightView];
    self.clipsToBounds = YES;
    
    self.textContainerInset = UIEdgeInsetsMake(0, self.leftView.frame.size.width, 0, rightViewFrame.size.width);
    
    return objc_setAssociatedObject(self, @selector(rightView), rightView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)rightView
{
    return objc_getAssociatedObject(self, @selector(rightView));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"textContainerInset"]) {
        if (self.placeHolderLabel) {
            
            self.placeHolderLabel.frame = CGRectMake(self.textContainerInset.left+5, self.textContainerInset.top, self.frame.size.width-self.textContainerInset.left-self.textContainerInset.right-5, self.frame.size.height-self.textContainerInset.top-self.textContainerInset.bottom);
            [self.placeHolderLabel sizeToFit];
        }
        
    }
}

- (void)dealloc
{
    if (self.placeHolderLabel) {
        [self removeObserver:self forKeyPath:@"textContainerInset"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    
}
@end
