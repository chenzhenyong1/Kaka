//
//  MeAppCacheViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeAppCacheViewController.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "MeSettingAppCaCheViewController.h"
#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTools.h"
@interface MeAppCacheViewController ()<XYPieChartDelegate, XYPieChartDataSource>
@property (nonatomic, strong) XYPieChart *pieChart;
@property (nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray        *sliceColors;

@end

@implementation MeAppCacheViewController
{
    UILabel *caCheLab;
    UITextField *caCheTextField;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"存储管理" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    MMLog(@"%@",[self freeDiskSpaceInBytes]);
    MMLog(@"%@",[self getTotalDiskSize]);
    
//    MMLog(@"%@",[NSString stringWithFormat:@"%.2f MB",[self usedMemory]]);
    MMLog(@"%@",CACHE_PATH);
    
    [self initUI];
}

//查询文件大小
//- (double)usedMemory
//{
//    task_basic_info_data_t taskInfo;
//    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
//    kern_return_t kernReturn = task_info(mach_task_self(),
//                                         TASK_BASIC_INFO,
//                                         (task_info_t)&taskInfo,
//                                         &infoCount);
//    
//    if (kernReturn != KERN_SUCCESS
//        ) {
//        return NSNotFound;
//    }
//    
//    return taskInfo.resident_size / 1024.0 / 1024.0;
//}
-(CGFloat)folderSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    float folderSize = 0;
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        
        for (NSString *fileName in childerFiles) {
            
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            
            
            
            long long size = [fileManager attributesOfItemAtPath:absolutePath error:nil].fileSize;
            float size1 = 0.0f;
            size1 = size/1024/1024.0;
            
            // 计算单个文件大小
            folderSize += size1;
        }
        
        MMLog(@"%f",folderSize);
        return folderSize/1024.0;
    }
    else
        
        return 0;
}

