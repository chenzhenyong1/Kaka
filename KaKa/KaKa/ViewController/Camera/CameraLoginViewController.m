//
//  CameraLoginViewController.m
//  KaKa
//
//  Created by Change_pan on 2016/10/21.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraLoginViewController.h"
#import "CameraDetailViewController.h"
@interface CameraLoginViewController ()
@property (nonatomic, strong) UILabel *tishi_lab;
@end

@implementation CameraLoginViewController
{
    UITextField *cameraNameField;
    UITextField *cameraPassWordField;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitle:@"登录摄像机"];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    [self initUI];
}


- (void)initUI
{
    _tishi_lab = [[UILabel alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, 42*PSDSCALE_Y, SCREEN_WIDTH-30*PSDSCALE_X, 35*PSDSCALE_Y)];
    _tishi_lab.textAlignment = NSTextAlignmentLeft;
    _tishi_lab.textColor = RGBSTRING(@"ad1e22");
    _tishi_lab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [self.view addSubview:_tishi_lab];
    
    cameraNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(_tishi_lab)+44*PSDSCALE_X, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    cameraNameField.placeholder = @"请输入登录名";
    cameraNameField.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    cameraNameField.backgroundColor = [UIColor whiteColor];
    cameraNameField.tintColor = RGBSTRING((@"ad1e22"));
    [self.view addSubview:cameraNameField];
    
    UILabel *cameraNameleftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190 * PSDSCALE_X, 100*PSDSCALE_Y)];
    cameraNameleftLabel.text = @"登录名";
    cameraNameleftLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    cameraNameleftLabel.textAlignment = NSTextAlignmentCenter;
    cameraNameleftLabel.textColor = RGBSTRING(@"333333");
    cameraNameField.leftView = cameraNameleftLabel;
    cameraNameField.leftViewMode = UITextFieldViewModeAlways;
    
    
    cameraPassWordField = [[UITextField alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(cameraNameField)+2*PSDSCALE_X, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    cameraPassWordField.placeholder = @"请输入密码";
    cameraPassWordField.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    cameraPassWordField.backgroundColor = [UIColor whiteColor];
    cameraPassWordField.tintColor = RGBSTRING((@"ad1e22"));
    [self.view addSubview:cameraPassWordField];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190 * PSDSCALE_X, 100*PSDSCALE_Y)];
    leftLabel.text = @"密码";
    leftLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.textColor = RGBSTRING(@"333333");
    cameraPassWordField.leftView = leftLabel;
    cameraPassWordField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(60*PSDSCALE_X, VIEW_H_Y(cameraPassWordField)+60*PSDSCALE_Y, SCREEN_WIDTH-120*PSDSCALE_X, 100*PSDSCALE_Y)];
    [btn setBackgroundColor:RGBSTRING(@"ad1e22")];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 10;
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btn_click) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)btn_click
{
    [self.view endEditing:YES];
    if (cameraNameField.text.length == 0) {
        [self addActityText:@"请输入登录名" deleyTime:1];
        return;
    }
    
    if (cameraPassWordField.text.length == 0) {
        [self addActityText:@"请输入登录密码" deleyTime:1];
        return;
    }
    
    // 登录
    [self loginCameraWithUserName:cameraNameField.text password:cameraPassWordField.text model:self.model];
}

/**
 *  登录摄像头
 *
 *  @param userName 登录名
 *  @param password 登录密码
 */
- (void)loginCameraWithUserName:(NSString *)userName password:(NSString *)password model:(CameraListModel *)model{
    
    MsgModel * msg = [[MsgModel alloc]init];
    msg.cmdId = @"01";
    msg.msgSN = @"0001";
    msg.token = @"0000000000000000000000000000000000000000000000000000000000000000";
    
    NSString *msgBody = [NSString stringWithFormat:@"username:%@&passwd:%@", userName, password];
    msg.msgBody = msgBody;
    
    __weak typeof(self) weakSelf = self;
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"LOGINERROR"]) {
            // 用户名或密码错误 弹出输入框
            weakSelf.tishi_lab.text = @"登录名或密码错误，请重新输入！";
            
        } else {
            // 登录摄像头成功
            [SettingConfig shareInstance].currentCameraModel = model;
            [SettingConfig shareInstance].ip_url = model.ipAddress;
            
            [UserDefaults setObject:userName forKey:[NSString stringWithFormat:@"CameraUserName_%@",model.macAddress]];
            [UserDefaults setObject:password forKey:[NSString stringWithFormat:@"CameraPassword_%@",model.macAddress]];
            CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
            cameraDetailVC.hidesBottomBarWhenPushed = YES;
            cameraDetailVC.model = model;
            [self.navigationController pushViewController:cameraDetailVC animated:YES];
        }
    }];
    
}



@end
