//
//  PRGSettingDataViewController.m
//  AiFuKa
//
//  Created by Change_pan on 16/6/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "PRGSettingDataViewController.h"
#import "UITextView+Extension.h"
#define kMaxLength 50
@interface PRGSettingDataViewController ()<UITextViewDelegate>

@end

@implementation PRGSettingDataViewController
{
    UITextField *_textField;
    UITextView *_textView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBSTRING(@"f2f2f2");
    [self addTitleWithName:self.titleStr wordNun:(int)self.titleStr.length];
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        [weakSelf saveData];
    }];
    
    if ([self.titleStr isEqualToString:@"昵称"]) {
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 49)];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.text = self.detail;
        [_textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        _textField.placeholder = self.titleStr;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
        UIView *leftView = [self viewWithFrame:CGRectMake(0, 0, 15, 49) inView:nil backgroundColor:0 cornerRadius:0];
        _textField.leftView = leftView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        [self.view addSubview:_textField];
    } else if ([self.titleStr isEqualToString:@"签名"]) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 100)];
        _textView.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
        
        if (self.detail.length) {
            _textView.text = self.detail;
        } else {
            _textView.placeholder = @"请输入签名";
        }
        
        _textView.textContainerInset = UIEdgeInsetsMake(15, 15, 0, 15);
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.editable =YES;
        _textView.delegate = self;
        _textView.keyboardType = UIKeyboardAppearanceDefault;
        _textView.returnKeyType = UIReturnKeyDone;
        
        [self.view addSubview:_textView];
    }
    
    
}

-(void)saveData
{
    [self.view endEditing:YES];
    
    NSDictionary *userInfoDic = nil;
    
    NSString *infoStr = nil;
    if ([self.titleStr isEqualToString:@"昵称"]) {
        
        if (_textField.text.length == 0) {
            [self addActityText:@"请输入昵称" deleyTime:2];
            return;
        }else if (_textField.text.length > 10){
            [self addActityText:@"用户名不能超过10个字符" deleyTime:2];
            return;
        }
        
        userInfoDic = @{@"nickName":_textField.text};
        infoStr = _textField.text;
        
    } else if ([self.titleStr isEqualToString:@"签名"]) {
        
        if (_textView.text.length == 0) {
            [self addActityText:@"请输入签名" deleyTime:2];
            return;
        }
        
        userInfoDic = @{@"signature":_textView.text};
        infoStr = _textView.text;
    }
    
    [self addActityLoading:nil subTitle:nil];
    [RequestManager postUpdateUserInfoWithUserInfo:userInfoDic succeed:^(id responseObject) {
        [self removeActityLoading];
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            [self addActityText:@"修改成功" deleyTime:1];
            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
            self.block(infoStr);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });

            
        } err_block:^(NSDictionary *resultDic) {
            [self addActityText:@"修改失败" deleyTime:1];
        }];
    } failed:^(NSError *error) {
        [self removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];

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


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    
    
    if (textView.text.length > kMaxLength)
    {
        textView.text = [textView.text substringToIndex:kMaxLength];
        return NO;
    }
    return YES;
}


@end