- (void)initUI
{
    UIView *caCheView = [[UIView alloc] initWithFrame:CGRectMake(0, 22*PSDSCALE_Y, SCREEN_WIDTH, 100*PSDSCALE_Y)];
    caCheView.backgroundColor = [UIColor whiteColor];
    caCheView.userInteractionEnabled = YES;
    caCheView.layer.borderWidth = 1;
    caCheView.layer.borderColor = RGBSTRING(@"cccccc").CGColor;
    [self.view addSubview:caCheView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cacheView_click)];
    [caCheView addGestureRecognizer:tap];
    
    
    UILabel *reserveLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 33*PSDSCALE_Y, 225*PSDSCALE_X, 35*PSDSCALE_Y)];
    reserveLab.textAlignment = NSTextAlignmentRight;
    reserveLab.text = @"预留可用空间";
    reserveLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [caCheView addSubview:reserveLab];
    
    
    caCheLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 35*PSDSCALE_Y, 678*PSDSCALE_X, 32*PSDSCALE_Y)];
    NSString *str = [UserDefaults objectForKey:@"Reserved"];
    if (str.length !=0)
    {
        caCheLab.text = [NSString stringWithFormat:@"%@MB",[UserDefaults objectForKey:@"Reserved"]];
    }
    else
    {
        caCheLab.text = @"0MB";
    }
    caCheLab.textAlignment = NSTextAlignmentRight;
    caCheLab.textColor = RGBSTRING(@"777777");
    caCheLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [caCheView addSubview:caCheLab];
    
    UIImageView *jiantouView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(caCheLab)+23*PSDSCALE_X, 32*PSDSCALE_Y, 19*PSDSCALE_X, 33*PSDSCALE_Y)];
    jiantouView.image = GETYCIMAGE(@"me_right_jiantou");
    [caCheView addSubview:jiantouView];
    
    UILabel *explainLab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(caCheView)+19*PSDSCALE_Y, 600*PSDSCALE_X, 27*PSDSCALE_Y)];
    explainLab.text = @"如果剩余存储空间小于预留可用空间，本次不再下载。";
    explainLab.textAlignment = NSTextAlignmentRight;
    explainLab.font = [UIFont systemFontOfSize:20*FONTCALE_Y];
    explainLab.textColor = RGBSTRING(@"777777");
    [self.view addSubview:explainLab];
    
    UIView *diskView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(caCheView)+79*PSDSCALE_Y, SCREEN_WIDTH, 190*PSDSCALE_Y)];
    diskView.backgroundColor = [UIColor whiteColor];
    diskView.layer.borderWidth = 1;
    diskView.layer.borderColor = RGBSTRING(@"cccccc").CGColor;
    [self.view addSubview:diskView];
    
    UILabel *total_capacity = [[UILabel alloc] initWithFrame:CGRectMake(0, 36*PSDSCALE_Y, 112*PSDSCALE_X,35*PSDSCALE_Y)];
    total_capacity.text = @"总容量";
    total_capacity.textAlignment = NSTextAlignmentRight;
    total_capacity.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
    total_capacity.textColor = [UIColor blackColor];
    [diskView addSubview:total_capacity];
    
    UILabel *allDiskLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 38*PSDSCALE_Y, 718*PSDSCALE_X, 35*PSDSCALE_Y)];
    allDiskLab.textAlignment = NSTextAlignmentRight;
    allDiskLab.textColor = [UIColor blackColor];
    allDiskLab.text = [NSString stringWithFormat:@"%@GB",[self getTotalDiskSize]];
    allDiskLab.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
    [diskView addSubview:allDiskLab];
    
    
    UIView *allProgressView = [[UILabel alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(total_capacity)+56*PSDSCALE_Y, 690*PSDSCALE_X, 23*PSDSCALE_Y)];
    allProgressView.backgroundColor = RGBSTRING(@"dcdcdc");
    allProgressView.layer.masksToBounds = YES;
    allProgressView.layer.cornerRadius = 6;
    [diskView addSubview:allProgressView];
    
    int a = [[self freeDiskSpaceInBytes] intValue];//剩余容量
    
    float b = [[self getTotalDiskSize] floatValue];//总容量
    
    UILabel *freeProgressView = [[UILabel alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(total_capacity)+56*PSDSCALE_Y, 0, 23*PSDSCALE_Y)];
    freeProgressView.backgroundColor = RGBSTRING(@"b11c22");
    freeProgressView.layer.masksToBounds = YES;
    freeProgressView.layer.cornerRadius = 6;
    [diskView addSubview:freeProgressView];
    
    [UIView animateWithDuration:2 animations:^{
        CGRect frame = freeProgressView.frame;
        frame.size.width = (690*a/b)*PSDSCALE_X;
        freeProgressView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
    self.slices = [NSMutableArray arrayWithCapacity:10];
    
    //使用的
    [_slices addObject:@([[self getTotalDiskSize] doubleValue]-[[self freeDiskSpaceInBytes] doubleValue]-[self folderSizeAtPath:CACHE_PATH])];
    
    
    [_slices addObject:@([[self freeDiskSpaceInBytes] doubleValue])];
    
    [_slices addObject:@([[NSString stringWithFormat:@"%.2f",[self folderSizeAtPath:CACHE_PATH]] doubleValue])];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       RGBSTRING(@"b11c22"),
                       RGBSTRING(@"ff4e4e"),RGBSTRING(@"ff98b8"),nil];
    
    self.pieChart = [[XYPieChart alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-370*PSDSCALE_X)/2, VIEW_H_Y(diskView)+62*PSDSCALE_Y, 370*PSDSCALE_X, 370*PSDSCALE_Y)];
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setLabelColor:[UIColor blackColor]];
    [self.pieChart setLabelFont:[UIFont systemFontOfSize:30*FONTCALE_Y]];
    
    [self.view addSubview:self.pieChart];
    
    
    UIView *systemUserSize = [[UIView alloc] initWithFrame:CGRectMake(156*PSDSCALE_X, VIEW_H_Y(self.pieChart)+57*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    systemUserSize.backgroundColor = RGBSTRING(@"b11c22");
    systemUserSize.layer.masksToBounds = YES;
    systemUserSize.layer.cornerRadius = 10*PSDSCALE_X;
    [self.view addSubview:systemUserSize];
    
    UILabel *systeUserSzie_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(systemUserSize)+10*PSDSCALE_X, VIEW_H_Y(self.pieChart)+50*PSDSCALE_Y, 180*PSDSCALE_X, 32*PSDSCALE_Y)];
    
    systeUserSzie_lab.text = [NSString stringWithFormat:@"系统:%.2fGB",[_slices.firstObject doubleValue]];
    systeUserSzie_lab.textAlignment = NSTextAlignmentLeft;
    systeUserSzie_lab.textColor = [UIColor blackColor];
    systeUserSzie_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:systeUserSzie_lab];
    
    
    UIView *freeDiskSize = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W_X(systeUserSzie_lab)+50*PSDSCALE_X, VIEW_Y(systemUserSize), 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    freeDiskSize.backgroundColor = RGBSTRING(@"ff4e4e");
    freeDiskSize.layer.masksToBounds = YES;
    freeDiskSize.layer.cornerRadius = 10*PSDSCALE_X;
    [self.view addSubview:freeDiskSize];
    
    
    UILabel *freeDiskSize_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(freeDiskSize)+10*PSDSCALE_X, VIEW_H_Y(self.pieChart)+50*PSDSCALE_Y, 160*PSDSCALE_X, 32*PSDSCALE_Y)];
    
    freeDiskSize_lab.text = [NSString stringWithFormat:@"剩余:%.2fGB",[_slices[1] doubleValue]];
    freeDiskSize_lab.textAlignment = NSTextAlignmentLeft;
    freeDiskSize_lab.textColor = [UIColor blackColor];
    freeDiskSize_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:freeDiskSize_lab];
    
    
    
    UIView *kakaDiskSize = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(systemUserSize), VIEW_Y(systemUserSize)+100*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    kakaDiskSize.backgroundColor = RGBSTRING(@"ff98b8");
    kakaDiskSize.layer.masksToBounds = YES;
    kakaDiskSize.layer.cornerRadius = 10*PSDSCALE_X;
    [self.view addSubview:kakaDiskSize];
    
    
    UILabel *kakaDiskSize_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(kakaDiskSize)+10*PSDSCALE_X, VIEW_H_Y(systeUserSzie_lab)+70*PSDSCALE_Y, 190*PSDSCALE_X, 32*PSDSCALE_Y)];
    
    kakaDiskSize_lab.text = [NSString stringWithFormat:@"咔咔:%.2fMB",[_slices.lastObject doubleValue]*1024];
    kakaDiskSize_lab.textAlignment = NSTextAlignmentLeft;
    kakaDiskSize_lab.textColor = [UIColor blackColor];
    kakaDiskSize_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:kakaDiskSize_lab];
    
    
    UILabel *kaka_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(kakaDiskSize_lab)+50*PSDSCALE_Y, SCREEN_WIDTH, 32*PSDSCALE_Y)];
    
    NSArray *photo_pathArr =[MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
    NSArray *video_photo_pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
    
    
    NSInteger photo_all_num = ([[self freeDiskSpaceInBytes] integerValue]*1024)/(350/1024.0);
    kaka_lab.text = [NSString stringWithFormat:@"当前照片%ld张，最多还能存储%ld张",[photo_pathArr count]+[video_photo_pathArr count],photo_all_num];
    kaka_lab.textAlignment = NSTextAlignmentCenter;
    kaka_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:kaka_lab];
    
    
    UILabel *kaka_Vide_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(kaka_lab)+10*PSDSCALE_Y, SCREEN_WIDTH, 32*PSDSCALE_Y)];
    
    NSArray *video_pathArr = [MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
    
    NSInteger video_all_num = ([[self freeDiskSpaceInBytes] integerValue]*1024)/5;
    kaka_Vide_lab.text = [NSString stringWithFormat:@"当前视频%ld个，最多还能存储%ld个",[video_pathArr count],video_all_num];
    kaka_Vide_lab.textAlignment = NSTextAlignmentCenter;
    kaka_Vide_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:kaka_Vide_lab];
    
    
    
