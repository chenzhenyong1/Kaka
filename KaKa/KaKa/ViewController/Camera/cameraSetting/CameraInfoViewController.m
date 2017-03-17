//
//  CameraInfoViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/26.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraInfoViewController.h"
#import "WHC_XMLParser.h"
#import <sys/utsname.h>
#import "MyTools.h"
@interface CameraInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) NSMutableArray *subtitlesArray;

@end

@implementation CameraInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButtonWith:nil];
    
    [self addTitle:@"摄像机信息"];
    
    NSLog(@"设备名称: %@",[self iphoneType]);
    NSDictionary *cdrSystemInfomation = VALUEFORKEY(self.detail_dic, @"cdrSystemInfomation");
    
    NSString *time  = FORMATSTRING(VALUEFORKEY(self.detail_dic, @"systemstarttime"));
    time = [MyTools yearToTimestamp:time];
    time = [MyTools timestampChangesStandarTimeMinute:time];
    NSString *free = [NSString stringWithFormat:@"%.1fGB",[FORMATSTRING(VALUEFORKEY(self.SD_dic, @"free")) intValue]/1024.0];
    NSString *all_size = [NSString stringWithFormat:@"%.1fGB",[FORMATSTRING(VALUEFORKEY(self.SD_dic, @"size")) intValue]/1024.0];
    _titlesArray = [NSMutableArray arrayWithArray:@[@"固件版本:",@"硬件版本:", @"序列号:", @"摄像机本次运行时间:", @"本次登录:", @"储存容量:", @"总容量:"]];
    _subtitlesArray = [NSMutableArray arrayWithArray:@[VALUEFORKEY(cdrSystemInfomation, @"cdrSoftwareVersion"),VALUEFORKEY(cdrSystemInfomation, @"cdrHardwareVersion"), VALUEFORKEY(cdrSystemInfomation, @"cdrDeviceSN"), time, [self iphoneType], free, all_size]];
    
    [self.view addSubview:self.tableView];
    
   
    
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT)];
        _tableView.backgroundColor = RGBSTRING(@"eeeeee");
        _tableView.tableFooterView = [[UIView alloc] init];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 165)];
        _tableView.tableHeaderView = headView;
        
        UIImage *logoImage = GETNCIMAGE(@"camera_info_logo.png");
        UIImageView *logoImageV = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - logoImage.size.width) / 2, 0, logoImage.size.width, logoImage.size.height)];
        logoImageV.image = logoImage;
        [headView addSubview:logoImageV];
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kIdentifier];
        
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:28 * FONTCALE_Y];
    cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
    cell.textLabel.text = [_titlesArray objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:25 * FONTCALE_Y];
    cell.detailTextLabel.textColor = RGBACOLOR(119, 119, 119, 1);
    cell.detailTextLabel.text = [_subtitlesArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)iphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    return platform;
    
}

@end
