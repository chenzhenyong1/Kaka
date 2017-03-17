//
//  MeAboutUsViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeAboutUsViewController.h"

@interface MeAboutUsViewController ()<UIAlertViewDelegate>

@end

@implementation MeAboutUsViewController
{
    NSString *phone;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"关于" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    UIImageView *bg_view = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-490*PSDSCALE_X)/2, 100*PSDSCALE_Y, 490*PSDSCALE_X, 185*PSDSCALE_Y)];
    bg_view.image = GETYCIMAGE(@"kaKa_logo");
    [self.view addSubview:bg_view];
    
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 368*PSDSCALE_Y, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    phoneView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:phoneView];
    UILabel *fuWuLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 33*PSDSCALE_Y, 150*PSDSCALE_X, 35*PSDSCALE_Y)];
    fuWuLab.text = @"服务热线:";
    fuWuLab.textAlignment = NSTextAlignmentRight;
    fuWuLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    fuWuLab.textColor = RGBSTRING(@"333333");
    [phoneView addSubview:fuWuLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(call_click)];
    phoneView.userInteractionEnabled = YES;
    [phoneView addGestureRecognizer:tap];
    
    phone = @"4006121122";
    UILabel *phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 37*PSDSCALE_Y, 721*PSDSCALE_X, 35*PSDSCALE_Y)];
    phoneLab.text = phone;
    phoneLab.textColor = RGBSTRING(@"333333");
    phoneLab.textAlignment = NSTextAlignmentRight;
    phoneLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [phoneView addSubview:phoneLab];
    
    
    UIView *webView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(phoneView)+1, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    UILabel *companyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 33*PSDSCALE_Y, 150*PSDSCALE_X, 35*PSDSCALE_Y)];
    companyLab.text = @"公司官网:";
    companyLab.textAlignment = NSTextAlignmentRight;
    companyLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    companyLab.textColor = RGBSTRING(@"333333");
    [webView addSubview:companyLab];
    
    UILabel *netLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 37*PSDSCALE_Y, 721*PSDSCALE_X, 35*PSDSCALE_Y)];
    netLab.text = @"www.e-eye.cn";
    netLab.textColor = RGBSTRING(@"333333");
    netLab.textAlignment = NSTextAlignmentRight;
    netLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [webView addSubview:netLab];
    
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(webView)+400*PSDSCALE_Y, SCREEN_WIDTH, 35*PSDSCALE_Y)];
    lab1.text = @"使用条款和隐私政策";
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.textColor = RGBSTRING(@"333333");
    lab1.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [self.view addSubview:lab1];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(lab1)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:18*FONTCALE_Y];
    lab2.textColor = RGBSTRING(@"919191");
    lab2.text = @"伊爱高新 版权所有";
    [self.view addSubview:lab2];
    
    UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(lab2)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y)];
    lab3.textAlignment = NSTextAlignmentCenter;
    lab3.font = [UIFont systemFontOfSize:18*FONTCALE_Y];
    lab3.textColor = RGBSTRING(@"919191");
    lab3.text = @"Copyright©2015-2017";
    [self.view addSubview:lab3];
    
    UILabel *lab4 = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(lab3)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y)];
    lab4.textAlignment = NSTextAlignmentCenter;
    lab4.font = [UIFont systemFontOfSize:18*FONTCALE_Y];
    lab4.textColor = RGBSTRING(@"919191");
    lab4.text = @"All rights reserved";
    [self.view addSubview:lab4];
    
    
    
    
}

- (void)call_click
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",phone] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
            if ([SharedApplication canOpenURL:url]) {
                [SharedApplication openURL:url];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
