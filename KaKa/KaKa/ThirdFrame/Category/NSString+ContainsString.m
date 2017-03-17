//
//  NSString.m
//  MoMo
//
//  Created by wei_yijie on 16/4/13.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "NSString+ContainsString.h"

@implementation NSString (ContainsString)

- (BOOL)containsString:(NSString *)str{
    if ([self rangeOfString:str].location != NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

@end
