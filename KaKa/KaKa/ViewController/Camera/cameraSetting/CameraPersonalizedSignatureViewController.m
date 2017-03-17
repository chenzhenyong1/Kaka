//
//  CameraPersonalizedSignatureViewController.m
//  KaKa
//
//  Created by Change_pan on 16/8/11.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraPersonalizedSignatureViewController.h"

#define kMaxLength 30
@interface CameraPersonalizedSignatureViewController ()
@property (nonatomic, strong) UITextField *cameraNameTF;

@end

@implementation CameraPersonalizedSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"个性文字"];
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        
        [weakSelf socketWithBody:weakSelf.cameraNameTF.text];
        
    }];
    
    [self addCamereNameTF];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
}


-(void)socketWithBody:(NSString *)body
{
    if (body.length == 0) {
        [self addActityText:@"请输入内容" deleyTime:1];
        return;
    }
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.osd.personalizedSignature=\"%@\"",body];
    
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        MMLog(@"aaa");
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            weakSelf.block(body);
            [self addActityText:@"修改成功" deleyTime:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            [self addActityText:@"网络连接异常" deleyTime:1];
        }
        
    }];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_cameraNameTF becomeFirstResponder];
}

- (void)addCamereNameTF {
    
    _cameraNameTF = [self textFieldWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 50) sizeFont:FONTCALE_Y * 30 background:nil keyBoardType:UIKeyboardTypeDefault placeholder:nil placeholdFont:FONTCALE_Y * 30 placehodlColor:nil secure:NO inView:self.view];
    _cameraNameTF.backgroundColor = [UIColor whiteColor];
    _cameraNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _cameraNameTF.placeholder = @"输入个性文字,不超过30个字符";
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
    _cameraNameTF.leftView = leftView;
    _cameraNameTF.leftViewMode = UITextFieldViewModeAlways;
    [_cameraNameTF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
}


- (void)textFieldChanged:(UITextField *)textField{
    NSString *toBeString = textField.text;
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
    
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else{
        NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }
    
}

/**
 *  获得 CharacterCount长度的字符
 */
-(NSString *)getSubString:(NSString*)string
{
    //    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //    NSData* data = [string dataUsingEncoding:encoding];
    //    NSInteger length = [data length];
    //    if (length > CharacterCount) {
    //        NSData *data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount)];
    //        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];//注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
    //        if (!content || content.length == 0) {
    //            data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount - 1)];
    //            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
    //        }
    //        return content;
    //    }
    //    return nil;
    
    if (string.length > kMaxLength) {
        NSLog(@"超出字数上限");
        return [string substringToIndex:kMaxLength];
    }
    return nil;
}

/**
 *  过滤字符串中的emoji
 */
- (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

/**
 * 字母、数字、中文正则判断（包括空格）（在系统输入法中文输入时会出现拼音之间有空格，需要忽略，当按return键时会自动用字母替换，按空格输入响应汉字）
 */
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

@end
