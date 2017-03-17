//
//  CameraBluetoothHFViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraBluetoothHFViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CameraBluetoothHFViewController ()

@property (nonatomic, strong)CBCentralManager *CBManager;

@end

@implementation CameraBluetoothHFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"蓝牙免提"];
    
    [self addBluetoothHFView];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
}

- (void)addBluetoothHFView {
    // 免提开启开关
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 22 * PSDSCALE_Y, SCREEN_WIDTH, 50)];
    bgView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView1];
    
    [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView1)) inView:bgView1 textColor:RGBSTRING(@"333333") fontSize:28 * FONTCALE_Y text:@"蓝牙匹配开关" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    UISwitch *blueMatchSwitch = [[UISwitch alloc] init];
    blueMatchSwitch.frame = CGRectMake(SCREEN_WIDTH - 15 - VIEW_W(blueMatchSwitch), (50 - VIEW_H(blueMatchSwitch)) / 2, VIEW_W(blueMatchSwitch), VIEW_H(blueMatchSwitch));

    [blueMatchSwitch addTarget:self action:@selector(blueMatchSwitch:) forControlEvents:UIControlEventValueChanged];
    blueMatchSwitch.onTintColor = RGBSTRING(@"b11c22");
    [blueMatchSwitch setOn:[self.detailString intValue]];
    [bgView1 addSubview:blueMatchSwitch];
    
//    [self buttonWithFrame:CGRectMake(SCREEN_WIDTH - 87, (VIEW_H(bgView1) - 33) / 2, 72, 33) inView:bgView1 title:[self.detailString intValue]?@"关闭":@"开启" titleColorNormal:RGBSTRING(@"333333") titleColorSelected:nil titleFontSize:28 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:4 borderWidth:1 borderColor:RGBACOLOR(119, 119, 119, 1) block:^(UIButton *sender) {
//        
//        if ([sender.titleLabel.text isEqualToString:@"关闭"]) {
//            MMLog(@"是关闭状态了");
//            [sender setTitle:@"开启" forState:UIControlStateNormal];
//            [self socketWithBody:@"0"];
//        }
//        else
//        {
//             MMLog(@"是开启状态了");
//            [sender setTitle:@"关闭" forState:UIControlStateNormal];
//            [self socketWithBody:@"1"];
//        }
//        
//    }];
    
    
    UIView *bgView2 = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(bgView1)+22 * PSDSCALE_Y, SCREEN_WIDTH, 50)];
    bgView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView2];
    
    [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView2)) inView:bgView2 textColor:RGBSTRING(@"333333") fontSize:28 * FONTCALE_Y text:@"蓝牙匹配" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    [self buttonWithFrame:CGRectMake(SCREEN_WIDTH - 87, (VIEW_H(bgView2) - 33) / 2, 72, 33) inView:bgView2 title:@"匹配" titleColorNormal:RGBSTRING(@"333333") titleColorSelected:nil titleFontSize:28 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:4 borderWidth:1 borderColor:RGBACOLOR(119, 119, 119, 1) block:^(UIButton *sender) {
        
        [self socketWithBody:@"2"];
        
        
        
    }];
}

-(void)socketWithBody:(NSString *)body
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.bluetooth=\"%@\"",body];
    [self addActityLoading:nil subTitle:nil];
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            if ([body isEqualToString:@"0"])
            {
                [self addActityText:@"蓝牙已关闭" deleyTime:1];
            }
            else if ([body isEqualToString:@"1"])
            {
                [self addActityText:@"蓝牙已开启" deleyTime:1];
            }
           else
            {
                if (IOS10_OR_LATER)
                {
                    // ios 10跳转蓝牙的方法
                    if (_CBManager) {
                        _CBManager = nil;
                        _CBManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
                    }else{
                        _CBManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
                    }
                } else {
                    //蓝牙设置界面
                    NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
                
            }
        }
        else
        {
            [self addActityText:@"网络连接异常" deleyTime:1];
        }
        
    }];
    
}

- (void)blueMatchSwitch:(UISwitch *)blueMatchSwitch
{
    if (blueMatchSwitch.isOn) {
        [self socketWithBody:@"1"];
        ZYLog(@"开启了");
    }else{
       [self socketWithBody:@"0"];
        ZYLog(@"关闭了");
    }
}


@end
