//
//  CameraVolumeCtrlViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraVolumeCtrlViewController.h"
#import "UIView+addBorderLine.h"

@interface CameraVolumeCtrlViewController ()

@property (nonatomic, strong) UIImageView *valueBg;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, strong) UISlider *slider;

@end

@implementation CameraVolumeCtrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"音量调节"];
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        
        NSArray *arr = [weakSelf.valueLabel.text componentsSeparatedByString:@"%"];
        MMLog(@"%@",arr[0]);
        [weakSelf socketWithBody:arr[0]];
        
    }];
    
    [self addVoiceControlSliderView];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
}


-(void)socketWithBody:(NSString *)body
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.volume=\"%@\"",body];
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

- (void)addVoiceControlSliderView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 100)];
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView addBorderLineWithColor:RGBSTRING(@"cccccc") borderWidth:1 direction:kBorderLineDirectionTop | kBorderLineDirectionBottom];
    [self.view addSubview:bgView];
    
    // 左边喇叭
    UIImage *leftVoiveImage = GETNCIMAGE(@"CameraSetting_voiceDisable.png");
    UIButton *leftVoiceView = [[UIButton alloc] initWithFrame:CGRectMake(15, (VIEW_H(bgView) - leftVoiveImage.size.height) / 2, leftVoiveImage.size.width, leftVoiveImage.size.height)];
    [leftVoiceView setImage:leftVoiveImage forState:UIControlStateNormal];
    [leftVoiceView addTarget:self action:@selector(voiceButton_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    leftVoiceView.tag = 99;
    [bgView addSubview:leftVoiceView];
    
    // 右边喇叭
    UIImage *rightVoiveImage = GETNCIMAGE(@"CameraSetting_voiceEnable.png");
    UIButton *rightVoiceView = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - rightVoiveImage.size.width, (VIEW_H(bgView) - rightVoiveImage.size.height) / 2, rightVoiveImage.size.width, rightVoiveImage.size.height)];
    [rightVoiceView addTarget:self action:@selector(voiceButton_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    rightVoiceView.tag = 100;
    [rightVoiceView setImage:rightVoiveImage forState:UIControlStateNormal];
    [bgView addSubview:rightVoiceView];
    
    //左右轨的图片
    UIImage *stetchLeftTrack= GETNCIMAGE(@"CameraSetting_voiceMiniTrackImage.png");
    UIImage *stetchRightTrack = GETNCIMAGE(@"CameraSetting_voiceMaxiTrackImage.png");
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"CameraSetting_voiceThumbImage.png"];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(VIEW_W_X(leftVoiceView) + 15, (VIEW_H(bgView) - stetchLeftTrack.size.height) / 2, SCREEN_WIDTH - (30 + rightVoiveImage.size.width) - (VIEW_W_X(leftVoiceView) + 15), stetchLeftTrack.size.height)];
    slider.backgroundColor = [UIColor clearColor];
    
    slider.value = [self.volumeString intValue]/100.0;
    
    [slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    //滑块拖动时的事件
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //    [slider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if (self.volumeString.length) {
        _valueLabel.text = [NSString stringWithFormat:@"%@%%",self.volumeString];
        [self sliderValueChanged:slider];
    }
    
    
}

- (void)sliderValueChanged:(UISlider *)sender {
    
    _valueLabel.text = [NSString stringWithFormat:@"%.f%%", sender.value * 100];
    
    CGPoint valueBgCenter = _valueBg.center;
    valueBgCenter.x = (VIEW_W(sender) - VIEW_W(_valueBg) / 2) * sender.value + VIEW_X(sender) + VIEW_W(_valueBg) / 2 - sender.currentThumbImage.size.width/2 * sender.value;
    _valueBg.center = valueBgCenter;
}

- (void)voiceButton_clicked_action:(UIButton *)sender {
    
    if (sender.tag == 99) {
        // 声音最小
        _slider.value = 0;
    } else if (sender.tag == 100) {
        //  声音最大
        _slider.value = 1;
    }
    
    [self sliderValueChanged:_slider];
}

@end
