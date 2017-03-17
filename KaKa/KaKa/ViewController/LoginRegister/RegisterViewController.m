//
//  RegisterViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UITextField *pwdTF;
@property (nonatomic, strong) UITextField *codeTF;

@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) NSUInteger countDownIndex;
@property (nonatomic, copy) NSString *authToken;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    [self addTitleLabel];
    
    [self addInputView];
    
    [self addLoginBtn];
    
}

- (void)addTitleLabel {
    [self labelWithFrame:CGRectMake(0, 148 * PSDSCALE_Y, SCREEN_WIDTH, 57 * PSDSCALE_Y) inView:self.view textColor:RGBSTRING(@"333333") fontSize:45 * FONTCALE_Y text:@"使用手机号注册" alignment:NSTextAlignmentCenter bold:YES fit:NO];
}

- (void)addInputView {
    UIImage *bgImage = GETNCIMAGE(@"register_input_bg");
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 * PSDSCALE_X, 285 * PSDSCALE_Y, SCREEN_WIDTH - 30 * PSDSCALE_X, bgImage.size.height / bgImage.size.width * (SCREEN_WIDTH - 30 * PSDSCALE_X))];
    bgImageView.image = bgImage;
    bgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bgImageView];
    
    __weak typeof(self) weakSelf = self;
    
    CGFloat height = (bgImage.size.height / bgImage.size.width * (SCREEN_WIDTH - 30 * PSDSCALE_X)) / 3;
    NSArray *leftTextsArray = @[@" +86", @" 验证码", @" 密码"];
    NSArray *placeholdersArray = @[@"请填写手机号码", @"请填写验证码", @"请填写密码 "];
    for (NSInteger i = 0; i < 3; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, height * i, SCREEN_WIDTH - 30 * PSDSCALE_X, height)];
        textField.placeholder = [placeholdersArray objectAtIndex:i];
        textField.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
        textField.tintColor = RGBSTRING((@"ad1e22"));
        [bgImageView addSubview:textField];
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190 * PSDSCALE_X, height)];
        leftLabel.text = [leftTextsArray objectAtIndex:i];
        leftLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
        leftLabel.textColor = RGBSTRING(@"333333");
        textField.leftView = leftLabel;
        textField.leftViewMode = UITextFieldViewModeAlways;

        // 手机号
        if (i == 0) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[placeholdersArray objectAtIndex:i]];
            [attr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30 * FONTCALE_Y]} range:NSMakeRange(0, [[placeholdersArray objectAtIndex:i] length])];
            textField.attributedPlaceholder = attr;
            textField.keyboardType = UIKeyboardTypePhonePad;
            _phoneTF = textField;
        } else if (i == 1) {
            
            _codeTF = textField;
            
            UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 238 * PSDSCALE_X, height)];
            textField.rightView = rightView;
            textField.rightViewMode = UITextFieldViewModeAlways;
            
            UIButton *codeBtn = [self buttonWithFrame:CGRectMake(0, 0, 182 * PSDSCALE_X, 81 * PSDSCALE_Y) inView:rightView title:@"获取验证码" titleColorNormal:RGBSTRING(@"ad1e22") titleColorSelected:nil titleFontSize:25 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:3 borderWidth:1 borderColor:RGBSTRING(@"ad1e22") block:^(UIButton *sender) {
                
                // 获取验证码
                [weakSelf codeBtn_clicked_action];
            }];
            _codeBtn = codeBtn;
            codeBtn.center = CGPointMake(VIEW_W(rightView) / 2, height / 2);
        } else {
            
            _pwdTF = textField;
           _pwdTF.secureTextEntry = YES;
        }
        
    }
    
    // 登录按钮
    [self buttonWithFrame:CGRectMake(60 * PSDSCALE_X, 750 * PSDSCALE_Y, SCREEN_WIDTH - 2 * 60 * PSDSCALE_X, 97 * PSDSCALE_X) inView:self.view title:@"注 册" titleColorNormal:WHITE_COLOR titleColorSelected:CLEARCOLOR titleFontSize:35 * FONTCALE_Y backgroundNormal:GETNCIMAGE(@"login_btn_bg.png") backgroundSelected:nil cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        [weakSelf registerBtnClicked];
    }];
}

