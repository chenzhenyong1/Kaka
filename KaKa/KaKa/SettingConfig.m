//
//  SettingConfig.m
//  LvXin
//
//  Created by wei_yijie on 15/9/1.
//  Copyright (c) 2015年 showsoft. All rights reserved.
//

#import "SettingConfig.h"

@implementation SettingConfig

static SettingConfig *instance;

+ (SettingConfig *)shareInstance{
    @synchronized(self){
        if (instance == nil) {
            instance = [[SettingConfig alloc] init];
        }
    }
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        //语言
        NSString *settingLanguage = [userdefault objectForKey:AppLanguage];
        //没设置
        if (settingLanguage.length < 1) {
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *currentLanguage = [languages objectAtIndex:0];
            [userdefault setObject:currentLanguage forKey:AppLanguage];
            [userdefault synchronize];
            if ([currentLanguage isEqualToString:@"en"]) {
                _languege = English;
            }else if ([currentLanguage isEqualToString:@"zh-Hant"]) {
                _languege = TraditionalChinese;
            }else if ([currentLanguage isEqualToString:@"zh-Hans"]) {
                _languege = SimpleChinese;
            }
        }else{
            if ([settingLanguage isEqualToString:@"zh-Hans"]) {
                _languege = SimpleChinese;
            }else if ([settingLanguage isEqualToString:@"zh-Hant"]) {
                _languege = TraditionalChinese;
            }else if ([settingLanguage isEqualToString:@"en"]) {
                _languege = English;
            }
        }
        //字号
        NSString *settingFontSize = [userdefault objectForKey:AppFontSize];
        if (settingFontSize.length < 1) {
            [userdefault setObject:@"normal" forKey:AppFontSize];
            [userdefault synchronize];
            _fontSize = Normal;
        }else{
            if ([settingFontSize isEqualToString:@"superbig"]) {
                _fontSize = SuperBig;
            }else if ([settingFontSize isEqualToString:@"big"]) {
                _fontSize = Big;
            }else if ([settingFontSize isEqualToString:@"normal"]) {
                _fontSize = Normal;
            }else if ([settingFontSize isEqualToString:@"small"]) {
                _fontSize = Small;
            }
            
        }
        
        _isLogin = [userdefault boolForKey:@"isLogin"];
        _passWord = [userdefault objectForKey:@"passWord"];
        _phone = [userdefault objectForKey:@"phone"];
        _isLogout = [userdefault boolForKey:@"isLogout"];
        _isOpen = [userdefault boolForKey:@"isOpen"];
        _isPhotoWithVideo = [userdefault boolForKey:@"isPhotoWithVideo"];
        _loginToken = [userdefault objectForKey:@"LoginToken"];
        _isDownload = [userdefault objectForKey:@"isDownload"];
        _mac_address = [userdefault objectForKey:@"mac_address"];
        
    }
    return self;
}
+ (void)releaseInstance{
    instance = nil;
}
- (void)setLanguege:(LanguageType)languege{
    if (languege == SimpleChinese) {
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        _languege = SimpleChinese;
    }else if (languege == TraditionalChinese) {
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hant" forKey:AppLanguage];
        _languege = TraditionalChinese;
    }else if (languege == English) {
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
        _languege = English;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGELANGUAGE" object:nil];
}

- (void)setFontSize:(FontType)fontSize{
    if (fontSize == SuperBig) {
        [[NSUserDefaults standardUserDefaults] setObject:@"superbig" forKey:AppFontSize];
        _fontSize = SuperBig;
    }else if (fontSize == Big) {
        [[NSUserDefaults standardUserDefaults] setObject:@"big" forKey:AppFontSize];
        _fontSize = Big;
    }else if (fontSize == Normal) {
        [[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:AppFontSize];
        _fontSize = Normal;
    }else if (fontSize == Small) {
        [[NSUserDefaults standardUserDefaults] setObject:@"small" forKey:AppFontSize];
        _fontSize = Small;
    }
    
}

- (void)setLoginToken:(NSString *)loginToken {
    _loginToken = loginToken;
    if (loginToken) {
        [UserDefaults setObject:loginToken forKey:@"LoginToken"];
        [UserDefaults synchronize];
    }
}

- (void)setIsLogin:(BOOL)isLogin
{
    _isLogin = isLogin;
    [UserDefaults setBool:isLogin forKey:@"isLogin"];
    [UserDefaults removeObjectForKey:@"isvip"];
    [UserDefaults synchronize];
}

- (void)setIsOpen:(BOOL)isOpen
{
    _isOpen = isOpen;
    [UserDefaults setBool:isOpen forKey:@"isOpen"];
    [UserDefaults synchronize];
}

- (void)setIsPhotoWithVideo:(BOOL)isPhotoWithVideo
{
    _isPhotoWithVideo = isPhotoWithVideo;
    [UserDefaults setBool:isPhotoWithVideo forKey:@"isPhotoWithVideo"];
    [UserDefaults synchronize];
}

- (void)setIsLogout:(BOOL)isLogout
{
    _isLogout = isLogout;
    [UserDefaults setBool:isLogout forKey:@"isLogout"];
    [UserDefaults synchronize];
}

- (void)setPhone:(NSString *)phone
{
    _phone = phone;
    [UserDefaults setObject:phone forKey:@"phone"];
    [UserDefaults synchronize];
}

- (void)setPassWord:(NSString *)passWord
{
    _passWord = passWord;
    [UserDefaults setObject:passWord forKey:@"passWord"];
    [UserDefaults synchronize];
}

- (void)setIsDownload:(NSString *)isDownload
{
    _isDownload = isDownload;
    [UserDefaults setObject:isDownload forKey:@"isDownload"];
    [UserDefaults synchronize];
}

-(void)setMac_address:(NSString *)mac_address
{
    _mac_address = mac_address;
    [UserDefaults setObject:mac_address forKey:@"mac_address"];
    [UserDefaults synchronize];
}




@end
