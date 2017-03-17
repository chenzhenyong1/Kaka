//
//  CameraFMSettingViewController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/24.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraFMSettingViewController.h"
#import "UIView+addBorderLine.h"

@interface CameraFMSettingViewController ()

@property (nonatomic, strong) UIImageView *valueBg;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UISlider *slider;
/** 开关 */
@property (nonatomic, strong) UIButton *selectedBtn;

/** 开关 */
@property (nonatomic, strong) UISwitch *changeSwitch;

@end

@implementation CameraFMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"FM发射设置"];
    
     __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        
        ZYLog(@"点击保存");
        if (weakSelf.changeSwitch.isOn) {
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%.0f",([weakSelf.valueLabel.text floatValue] *10)]];
        }else
        {
            
            [weakSelf socketWithBody:@"0"];
        }
        
        
    }];
    
    [self setupContentView];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
}

-(void)socketWithBody:(NSString *)body
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.fmFrequency=\"%@\"",body];
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
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


- (void)setupContentView
{
    // FM开关BG
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 22 * PSDSCALE_Y, SCREEN_WIDTH, 50)];
    [bgView1 addBorderLineWithColor:RGBSTRING(@"cccccc") borderWidth:1 direction:kBorderLineDirectionTop];
    bgView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView1];
    
    [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView1)) inView:bgView1 textColor:RGBSTRING(@"333333") fontSize:28 * FONTCALE_Y text:@"FM开关" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    UISwitch *changeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, (VIEW_H(bgView1) - 33) / 2, 72, 33)];
    
    [changeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    changeSwitch.onTintColor = RGBSTRING(@"b11c22");
    changeSwitch.on = YES;
    [bgView1 addSubview:changeSwitch];
    _changeSwitch = changeSwitch;
//    self.selectedBtn = [self buttonWithFrame:CGRectMake(SCREEN_WIDTH - 87, (VIEW_H(bgView1) - 33) / 2, 72, 33) inView:bgView1 title:@"开启" titleColorNormal:RGBSTRING(@"333333") titleColorSelected:nil titleFontSize:28 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:4 borderWidth:1 borderColor:RGBACOLOR(119, 119, 119, 1) block:^(UIButton *sender) {
    
//        if ([sender.titleLabel.text isEqualToString:@"关闭"]) {
//            MMLog(@"是关闭状态了");
//            
//            
//            self.slider.userInteractionEnabled = YES;
//            
//            UIImage *stetchLeftTrack= GETNCIMAGE(@"CameraSetting_voiceMiniTrackImage.png");
//            
//            [self.slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
//            [sender setTitle:@"开启" forState:UIControlStateNormal];
////            [self socketWithBody:@"0"];
//        }
//        else
//        {
//            MMLog(@"是开启状态了");
//            
//            self.slider.userInteractionEnabled = NO;
//             UIImage *stetchRightTrack = GETNCIMAGE(@"CameraSetting_voiceMaxiTrackImage.png");
//            [self.slider setMinimumTrackImage:stetchRightTrack forState:UIControlStateNormal];
////            _valueLabel.text = [NSString stringWithFormat:@"%d",[self.fmFrequencyString intValue]/10];
////            [self sliderValueChanged:self.slider];
//            
//            
//            [sender setTitle:@"关闭" forState:UIControlStateNormal];
////            [self socketWithBody:@"1"];
//        }
//        
//    }];
    
    
    
    //频率的BG
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView1.bottom , SCREEN_WIDTH, 100)];
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView addBorderLineWithColor:RGBSTRING(@"cccccc") borderWidth:1 direction:kBorderLineDirectionTop | kBorderLineDirectionBottom];
    [self.view addSubview:bgView];
    //频率label
    UILabel *label = [self labelWithFrame:CGRectMake(15, 0, 35, VIEW_H(bgView)) inView:bgView textColor:RGBSTRING(@"333333") fontSize:28 * FONTCALE_Y text:@"频率" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    //左右轨的图片
    UIImage *stetchLeftTrack= GETNCIMAGE(@"CameraSetting_voiceMiniTrackImage.png");
    UIImage *stetchRightTrack = GETNCIMAGE(@"CameraSetting_voiceMaxiTrackImage.png");
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"CameraSetting_voiceThumbImage.png"];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(VIEW_W_X(label) + 15, (VIEW_H(bgView) - stetchLeftTrack.size.height) / 2, SCREEN_WIDTH - (30 + label.width) - VIEW_W_X(label), stetchLeftTrack.size.height)];
    slider.backgroundColor = [UIColor clearColor];
    
    slider.maximumValue = 1.08;
    slider.minimumValue = 0.88;
    
    slider.value = ([self.fmFrequencyString intValue] / 10.0) /100.0;
    
    [slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    //滑块拖动时的事件
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [bgView addSubview:slider];
    _slider = slider;
    
    // 底部横线
    UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(slider), VIEW_H_Y(slider) + 10, VIEW_W(slider), 5)];
    bottomImageView.image = GETNCIMAGE(@"CameraSetting_voiceBottomImage.png");
    [bgView addSubview:bottomImageView];
    
    // label
    UIImageView *valueBg = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(slider), 15, 39, 22)];
    valueBg.image = GETNCIMAGE(@"CameraSetting_voiceValueBg");
    [bgView addSubview:valueBg];
    _valueBg = valueBg;
    UILabel *valueLabel = [self labelWithFrame:CGRectMake(0, -2, VIEW_W(valueBg), VIEW_H(valueBg)) inView:valueBg textColor:RGBSTRING(@"333333") fontSize:FONTCALE_Y * 21 text:@"0%" alignment:NSTextAlignmentCenter bold:NO fit:NO];
    _valueLabel = valueLabel;
    
    if (![self.fmFrequencyString isEqualToString:@"0"]) {
        
        self.changeSwitch.on = YES;
        _valueLabel.text = [NSString stringWithFormat:@"%f",[self.fmFrequencyString floatValue]/10];
        [self sliderValueChanged:slider];
    }else
    {
        self.changeSwitch.on = NO;
        [self.selectedBtn setTitle:@"关闭" forState:UIControlStateNormal];
        self.slider.userInteractionEnabled = NO;
//        _valueLabel.text = @"0";
        [self sliderValueChanged:slider];
    }
}


