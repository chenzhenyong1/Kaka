//
//  LoginViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"
#import "WeChatManager.h"
#import "QQManager.h"
#import "Base.h"

@interface LoginViewController () <QQManagerDelegate>
{
    NSString *captchaId;  //验证码ID
    NSString *captcha;    //验证码
    UIImage *captchaImg;  //验证码图片
}

@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UITextField *pwdTF;
@property (nonatomic, strong) UITextField *codeTF;

@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) UIButton *forgetPwdBtn;

@property (nonatomic, strong) UIButton *codeImageBtn;
@property (nonatomic, assign) BOOL isNeedCode;//是否需要输入验证码
@property (nonatomic, assign) NSUInteger loginFailedTimes;//登录失败次数
@end

@implementation LoginViewController

- (void)dealloc {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [NotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setFd_interactivePopDisabled:NO];
    
    // 添加logo
    [self addLogoView];
    
    [self addLoginView];
    
    [self addThirdLoginView];
    
    self.navigationController.navigationBarHidden = YES;
    
    [NotificationCenter addObserver:self selector:@selector(weChat_login_action:) name:@"WeChat_Auth_Code" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

// 添加logo
- (void)addLogoView {
    UIImage *logoImage = GETNCIMAGE(@"kaKa_logo.png");
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.frame = CGRectMake((SCREEN_WIDTH - logoImage.size.width) / 2, 200 * PSDSCALE_Y, logoImage.size.width, logoImage.size.height);
    [self.view addSubview:logoImageView];
}

// 登录视图
- (void)addLoginView {
    
    [self addInputTextField];
    
    __weak typeof(self) weakSelf = self;
    // 登录按钮
    UIButton *loginBtn = [self buttonWithFrame:CGRectMake(60 * PSDSCALE_X, VIEW_H_Y(_pwdTF) + 107 * PSDSCALE_Y, SCREEN_WIDTH - 2 * 60 * PSDSCALE_X, 97 * PSDSCALE_X) inView:self.view title:@"登 录" titleColorNormal:WHITE_COLOR titleColorSelected:CLEARCOLOR titleFontSize:35 * FONTCALE_Y backgroundNormal:GETNCIMAGE(@"login_btn_bg.png") backgroundSelected:nil cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        [weakSelf loginButtonClicked];
    }];
    _loginBtn = loginBtn;
    
    // 立即注册按钮
    UIButton *registerBtn = [self buttonWithFrame:CGRectMake(60 * PSDSCALE_X, VIEW_H_Y(loginBtn) + 10 * PSDSCALE_Y, 160 * PSDSCALE_X, 63 * PSDSCALE_X) inView:self.view title:@"立即注册!" titleColorNormal:RGBSTRING(@"aaaaaa") titleColorSelected:CLEARCOLOR titleFontSize:25 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        [weakSelf registerButtonClicked];
    }];
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _registerBtn = registerBtn;
    
    // 忘记密码按钮
    UIButton *forgetPwdBtn = [self buttonWithFrame:CGRectMake(VIEW_W_X(loginBtn) - 160 * PSDSCALE_X, VIEW_H_Y(loginBtn) + 10 * PSDSCALE_Y, 160 * PSDSCALE_X, 63 * PSDSCALE_X) inView:self.view title:@"忘记密码!" titleColorNormal:RGBSTRING(@"aaaaaa") titleColorSelected:CLEARCOLOR titleFontSize:25 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        [weakSelf forgetPwdButtonClicked];
    }];
    forgetPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _forgetPwdBtn = forgetPwdBtn;
    
    
    
}

