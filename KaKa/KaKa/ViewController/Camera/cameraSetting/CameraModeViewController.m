//
//  CameraModeViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraModeViewController.h"

@interface CameraModeViewController ()

@property (nonatomic, strong) UIButton *selectedRadioBtn;
@end

@implementation CameraModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"摄像模式"];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addImageModeSelView];
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        if (weakSelf.selectedRadioBtn.tag == 1) {
            
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%ld",weakSelf.selectedRadioBtn.tag-1]];
        }
        else if (weakSelf.selectedRadioBtn.tag == 2)
        {
            [weakSelf socketWithBody:[NSString stringWithFormat:@"%ld",weakSelf.selectedRadioBtn.tag-1]];
        }
        
    }];
    
    
}

-(void)socketWithBody:(NSString *)body
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.videoRecord.mode=\"%@\"",body];
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

- (void)addImageModeSelView {
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 1)];
    line.backgroundColor = RGBSTRING(@"cccccc");
    [self.view addSubview:line];
    
    NSArray *namesArray = @[@"全屏模式（16：9）", @"影院宽屏模式（2.4：1）"];
    UIImage *radioNorImage = GETNCIMAGE(@"camera_radioBtn_nor.png");
    UIImage *radioSelImage = GETNCIMAGE(@"camera_radioBtn_sel.png");
    for (NSInteger i = 0; i < namesArray.count; i++) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 16 + i * 51, SCREEN_WIDTH, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView)) inView:bgView textColor:RGBSTRING(@"333333") fontSize:FONTCALE_Y * 28 text:namesArray[i] alignment:NSTextAlignmentLeft bold:NO fit:NO];
        
        // 选择按钮
        UIButton *selBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - (30 + radioNorImage.size.width), (50 - radioNorImage.size.height) / 2, 30 + radioNorImage.size.width, radioNorImage.size.height)];
        selBtn.tag = i + 1;
        [selBtn setImage:radioNorImage forState:UIControlStateNormal];
        [selBtn setImage:radioSelImage forState:UIControlStateDisabled];
        [selBtn addTarget:self action:@selector(selectRadioBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:selBtn];
        if ([self.detailString intValue] == 0 && i == 0) {
            selBtn.enabled = NO;
            _selectedRadioBtn = selBtn;
            
        }
        else if ([self.detailString intValue] == 1 && i == 1)
        {
            selBtn.enabled = NO;
            _selectedRadioBtn = selBtn;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(bgView), SCREEN_WIDTH, 1)];
        line.backgroundColor = RGBSTRING(@"cccccc");
        [self.view addSubview:line];
        
    }
    
}

- (void)selectRadioBtn_clicked_action:(UIButton *)sender {
    
    _selectedRadioBtn.enabled = YES;
    
    sender.enabled = NO;
    _selectedRadioBtn = sender;
    
}


@end
