//
//  PRGCookieManager.h
//  PayRent
//
//  Created by Change_pan on 16/5/3.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRGCookieManager : NSObject

+ (void)saveCookies;//保存cookie

+ (void)setCookie;//设置cookie

//删除cookie
+(void)deleteCokie;

@end