- (void)addInputTextField {
    // 手机号
    UIImage *phoneImage = GETNCIMAGE(@"login_phone_bg.png");
    CGRect phoneImageFrame = CGRectMake(40*PSDSCALE_X, 490*PSDSCALE_Y, SCREEN_WIDTH, (SCREEN_WIDTH - 40*PSDSCALE_X) * phoneImage.size.height / phoneImage.size.width);
    [self imageViewWithFrame:phoneImageFrame inView:self.view image:phoneImage contentMode:0 backgroundColor:CLEARCOLOR cornerRadius:0 borderWidth:0 borderColor:CLEARCOLOR];
    
    CGRect phoneTFFrame = CGRectMake(40*PSDSCALE_X, 482*PSDSCALE_Y, SCREEN_WIDTH-2*40*PSDSCALE_X, (SCREEN_WIDTH - 40*PSDSCALE_X) * phoneImage.size.height / phoneImage.size.width);
    UITextField *phoneTF = [self textFieldWithFrame:phoneTFFrame sizeFont:30 * FONTCALE_Y background:nil keyBoardType:UIKeyboardTypePhonePad placeholder:@"手机号码" placeholdFont:30 * FONTCALE_Y placehodlColor:RGBSTRING(@"4a4a4a") secure:NO inView:self.view];
    phoneTF.tintColor = RGBSTRING((@"ad1e22"));
    phoneTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87*PSDSCALE_X, VIEW_H(phoneTF))];
    phoneTF.leftViewMode = UITextFieldViewModeAlways;
    phoneTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87*PSDSCALE_X, VIEW_H(phoneTF))];
    phoneTF.rightViewMode = UITextFieldViewModeAlways;
    _phoneTF = phoneTF;
    
    // 密码
    UIImage *pwdImage = GETNCIMAGE(@"login_pwd_bg.png");
    CGRect pwdImageFrame = CGRectMake(40 * PSDSCALE_X, VIEW_H_Y(_phoneTF) + 60 * PSDSCALE_Y, SCREEN_WIDTH, (SCREEN_WIDTH - 40 * PSDSCALE_X) * pwdImage.size.height / pwdImage.size.width);
    [self imageViewWithFrame:pwdImageFrame inView:self.view image:pwdImage contentMode:0 backgroundColor:CLEARCOLOR cornerRadius:0 borderWidth:0 borderColor:CLEARCOLOR];
    
    CGRect pwdTFFrame = CGRectMake(40 * PSDSCALE_X, VIEW_H_Y(_phoneTF) + 52 * PSDSCALE_Y, SCREEN_WIDTH - 40 * PSDSCALE_X, (SCREEN_WIDTH - 40 * PSDSCALE_X) * pwdImage.size.height / pwdImage.size.width);
    UITextField *pwdTF = [self textFieldWithFrame:pwdTFFrame sizeFont:30 * FONTCALE_Y background:nil keyBoardType:UIKeyboardTypeDefault placeholder:@"密码" placeholdFont:30 * FONTCALE_Y placehodlColor:RGBSTRING(@"4a4a4a") secure:YES inView:self.view];
    pwdTF.tintColor = RGBSTRING((@"ad1e22"));
    pwdTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87 * PSDSCALE_X, VIEW_H(pwdTF))];
    pwdTF.leftViewMode = UITextFieldViewModeAlways;
    _pwdTF = pwdTF;
    
    __weak typeof(self) weakSelf = self;
    UIButton *eyesBtn = [self buttonWithFrame:CGRectMake(0, 0, 110 * PSDSCALE_X, 87 * PSDSCALE_X) inView:nil title:nil titleColorNormal:CLEARCOLOR titleColorSelected:CLEARCOLOR titleFontSize:0 backgroundNormal:nil backgroundSelected:nil cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        sender.selected = !sender.selected;
        weakSelf.pwdTF.secureTextEntry = !sender.selected;
        
        // 当密码框切换回明文时后面会有一段空白，所以重新设置一下text
        NSString *newPassword = weakSelf.pwdTF.text;
        weakSelf.pwdTF.text = @"";
        weakSelf.pwdTF.text = newPassword;
    }];
    [eyesBtn setImage:GETNCIMAGE(@"login_eyes_btn_sel.png") forState:UIControlStateNormal];
    [eyesBtn setImage:GETNCIMAGE(@"login_eyes_btn_nor.png") forState:UIControlStateSelected];
    pwdTF.rightView = eyesBtn;
    pwdTF.rightViewMode = UITextFieldViewModeAlways;

    if (![[UserDefaults objectForKey:@"UserName"] hasPrefix:@"qq_"] && ![[UserDefaults objectForKey:@"UserName"] hasPrefix:@"wechat_"]) {
        _phoneTF.text = [UserDefaults objectForKey:@"UserName"];
        _pwdTF.text = [UserDefaults objectForKey:@"Pwd"];
    }
    
//    _phoneTF.text = @"18566775262";
//    _pwdTF.text = @"123456";
}

