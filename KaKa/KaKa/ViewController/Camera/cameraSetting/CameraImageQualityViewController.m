//
//  CameraImageQualityViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraImageQualityViewController.h"

@interface CameraImageQualityViewController ()

@property (nonatomic, strong) NSArray *namesArray;

@property (nonatomic, strong) UIButton *selectedRadioBtn;

@property (nonatomic, strong) UILabel *imageModeLabel;

@end

@implementation CameraImageQualityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"图像质量"];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        if (weakSelf.selectedRadioBtn.tag == 1) {
            
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%ld",weakSelf.selectedRadioBtn.tag+1]];
        }
        else if (weakSelf.selectedRadioBtn.tag == 2)
        {
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%ld",weakSelf.selectedRadioBtn.tag-1]];
        }
        else if (weakSelf.selectedRadioBtn.tag == 3)
        {
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%ld",weakSelf.selectedRadioBtn.tag-3]];
        }

    }];
    
    [self addImageQualityView];
}


-(void)socketWithBody:(NSString *)body
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    
    
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.videoRecord.type=\"%@\"",body];
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

- (void)addImageQualityView {
    
    NSString *video_type;
    if ([self.detailString isEqualToString:@"0"]) {
        
        video_type = @"标清（800*480)";
    }
    else if ([self.detailString isEqualToString:@"1"])
    {
        video_type = @"高清（1280*720)";
    }
    else
    {
        video_type = @"全高清（1920*1080)";
    }
    
    _imageModeLabel = [self labelWithFrame:CGRectMake(15, 24, SCREEN_WIDTH - 30, 18) inView:self.view textColor:RGBSTRING(@"B11C22") fontSize:32 * FONTCALE_Y text:[NSString stringWithFormat:@"图像质量：%@",video_type] alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    [self labelWithFrame:CGRectMake(15, VIEW_H_Y(_imageModeLabel) + 15, SCREEN_WIDTH - 30, 14) inView:self.view textColor:RGBSTRING(@"777777") fontSize:24 * FONTCALE_Y text:@"大约可录制01:11:48" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 83, SCREEN_WIDTH, 1)];
    line.backgroundColor = RGBSTRING(@"cccccc");
    [self.view addSubview:line];
    
    _namesArray = @[@"全高清（1920*1080）", @"高清（1280*720）", @"标清（800*480）"];
    UIImage *radioNorImage = GETNCIMAGE(@"camera_radioBtn_nor.png");
    UIImage *radioSelImage = GETNCIMAGE(@"camera_radioBtn_sel.png");
    for (NSInteger i = 0; i < _namesArray.count; i++) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 84 + i * 51, SCREEN_WIDTH, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        
        
        [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView)) inView:bgView textColor:RGBSTRING(@"333333") fontSize:FONTCALE_Y * 28 text:_namesArray[i] alignment:NSTextAlignmentLeft bold:NO fit:NO];
        
        // 选择按钮
        UIButton *selBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - (30 + radioNorImage.size.width), (50 - radioNorImage.size.height) / 2, 30 + radioNorImage.size.width, radioNorImage.size.height)];
        selBtn.tag = i + 1;
        [selBtn setImage:radioNorImage forState:UIControlStateNormal];
        [selBtn setImage:radioSelImage forState:UIControlStateDisabled];
        [selBtn addTarget:self action:@selector(selectRadioBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:selBtn];
        if ([self.detailString intValue] == 2 && i == 0) {
            selBtn.enabled = NO;
            _selectedRadioBtn = selBtn;
            
        }
        else if ([self.detailString intValue] == 1 && i == 1)
        {
            selBtn.enabled = NO;
            _selectedRadioBtn = selBtn;
        }
        else if ([self.detailString intValue] == 0 && i == 2)
        {
            selBtn.enabled = NO;
            _selectedRadioBtn = selBtn;
        }
        
        if (i == 1 || i == 2 ) {
            bgView.hidden = YES;
        }

        
        if (i == 0) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(bgView), SCREEN_WIDTH, 1)];
            line.backgroundColor = RGBSTRING(@"cccccc");
            [self.view addSubview:line];
            
            [self selectRadioBtn_clicked_action:selBtn];
        }
        
        
        
        
    }
    
}

- (void)selectRadioBtn_clicked_action:(UIButton *)sender {
    
    _selectedRadioBtn.enabled = YES;
    
    sender.enabled = NO;
    _selectedRadioBtn = sender;
    
    if (sender.tag - 1 < _namesArray.count) {
        _imageModeLabel.text = [NSString stringWithFormat:@"图片质量：%@", [_namesArray objectAtIndex:sender.tag - 1]];
    }
}


@end
