//
//  CameraStoreManagementViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraStoreManagementViewController.h"
#import "XYPieChart.h"
#import "WHC_XMLParser.h"
@interface CameraStoreManagementViewController () <XYPieChartDataSource,UIAlertViewDelegate>
// 总容量
@property (nonatomic, strong) UILabel *totalCapacityLabel;

@property (nonatomic, strong) XYPieChart *pieChart;
@property(nonatomic, strong) NSArray     *sliceColors;
@property (nonatomic, strong) NSMutableArray *slices;
@end

@implementation CameraStoreManagementViewController
{
    UILabel *photoLab;
    UILabel *videoLab;
    UILabel *otherLab;
    UILabel *freeLab;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"存储管理"];
    
    self.view.backgroundColor = RGBSTRING(@"eeeeee");

    // 总容量
    [self addTotalCapacityView];
}

- (void)addTotalCapacityView {
    // 总容量
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 22 * PSDSCALE_Y, SCREEN_WIDTH, 50)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    // 总容量label
    UILabel *totalCapacityLabel = [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH / 2, VIEW_H(bgView)) inView:bgView textColor:RGBSTRING(@"333333") fontSize:28 * FONTCALE_Y text:[NSString stringWithFormat:@"总容量：%.2fGB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"size")) intValue]/1024.0] alignment:NSTextAlignmentLeft bold:NO fit:NO];
    _totalCapacityLabel = totalCapacityLabel;
    
    __weak typeof(self) weakSelf = self;
    [self buttonWithFrame:CGRectMake(SCREEN_WIDTH - 87, (VIEW_H(bgView) - 33) / 2, 72, 33) inView:bgView title:@"格式化" titleColorNormal:RGBSTRING(@"333333") titleColorSelected:nil titleFontSize:28 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:4 borderWidth:1 borderColor:RGBACOLOR(119, 119, 119, 1) block:^(UIButton *sender) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定格式化吗?" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }];
    
    NSString *free_str = [[NSString alloc] init];
    if ([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"free")) intValue]>1024)
    {
        free_str = [NSString stringWithFormat:@"剩余：%.2fGB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"free")) intValue]/1024.0];
    }
    else
    {
        free_str = [NSString stringWithFormat:@"剩余：%dMB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"free")) intValue]];
    }
    
    NSString *photo_size = [[NSString alloc] init];
    if ([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"photoSize")) intValue]>1024)
    {
        photo_size = [NSString stringWithFormat:@"照片：%.2fGB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"photoSize")) intValue]/1024.0];
    }
    else
    {
        photo_size = [NSString stringWithFormat:@"照片：%dMB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"photoSize")) intValue]];
    }
    
    NSString *video_size = [[NSString alloc] init];
    if (([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"protectVideoSize")) intValue] +[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"recVideoSize")) intValue])>1024)
    {
        video_size = [NSString stringWithFormat:@"视频：%.2fGB",([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"protectVideoSize")) intValue] +[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"recVideoSize")) intValue])/1024.0];
    }
    else
    {
        video_size = [NSString stringWithFormat:@"视频：%dMB",([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"protectVideoSize")) intValue] +[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"recVideoSize")) intValue])];
    }
    
    NSString *other_size = [[NSString alloc] init];
    if ([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"other")) intValue] >1024)
    {
        other_size = [NSString stringWithFormat:@"系统：%.2fGB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"other")) intValue]/1024.0];
    }
    else
    {
        other_size = [NSString stringWithFormat:@"系统：%dMB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"other")) intValue]];
    }
    
    
    
    NSArray *colors = @[RGBSTRING(@"b11c22"), RGBSTRING(@"ff4e4e"), RGBSTRING(@"ff98b8"), RGBSTRING(@"ffffff")];
    NSArray *values = @[photo_size, video_size, other_size,free_str];
    CGFloat leftMargin = 156 * PSDSCALE_X;
    CGFloat rightMargin = 40 * PSDSCALE_X;
    CGFloat colorViewWidth = 10;
    CGFloat space = 5;
    CGFloat labelWidth = (SCREEN_WIDTH - leftMargin - rightMargin - 2 * (space + colorViewWidth)) / 2;
    CGFloat labelHeight = 27 * PSDSCALE_Y;
    
    photoLab = [[UILabel alloc] init];
    videoLab = [[UILabel alloc] init];
    otherLab = [[UILabel alloc] init];
    freeLab = [[UILabel alloc] init];
    
    for (NSInteger i = 0; i < colors.count; i++) {
        
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin + (i % 2) * (space + labelWidth + colorViewWidth), 200 * PSDSCALE_Y + (i / 2) * 56 * PSDSCALE_Y, colorViewWidth, colorViewWidth)];
        colorView.backgroundColor = colors[i];
        colorView.layer.cornerRadius = colorViewWidth / 2;
        colorView.layer.masksToBounds = YES;
        [self.view addSubview:colorView];
        
        if (i == 0)
        {
            photoLab.frame =CGRectMake(VIEW_W_X(colorView) + space, VIEW_Y(colorView) - (labelHeight - colorViewWidth)/2, labelWidth, labelHeight);
            photoLab.text = values[i];
            photoLab.textColor = RGBSTRING(@"333333");
            photoLab.font = [UIFont systemFontOfSize:FONTCALE_Y * 25];
            photoLab.textAlignment = NSTextAlignmentLeft;
            [self.view addSubview:photoLab];
        }
        
        if (i == 1)
        {
            videoLab.frame =CGRectMake(VIEW_W_X(colorView) + space, VIEW_Y(colorView) - (labelHeight - colorViewWidth)/2, labelWidth, labelHeight);
            videoLab.text = values[i];
            videoLab.textColor = RGBSTRING(@"333333");
            videoLab.font = [UIFont systemFontOfSize:FONTCALE_Y * 25];
            videoLab.textAlignment = NSTextAlignmentLeft;
            [self.view addSubview:videoLab];
        }
        if (i == 2)
        {
            otherLab.frame =CGRectMake(VIEW_W_X(colorView) + space, VIEW_Y(colorView) - (labelHeight - colorViewWidth)/2, labelWidth, labelHeight);
            otherLab.text = values[i];
            otherLab.textColor = RGBSTRING(@"333333");
            otherLab.font = [UIFont systemFontOfSize:FONTCALE_Y * 25];
            otherLab.textAlignment = NSTextAlignmentLeft;
            [self.view addSubview:otherLab];
        }
        if (i == 3)
        {
            freeLab.frame =CGRectMake(VIEW_W_X(colorView) + space, VIEW_Y(colorView) - (labelHeight - colorViewWidth)/2, labelWidth, labelHeight);
            freeLab.text = values[i];
            freeLab.textColor = RGBSTRING(@"333333");
            freeLab.font = [UIFont systemFontOfSize:FONTCALE_Y * 25];
            freeLab.textAlignment = NSTextAlignmentLeft;
            [self.view addSubview:freeLab];
        }
        
        
    }
    
    self.slices = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"photoSize")) intValue]],
                   [NSNumber numberWithFloat:[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"free")) intValue]],
                   [NSNumber numberWithFloat:[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"other")) intValue]],
                   [NSNumber numberWithFloat:([FORMATSTRING(VALUEFORKEY(self.detail_dic, @"protectVideoSize")) intValue] +[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"recVideoSize")) intValue])], nil];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       RGBSTRING(@"b11c22"),
                       RGBSTRING(@"ffffff"),
                       RGBSTRING(@"ff98b8"),
                       RGBSTRING(@"ff4e4e"),nil];
    
    self.pieChart = [[XYPieChart alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-370*PSDSCALE_X)/2, 480*PSDSCALE_Y, 370*PSDSCALE_X, 370*PSDSCALE_Y)];
    [self.pieChart setDataSource:self];
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setStartPieAngle:M_PI_2*1.5];
    [self.pieChart setLabelColor:[UIColor clearColor]];
    [self.view addSubview:self.pieChart];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            [self addActityLoading:nil subTitle:nil];
            AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
            MsgModel *msg = [[MsgModel alloc] init];
            msg.cmdId = @"0B";
            msg.token = [SettingConfig shareInstance].deviceLoginToken;
            __weak typeof(self) weakSelf = self;
            [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                [self removeActityLoading];
                if ([msg.msgBody isEqualToString:@"OK"])
                {
//                    [socketManager disconnectSocket];
                    [weakSelf addActityText:@"格式化成功" deleyTime:1];
                    
                    photoLab.text = @"照片：0MB";
                    videoLab.text = @"视频：0MB";
                    otherLab.text = @"系统：0MB";
                    freeLab.text = [NSString stringWithFormat:@"剩余：%.2fGB",[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"size")) intValue]/1024.0];
                    [weakSelf.slices removeAllObjects];
                    weakSelf.slices = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:[FORMATSTRING(VALUEFORKEY(self.detail_dic, @"size")) intValue]], nil];
                    weakSelf.sliceColors =[NSArray arrayWithObjects:RGBSTRING(@"ffffff"),nil];
                    [weakSelf.pieChart reloadData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"upload_action" object:nil];
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        
                    });
                    
                }
                else
                {
                    [weakSelf addActityText:@"格式化失败" deleyTime:1];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}








- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieChart reloadData];
}


#pragma mark - XYPieChartDataSource
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    
    return self.sliceColors.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    
    return [self.slices[index] floatValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    
    return [self.sliceColors objectAtIndex:index];
}
- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    
    return nil;
}

@end