- (void)switchAction:(UISwitch *)sender
{
    
    ZYLog(@"send = %d",sender.isOn);
    
    if (sender.isOn) {
        MMLog(@"是开启状态了");
        self.slider.userInteractionEnabled = YES;
        //
        UIImage *stetchLeftTrack= GETNCIMAGE(@"CameraSetting_voiceMiniTrackImage.png");
        
        [self.slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    }else
    {
        self.slider.userInteractionEnabled = NO;
        UIImage *stetchRightTrack = GETNCIMAGE(@"CameraSetting_voiceMaxiTrackImage.png");
        [self.slider setMinimumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        _valueLabel.text = [NSString stringWithFormat:@"%.1f",[self.fmFrequencyString floatValue]/10];
        [self sliderValueChanged:self.slider];
        
    }
    
//    if ([sender.titleLabel.text isEqualToString:@"关闭"]) {
        //            MMLog(@"是关闭状态了");
        //
        //
        //            self.slider.userInteractionEnabled = YES;
        //
        //            UIImage *stetchLeftTrack= GETNCIMAGE(@"CameraSetting_voiceMiniTrackImage.png");
        //
        //            [self.slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        //            [sender setTitle:@"开启" forState:UIControlStateNormal];
        ////            [self socketWithBody:@"0"];
        //        }
        //        else
        //        {
        //            MMLog(@"是开启状态了");
        //
        //            self.slider.userInteractionEnabled = NO;
        //             UIImage *stetchRightTrack = GETNCIMAGE(@"CameraSetting_voiceMaxiTrackImage.png");
        //            [self.slider setMinimumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        ////            _valueLabel.text = [NSString stringWithFormat:@"%d",[self.fmFrequencyString intValue]/10];
        ////            [self sliderValueChanged:self.slider];
        //            
        //            
        //            [sender setTitle:@"关闭" forState:UIControlStateNormal];
        ////            [self socketWithBody:@"1"];
        //        }

}



- (void)sliderValueChanged:(UISlider *)sender {
    
    _valueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value * 1000 / 10.0];
    
    CGPoint valueBgCenter = _valueBg.center;
    valueBgCenter.x = (VIEW_W(sender) - VIEW_W(_valueBg) / 2) * (sender.value - sender.minimumValue)  + VIEW_X(sender) + VIEW_W(_valueBg) / 2 - sender.currentThumbImage.size.width/2 * sender.value + (sender.width / (sender.maximumValue - sender.minimumValue + 0.07)) * (sender.value - sender.minimumValue);
    _valueBg.center = valueBgCenter;
    
    ZYLog(@"sender.value = %f",sender.value);
}


@end
