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
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    UILabel *appVersion = [self setAttributeLabelWithFrame:CGRectMake((SCREEN_WIDTH-150*PSDSCALE_X)/2, 300*PSDSCALE_Y, 150*PSDSCALE_X, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:[NSString stringWithFormat:@"V%@",app_Version]];
    [self.view addSubview:appVersion];
    //服务热线
    UIView *phoneView = [self servicePhone];
    
    //公司官网
    
    UIView *webView = [self companyOfficialWebsiteBelow:phoneView];
    
    //版权有关的view
    [self companyInfoBelow:webView];
    
}

//版权有关的view
- (void)companyInfoBelow:(UIView *)view
{
    UILabel *lab1 = [self setAttributeLabelWithFrame:CGRectMake(0, VIEW_H_Y(view)+400*PSDSCALE_Y, SCREEN_WIDTH, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:@"使用条款和隐私政策"];
    
    [self.view addSubview:lab1];
    
    UILabel *lab2 = [self setAttributeLabelWithFrame:CGRectMake(0, VIEW_H_Y(lab1)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y) textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:18*FONTCALE_Y] textColor:RGBSTRING(@"919191") text:@"伊爱高新 版权所有"];
    
    [self.view addSubview:lab2];
    
    UILabel *lab3 = [self setAttributeLabelWithFrame:CGRectMake(0, VIEW_H_Y(lab2)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y) textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:18*FONTCALE_Y] textColor:RGBSTRING(@"919191") text:@"Copyright©2015-2017"];
    
    [self.view addSubview:lab3];
    
    UILabel *lab4 = [self setAttributeLabelWithFrame:CGRectMake(0, VIEW_H_Y(lab3)+27*PSDSCALE_Y, SCREEN_WIDTH, 23*PSDSCALE_Y) textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:18*FONTCALE_Y] textColor:RGBSTRING(@"919191") text:@"All rights reserved"];
    
    [self.view addSubview:lab4];
}

//公司官网
- (UIView *)companyOfficialWebsiteBelow:(UIView *)view
{
    UIView *webView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(view)+1, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    
    UILabel *companyLab = [self setAttributeLabelWithFrame:CGRectMake(0, 33*PSDSCALE_Y, 150*PSDSCALE_X, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:@"公司官网:"];
    
    [webView addSubview:companyLab];
    
    UILabel *netLab = [self setAttributeLabelWithFrame:CGRectMake(0, 37*PSDSCALE_Y, 721*PSDSCALE_X, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:@"www.e-eye.cn"];
    
    [webView addSubview:netLab];
    
    return webView;
}

//服务热线
- (UIView *)servicePhone
{
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 368*PSDSCALE_Y, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    phoneView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:phoneView];
    
    UILabel *fuWuLab = [self setAttributeLabelWithFrame:CGRectMake(0, 33*PSDSCALE_Y, 150*PSDSCALE_X, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:@"服务热线:"];
    
    [phoneView addSubview:fuWuLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(call_click)];
    phoneView.userInteractionEnabled = YES;
    [phoneView addGestureRecognizer:tap];
    
    phone = @"4006121122";
    
    UILabel *phoneLab = [self setAttributeLabelWithFrame:CGRectMake(0, 37*PSDSCALE_Y, 721*PSDSCALE_X, 35*PSDSCALE_Y) textAlignment:NSTextAlignmentRight font:[UIFont systemFontOfSize:28*FONTCALE_Y] textColor:RGBSTRING(@"333333") text:phone];
    
    [phoneView addSubview:phoneLab];
    
    return phoneView;
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

//设置文字
- (UILabel *)setAttributeLabelWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment font:(UIFont *)font textColor:(UIColor *)textColor text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = textAlignment;
    label.font = font;
    label.textColor = textColor;
    label.text = text;
    
    return label;

}

@end