- (void)codeBtn_clicked_action
{
    if (![self checkPhoneNumber:_phoneTF.text]) {
        [self addActityText:@"请输入正确的手机号码" deleyTime:1];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RequestManager existUserWithPhoneNumber:_phoneTF.text succeed:^(id responseObject) {
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            //账号不存在
            if (![VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"exists") boolValue]) {
                //获取验证码
                [RequestManager reqAuthWithPhoneNumber:_phoneTF.text succeed:^(id responseObject) {
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    //解析数据
                    [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
                        //token
                        _authToken = VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"authToken");
//                        _codeTF.text = VALUEFORKEY(VALUEFORKEY(resultDic, @"result"), @"captcha");
                        
                        [self countDown];
                        
                    } err_block:^(NSDictionary *resultDic) {
                        
                    }];
                    
                } failed:^(NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    REQUEST_FAILED_ALERT;
                }];
            }
            //存在
            else{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self addActityText:@"该用户已注册" deleyTime:1];
            }
            
        } err_block:^(NSDictionary *resultDic) {
            //
            MMLog(@"%@",resultDic);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];

    } failed:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        REQUEST_FAILED_ALERT;
    }];
    
}

//倒计时按钮
- (void)countDown{
    _codeBtn.userInteractionEnabled = NO;
    _countDownIndex = 60;
    [_countDownTimer invalidate];
    _countDownTimer = nil;
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimerAction:) userInfo:nil repeats:YES];
    [_countDownTimer fire];
}
//倒计时方法
- (void)countDownTimerAction:(NSTimer *)timer{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_countDownIndex == 0) {
            return ;
        }
        _countDownIndex--;
        NSString *title = [NSString stringWithFormat:@"%luS %@",(unsigned long)_countDownIndex,@"重新获取"];
        [_codeBtn setTitle:title forState:UIControlStateNormal];
        if (_countDownIndex <= 0) {
            [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            _codeBtn.userInteractionEnabled = YES;
            [_countDownTimer invalidate];
            _countDownTimer = nil;
        }
    });
}



- (void)addLoginBtn {
    
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    [loginBtn setTitleColor:RGBSTRING(@"333333") forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginButton_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(85 * PSDSCALE_Y);
        make.left.mas_equalTo(280 * PSDSCALE_X);
        make.right.mas_equalTo(-280 * PSDSCALE_X);
        make.bottom.mas_equalTo(-40 * PSDSCALE_Y);
    }];
    
}

- (void)registerBtnClicked {
    

    if (_phoneTF.text.length < 1) {
        [self addActityText:@"手机号码不能为空" deleyTime:1];
        return;
    }
    if (![self checkPhoneNumber:_phoneTF.text]) {
        [self addActityText:@"请输入正确的手机号码" deleyTime:1];
        return;
    }
    
    if (_codeTF.text.length < 1) {
        [self addActityText:@"请输入验证码" deleyTime:1];
        return;
    }
    
    
    if (_pwdTF.text.length < 6 || _pwdTF.text.length > 15) {
        [self addActityText:@"请输入6到15位密码" deleyTime:1];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 验证短信
    [RequestManager authWithToken:FORMATSTRING(_authToken) authCode:FORMATSTRING(_codeTF.text) succeed:^(id responseObject) {

        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
            // 注册
            [weakSelf registerForUser];
        } err_block:^(NSDictionary *resultDic) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self addActityText:@"验证码错误" deleyTime:1];
        }];
    } failed:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        REQUEST_FAILED_ALERT;
    }];

}

// 注册
- (void)registerForUser {
    
    [RequestManager registerWithToken:FORMATSTRING(_authToken) nickName:@"" password:_pwdTF.text phoneNum:_phoneTF.text idCardNum:@"" email:@"" succeed:^(id responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            
            [self addActityText:@"注册成功" deleyTime:1];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } err_block:^(NSDictionary *resultDic) {
            [self addActityText:@"注册失败" deleyTime:1];
        }];

    } failed:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        REQUEST_FAILED_ALERT;
    }];

}

- (void)loginButton_clicked_action:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
