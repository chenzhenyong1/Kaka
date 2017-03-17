//
//  MeSettingAppCaCheViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeSettingAppCaCheViewController.h"

@interface MeSettingAppCaCheViewController ()

@end

@implementation MeSettingAppCaCheViewController
{
    UITextField *_textField;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"设置预留可用空间" wordNun:8];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 36, 20)];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:30*PSDSCALE_Y];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 30*PSDSCALE_Y, SCREEN_WIDTH, 123*PSDSCALE_Y)];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    _textField.font = [UIFont systemFontOfSize:30*PSDSCALE_Y];
    UIView *leftView = [self viewWithFrame:CGRectMake(0, 0, 32*PSDSCALE_X, 122*PSDSCALE_Y) inView:nil backgroundColor:0 cornerRadius:0];
    _textField.leftView = leftView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *rightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100*PSDSCALE_X, 122*PSDSCALE_Y)];
    _textField.rightView = rightLab;
    rightLab.text = @"MB";
    _textField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_textField];
    
    
    
}

- (void)rightButtonAction
{
    self.block(_textField.text);
    [self.navigationController popViewControllerAnimated:YES];
}



@end