//    UIImageView *bg_View = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-814*PSDSCALE_Y-NAVIGATIONBARHEIGHT, SCREEN_WIDTH, 814*PSDSCALE_Y)];
//    bg_View.image = GETYCIMAGE(@"me_caChe");
//    [self.view addSubview:bg_View];

    
}

- (void)cacheView_click
{
    
    MeSettingAppCaCheViewController *settingAppCacheVC = [[MeSettingAppCaCheViewController alloc] init];
    settingAppCacheVC.block = ^(NSString *text){
        caCheLab.text = [NSString stringWithFormat:@"%@MB",text];
        [UserDefaults setObject:text forKey:@"Reserved"];
        [UserDefaults synchronize];
        
        MMLog(@"------%@",[UserDefaults objectForKey:@"Reserved"]);
    };
    [self.navigationController pushViewController:settingAppCacheVC animated:YES];
}



//获取手机剩余空间

- (NSString *)freeDiskSpaceInBytes{
    
    struct statfs buf;
    
    long long freeSpace = -1;
    
    if(statfs("/var", &buf) >= 0){
        
        freeSpace = (long long)(buf.f_bsize * buf.f_bfree);
        
    }
    
    return [NSString stringWithFormat:@"%.2f" ,(double)roundf(freeSpace/1024/1024/1024.0)];
    
}

//获取手机总空间
- (NSString *)getTotalDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return [NSString stringWithFormat:@"%.2f" ,(double)roundf(freeSpace/1024/1024/1024.0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieChart reloadData];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] doubleValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    //    if(pieChart == self.pieChartRight) return nil;
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
    //    self.selectedSliceLabel.text = [NSString stringWithFormat:@"$%@",[self.slices objectAtIndex:index]];
}




@end
