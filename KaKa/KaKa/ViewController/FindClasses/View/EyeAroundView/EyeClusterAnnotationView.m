//
//  EyeClusterAnnotationView.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeClusterAnnotationView.h"

@implementation EyeClusterAnnotationView

@synthesize size = _size;
@synthesize label = _label;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
         [self setBounds:CGRectMake(0.f, 0.f, 58.f, 38.f)];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 10.f, -2.f, 20.f, 20.f)];
//        [self.label sizeToFit];
        _label.textColor = [UIColor whiteColor];
        [_label.layer setMasksToBounds:YES];
        _label.layer.cornerRadius = 10;
        _label.font = [UIFont systemFontOfSize:9];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
    }
    return self;
}


- (void)setSize:(NSInteger)size {
    _size = size;
    if (_size == 1) {
        self.label.hidden = YES;
        
        return;
    }
    self.label.hidden = NO;
    
    self.label.backgroundColor = ZYRGBColor(172, 34, 43);
    
    _label.text = [NSString stringWithFormat:@"%ld", (long)size];
    
//     _label.text = @"100";
//    [self.label sizeToFit];
}

@end