// 同一个账号三次登录失败之后，要求输入图形验证码
- (void)addCodeTextField {
    
    // 验证码
    UIImage *codeImage = GETNCIMAGE(@"login_code_bg.png");
    CGRect codeImageFrame = CGRectMake(40 * PSDSCALE_X, VIEW_H_Y(_pwdTF) + 60 * PSDSCALE_Y, SCREEN_WIDTH, (SCREEN_WIDTH - 40 * PSDSCALE_X) * codeImage.size.height / codeImage.size.width);
    [self imageViewWithFrame:codeImageFrame inView:self.view image:codeImage contentMode:0 backgroundColor:CLEARCOLOR cornerRadius:0 borderWidth:0 borderColor:CLEARCOLOR];
    
    CGRect codeTFFrame = CGRectMake(40 * PSDSCALE_X, VIEW_H_Y(_pwdTF) + 52 * PSDSCALE_Y, SCREEN_WIDTH - 40 * PSDSCALE_X, (SCREEN_WIDTH - 40 * PSDSCALE_X) * codeImage.size.height / codeImage.size.width);
    UITextField *codeTF = [self textFieldWithFrame:codeTFFrame sizeFont:30 * FONTCALE_Y background:nil keyBoardType:UIKeyboardTypeDefault placeholder:@"验证码" placeholdFont:30 * FONTCALE_Y placehodlColor:RGBSTRING(@"4a4a4a") secure:YES inView:self.view];
    codeTF.tintColor = RGBSTRING((@"ad1e22"));
    codeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87 * PSDSCALE_X, VIEW_H(codeTF))];
    codeTF.leftViewMode = UITextFieldViewModeAlways;
    _codeTF = codeTF;
    
    // 验证码图片
    UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(0, 0, 160 * PSDSCALE_X, VIEW_H(codeTF));
    codeBtn.backgroundColor = RGBSTRING(@"cccccc");
    [codeBtn addTarget:self action:@selector(codeBtn_clicked:) forControlEvents:UIControlEventTouchUpInside];
    _codeImageBtn = codeBtn;
    
    _codeTF.rightView = _codeImageBtn;
    _codeTF.rightViewMode = UITextFieldViewModeAlways;
    
    // 登录、忘记密码、注册按钮往下移
    CGRect frame = _loginBtn.frame;
    frame.origin.y = VIEW_H_Y(_codeTF) + 107 * PSDSCALE_Y;
    _loginBtn.frame = frame;
    
    frame = _registerBtn.frame;
    frame.origin.y = VIEW_H_Y(_loginBtn) + 10 * PSDSCALE_Y;
    _registerBtn.frame = frame;
    
    frame = _forgetPwdBtn.frame;
    frame.origin.y = VIEW_H_Y(_loginBtn) + 10 * PSDSCALE_Y;
    _forgetPwdBtn.frame = frame;

}

// 第三方登录
- (void)addThirdLoginView {
    
    UIView *bgView = [[UIView alloc] init];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(190 * PSDSCALE_Y);
    }];
    [bgView updateConstraintsIfNeeded];
    
    // 提示
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = RGBSTRING(@"777777");
    titleLabel.font = [UIFont systemFontOfSize:25 * FONTCALE_Y];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"使用第三方登录";
    [bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(50 * PSDSCALE_Y);
    }];
    
    UIButton *qqBtn = [[UIButton alloc] init];
    [qqBtn setImage:GETNCIMAGE(@"login_qq_btn.png") forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(thirdLogin_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    qqBtn.tag = 2;
    [bgView addSubview:qqBtn];
    
    if ([[WeChatManager shareWeChatManager] isWXAppInstalled]) {
        
        // 安装了微信，显示微信按钮
        UIButton *wechatBtn = [[UIButton alloc] init];
        [wechatBtn setImage:GETNCIMAGE(@"login_wechat_btn.png") forState:UIControlStateNormal];
        [wechatBtn addTarget:self action:@selector(thirdLogin_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        wechatBtn.tag = 1;
        [bgView addSubview:wechatBtn];
        [wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(203 * PSDSCALE_X);
            make.bottom.mas_equalTo(-37 * PSDSCALE_Y);
            make.height.mas_equalTo(100 * PSDSCALE_Y);
            make.width.mas_equalTo(144 * PSDSCALE_X);
        }];
        
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-190 * PSDSCALE_X);
            make.bottom.mas_equalTo(-37 * PSDSCALE_Y);
            make.height.mas_equalTo(100 * PSDSCALE_Y);
            make.width.mas_equalTo(144 * PSDSCALE_X);
        }];

    } else {
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.bottom.mas_equalTo(-37 * PSDSCALE_Y);
            make.height.mas_equalTo(100 * PSDSCALE_Y);
            make.width.mas_equalTo(144 * PSDSCALE_X);
        }];
    }
}

