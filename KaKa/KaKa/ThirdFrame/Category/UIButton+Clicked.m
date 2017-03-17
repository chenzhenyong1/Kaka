//
//  UIButton+Clicked.m
//  LeBeiEr
//
//  Created by wei_yijie on 16/2/25.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "UIButton+Clicked.h"
#import <objc/runtime.h>

@implementation UIButton (Clicked)

- (void)setStateDic:(NSMutableDictionary *)stateDic{
    [self willChangeValueForKey:@"stateDic"];
    objc_setAssociatedObject(self, @"stateDicKey", stateDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"stateDic"];
}

- (NSMutableDictionary *)stateDic{
    return objc_getAssociatedObject(self, @"stateDicKey");
}


- (void)setClickBlock:(void (^)(UIButton *))clickBlock{
    [self willChangeValueForKey:@"clickBlock"];
    objc_setAssociatedObject(self, @"clickBlock_Key", clickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"clickBlock"];
}

- (void (^)(UIButton *))clickBlock{
    return objc_getAssociatedObject(self, @"clickBlock_Key");
}

- (void)addTargetWithBlock:(void(^)(UIButton *sender))clickedAction{
    self.clickBlock = clickedAction;
    [self addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(down_action) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(outside_action) forControlEvents:UIControlEventTouchDragOutside];
}
- (void)down_action{
    self.alpha = 0.6;
}
- (void)outside_action{
    self.alpha = 1;
}
- (void)action{
    self.clickBlock(self);
    self.alpha = 1;
    for (int i = 0; i < [self.stateDic allKeys].count; i++) {
        NSInteger state_save = [[self.stateDic allKeys][i] integerValue];
        UIColor *color_save = [self.stateDic allValues][i];
        NSInteger state = self.state;
        if (!state_save) {
            self.backgroundColor = color_save;
        }
        if (state & state_save) {
            self.backgroundColor = color_save;
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state{
    if (!self.stateDic) {
        self.stateDic = [[NSMutableDictionary alloc] init];
    }
    [self.stateDic setObject:backgroundColor forKey:@(state)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
