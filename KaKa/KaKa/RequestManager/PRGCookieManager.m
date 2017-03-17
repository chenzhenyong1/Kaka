//
//  PRGCookieManager.m
//  PayRent
//
//  Created by Change_pan on 16/5/3.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "PRGCookieManager.h"

@implementation PRGCookieManager

+ (void)saveCookies
{
    /*
     * 把cookie进行归档并转换为NSData类型
     * 注意：cookie不能直接转换为NSData类型，否则会引起崩溃。
     * 所以先进行归档处理，再转换为Data
     */
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    
    //存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: cookiesData forKey: @"cookie"];
    [userDefaults synchronize];
    
    
    
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"cookie"]];
    MMLog(@"%@",cookies);
}


+ (void)setCookie
{
//    NSLog(@"============再取出保存的cookie重新设置cookie===============");
    //取出保存的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"cookie"]];
    
    if (cookies.count) {
//        NSLog(@"有cookie");
        
        //设置cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookies) {
            
            [cookieStorage setCookie:cookie];
        }
    }else{
//        NSLog(@"无cookie");
    }
    
    //打印cookie，检测是否成功设置了cookie
//    NSArray *cookiesA = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    for (NSHTTPCookie *cookie in cookiesA) {
//        NSLog(@"setCookie: %@", cookie);
//    }
//    NSLog(@"\n");
    
}

//删除cookie
+(void)deleteCokie
{
    // 删除本地缓存cookies
    [UserDefaults removeObjectForKey:@"cookie"];
    [UserDefaults synchronize];
    
    // 删除所有的cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSArray arrayWithArray:[cookieStorage cookies]];
    for (id obj in cookies) {
        [cookieStorage deleteCookie:obj];
    }

}





@end