- (void)loginButtonClicked {
    [self.view endEditing:YES];
    if (_phoneTF.text.length < 1) {
        [self addActityText:@"请输入您的手机号码" deleyTime:1];
        return;
    }
    if (![self checkPhoneNumber:_phoneTF.text]) {
        [self addActityText:@"请输入正确的手机号码" deleyTime:1];
        return;
    }
    
    
    if (_pwdTF.text.length < 6 || _pwdTF.text.length > 15) {
        [self addActityText:@"请输入6到15位密码" deleyTime:1];
        return;
    }
    
    if (_isNeedCode) {
        if (_codeTF.text.length < 1) {
            [self addActityText:@"请输入验证码" deleyTime:1];
            return;
        }
        captcha = _codeTF.text;
    }else{
        captchaId = @"";  //验证码ID
        captcha = @"";    //验证码
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    
    
    [RequestManager existUserWithPhoneNumber:_phoneTF.text succeed:^(id responseObject) {
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            //账号不存在
            if ([VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"exists") boolValue])
            {
                [RequestManager loginWithID:_phoneTF.text idType:@"phoneNum" password:_pwdTF.text devToken:@"" captchaId:captchaId captcha:captcha succeed:^(id responseObject) {
                    [[NSUserDefaults standardUserDefaults] setObject:_phoneTF.text forKey:@"phoneNumber"];
                    
                    [weakSelf resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        _loginFailedTimes = 0;
                        NSString *loginToken = VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"loginToken");
                        //保存token
                        [SettingConfig shareInstance].loginToken = loginToken;
                        //保存电话号
                        [SettingConfig shareInstance].phone = _phoneTF.text;
                        [SettingConfig shareInstance].isLogin = YES;
                        [weakSelf addActityText:@"登录成功" deleyTime:1];
                        
                        // 保存用户名
                        [[NSUserDefaults standardUserDefaults] setObject:_phoneTF.text forKey:@"UserName"];
                        [[NSUserDefaults standardUserDefaults] setObject:_pwdTF.text forKey:@"Pwd"];
                        
                        // 登录成功后，获取个人信息保存本地
                        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [NotificationCenter postNotificationName:@"loginStatusNotification" object:@"1"];
                        });
                        
                        
                    } err_block:^(NSDictionary *resultDic) {
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        //多次登录失败。同一帐号3次登录失败后，服务端返回此错误码
                        if ([FORMATSTRING(VALUEFORKEY(resultDic, @"errCode")) isEqualToString:@"-25"]) {
                            [weakSelf addActityText:@"账号或密码错误，请填写验证码" deleyTime:1];
                            _isNeedCode = YES;
                            
                            if (!_codeImageBtn) {
                                [self addCodeTextField];
                            }
                            _codeTF.text = nil;
                            _pwdTF.text = nil;
                            [weakSelf getVerificationCode];
                        } else if ([FORMATSTRING(VALUEFORKEY(resultDic, @"errCode")) isEqualToString:@"-26"]) {
                            [weakSelf addActityText:@"验证码输入错误" deleyTime:1];
                        } else if ([FORMATSTRING(VALUEFORKEY(resultDic, @"errCode")) isEqualToString:@"-24"]){
                            [weakSelf addActityText:@"账号或密码错误" deleyTime:1];
                        }
                    }];
                } failed:^(NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    REQUEST_FAILED_ALERT;
                }];
            }
            else
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self addActityText:@"该用户不存在" deleyTime:1];
            }
            
        } err_block:^(NSDictionary *resultDic) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            MMLog(@"%@",resultDic);
        }];
    } failed:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        REQUEST_FAILED_ALERT;
    }];
    
    
    
    
    
    

}

- (void)codeBtn_clicked:(UIButton *)btn
{
    if (_phoneTF.text.length < 1) {
        [self addActityText:@"手机号码不能为空" deleyTime:1];
        return;
    }
    if (![self checkPhoneNumber:_phoneTF.text]) {
        [self addActityText:@"请输入正确的手机号码" deleyTime:1];
        return;
    }
    
    
//    if (_pwdTF.text.length < 6 || _pwdTF.text.length > 15) {
//        [self addActityText:@"请输入6到15位密码" deleyTime:1];
//        return;
//    }
    
    [self getVerificationCode];
}

//获取验证码
- (void)getVerificationCode {
   
    [RequestManager getCaptchaWithWidth:2 * 110 * PSDSCALE_X height:2 * VIEW_H(_codeTF) succeed:^(id responseObject) {
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            captchaId = VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"captchaId");
            NSString *imageStr = VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"imageData");
            captchaImg = [UIImage imageWithData:[NSData dataWithBase64EncodedString:imageStr]];
            [_codeImageBtn setImage:captchaImg forState:UIControlStateNormal];
        } err_block:^(NSDictionary *resultDic) {
            [self addActityText:NSLocalizedString(@"getCodeFailure", nil) deleyTime:1];
        }];

    } failed:^(NSError *error) {
        NSString *errorStr = [NSString stringWithFormat:@"错误码: %ld",(long)error.code];
        [self addActityText:errorStr deleyTime:1.0];
    }];
    
}

- (void)registerButtonClicked {
    
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)forgetPwdButtonClicked {
    ForgetPwdViewController *forgetPwdVC = [[ForgetPwdViewController alloc] init];
    [self.navigationController pushViewController:forgetPwdVC animated:YES];
}

- (void)thirdLogin_button_clicked_action:(UIButton *)sender {
    
    if (sender.tag == 1) {
        // 微信
        [[WeChatManager shareWeChatManager] sendAuthRequest];
    } else if (sender.tag == 2) {
        // QQ
        [QQManager shareQQManager].delegate = self;
        [[QQManager shareQQManager] authorize];
    }
}

- (void)weChat_login_action:(NSNotification *)notif
{
    if ([notif.object isKindOfClass:[NSString class]]) {
        NSString *code = notif.object;
        
        // 获取微信 access_token
        [[WeChatManager shareWeChatManager] getAccess_tokenWithCode:code succeed:^(id responseObject) {
            NSDictionary *result_dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            
            NSString *access_token = VALUEFORKEY(result_dic, @"access_token");
            NSString *openId = VALUEFORKEY(result_dic, @"openid");
            NSString *expires_in = VALUEFORKEY(result_dic, @"expires_in");
            
            if ([FORMATSTRING(expires_in) isEqualToString:@"7200"]) {
                [self weChatLoginWithAccess_token:access_token openId:openId];
            } else {
                [self addActityText:@"用户授权失败" deleyTime:1];
            }
        } failed:^(NSError *error) {
            [self addActityText:@"用户授权失败" deleyTime:1];
        }];
    }
}

// 微信登录
- (void)weChatLoginWithAccess_token:(NSString *)access_token openId:(NSString *)openId
{
    [self addActityLoading:@"登录中..." subTitle:nil];
    __weak typeof(self) weakSelf = self;
    [RequestManager thirdPartyLoginWithChannel:@"wechat" devToken:nil accessToken:access_token openId:openId succeed:^(id responseObject) {
        
        [weakSelf removeActityLoading];
        
        [weakSelf handleLoginResultWithResponseObject:responseObject openId:openId isWechat:YES];
        
    } failed:^(NSError *error) {
        [self removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];
}

- (void)handleLoginResultWithResponseObject:(id)responseObject openId:(NSString *)openId isWechat:(BOOL)isWechat{
    
    __weak typeof(self) weakSelf = self;
    
    // 拼接上前缀，防止微信openid跟qq openId相同的情况
    NSString *loginUserName = [@"qq_" stringByAppendingString:openId];
    if (isWechat) {
        loginUserName = [@"wechat_" stringByAppendingString:openId];
    }
    
    [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
        
        NSDictionary *result = VALUEFORKEY(resultDic, @"result");
        
        [SettingConfig shareInstance].loginToken = FORMATSTRING(VALUEFORKEY(result, @"loginToken"));
        
        // 保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:loginUserName forKey:@"UserName"];
        [SettingConfig shareInstance].isLogin = YES;
        // 登录成功后，获取个人信息保存本地
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
        // 登录成功
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NotificationCenter postNotificationName:@"loginStatusNotification" object:@"1"];
        });
        
    } err_block:^(NSDictionary *resultDic) {
        [weakSelf addActityText:FORMATSTRING(VALUEFORKEY(resultDic, @"errMsg")) deleyTime:1];
    }];
}


#pragma mark - QQManagerDelegate
- (void)didGetOAuth:(TencentOAuth *)oAuth {
    
    // qq登录
    [self addActityLoading:@"登录中" subTitle:nil];
    __weak typeof(self) weakSelf = self;
    [RequestManager thirdPartyLoginWithChannel:@"qq" devToken:nil accessToken:oAuth.accessToken openId:oAuth.openId succeed:^(id responseObject) {
        [weakSelf removeActityLoading];
        
        [weakSelf handleLoginResultWithResponseObject:responseObject openId:oAuth.openId isWechat:NO];

    } failed:^(NSError *error) {
        [self removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];
}

@end
