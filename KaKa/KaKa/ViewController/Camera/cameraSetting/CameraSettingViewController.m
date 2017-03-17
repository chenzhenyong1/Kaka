//
//  CameraSettingViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraSettingViewController.h"

#import "CameraNameViewController.h"
#import "CameraPwdViewController.h"
#import "CameraVolumeCtrlViewController.h"
#import "CameraBluetoothHFViewController.h"
#import "CameraRecordingSensitivityViewController.h"
#import "CameraImageQualityViewController.h"
#import "CameraModeViewController.h"
#import "CameraHighSettingViewController.h"
#import "CameraStoreManagementViewController.h"
#import "CameraInfoViewController.h"
#import "WHC_XMLParser.h"
#import "CameraFMSettingViewController.h"//FM发射设置
#import "CameraDetailViewController.h"

@interface CameraSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISwitch *edogSwitch;
@property (nonatomic, strong) UISwitch *relateVideoSwitch;

@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) NSMutableArray *subtitlesArray;
@property (nonatomic, strong) NSDictionary *cdrSystemCfg;//设置信息
@property (nonatomic, strong) NSDictionary *cdrSdInformation;//内存信息
@property (nonatomic, assign)  BOOL isPush;//是否跳转;

@end

@implementation CameraSettingViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isPush)
    {
        [self getSocketData];
        _isPush = NO;
    }
}

-(void)dealloc
{
    NSLog(@"释放");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titlesArray = [NSMutableArray arrayWithArray:@[@"摄像机名称", @"摄像机密码", @"音量调节", @"录像时录音", @"蓝牙免提",@"FM发射频率设置", @"拍照关联视频", @"图像质量", @"摄像模式", @"高级设置", @"摄像头存储管理", @"摄像机信息"]];
    _subtitlesArray = [NSMutableArray arrayWithArray:@[@"摄像机头1", @"", @"0%", @"", @"",@"0MHz", @"", @"", @"", @"", @"剩余可用容量0GB", @""]];
    
    [self addTitle:@"摄像头设置"];
    
    [self addBackButtonWith:nil];
    
//    __weak typeof(self) weakSelf = self;
//    [self addRightButtonWithName:GETNCIMAGE(@"camera_refresh_icon.png") wordNum:2 actionBlock:^(UIButton *sender) {
//        [weakSelf getSocketData];
//        
//    }];
    [self.view addSubview:self.tableView];
    
    
    
    [self getSocketData];
    
    
    
   
}

//电子狗
- (void)edogSwitch_click:(UISwitch *)sender
{
    NSString *body;
    if (sender.on)
    {
        body = @"1";
    }
    else
    {
        body = @"0";
    }
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.eDog=\"%@\"",body];
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            [weakSelf addActityText:@"修改成功" deleyTime:1];
        }
        
    }];

}

- (void)relateVideoSwitch_click:(UISwitch *)sender
{
    NSString *body;
    if (sender.on)
    {
        body = @"1";
    }
    else
    {
        body = @"0";
    }
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [NSString stringWithFormat:@"cdrSystemCfg.photoWithVideo=\"%@\"",body];
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            MMLog(@"hahah");
            [weakSelf addActityText:@"修改成功" deleyTime:1];
            if ([body isEqualToString:@"1"])
            {
                [SettingConfig shareInstance].isPhotoWithVideo =YES;
            }
            else
            {
                [SettingConfig shareInstance].isPhotoWithVideo =NO;
            }
            
        }
        
    }];
}


- (void)getSDData
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"09";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        NSString *body = msg.msgBody;
        NSString *urlString = [NSString stringWithFormat:@"http://%@/tmp/%@",[SettingConfig shareInstance].ip_url,body];
        [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {
            
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            MMLog(@"%@",dic);
            weakSelf.cdrSdInformation = VALUEFORKEY(dic, @"cdrSDInformation");
            NSString *str = FORMATSTRING(VALUEFORKEY(weakSelf.cdrSdInformation, @"free"));
            if (str.length == 0) {
                str = @"0";
            }
            if ([str intValue]>1024) {
                str = [NSString stringWithFormat:@"%.2f",[str intValue]/1024.0];
                [weakSelf.subtitlesArray replaceObjectAtIndex:10 withObject:[NSString stringWithFormat:@"剩余可用容量%@G",str]];
            }
            else
            {
                [weakSelf.subtitlesArray replaceObjectAtIndex:10 withObject:[NSString stringWithFormat:@"剩余可用容量%@M",str]];
            }
            
             [weakSelf.tableView reloadData];
             } andFailed:^(NSError *error) {
                 
             }];
            
        }];
}


- (void)getSocketData
{
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0D";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        NSString *body = msg.msgBody;
        NSString *urlString = [NSString stringWithFormat:@"http://%@/tmp/%@",[SettingConfig shareInstance].ip_url,body];
        
            
            [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {
                
                NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
                MMLog(@"%@",dic);
                
                weakSelf.cdrSystemCfg = VALUEFORKEY(dic, @"cdrSystemCfg");
                NSDictionary *videoRecoord = VALUEFORKEY(weakSelf.cdrSystemCfg, @"videoRecord");
                [SettingConfig shareInstance].isPhotoWithVideo = VALUEFORKEY(weakSelf.cdrSystemCfg, @"photoWithVideo") ? YES:NO;
                
                [_subtitlesArray replaceObjectAtIndex:0 withObject:FORMATSTRING(VALUEFORKEY(weakSelf.cdrSystemCfg, @"name"))];
                [_subtitlesArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@%%",FORMATSTRING(VALUEFORKEY(weakSelf.cdrSystemCfg, @"volume")])];
                [_subtitlesArray replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%.1fMHz",[FORMATRUL(VALUEFORKEY(weakSelf.cdrSystemCfg, @"fmFrequency")) integerValue]/10.0]];
                 
                 NSString *volumeRecordingSensitivity = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"volumeRecordingSensitivity"));
                 
                 if ([weakSelf.superVC isKindOfClass:[CameraDetailViewController class]]) {
                     
                     weakSelf.block(volumeRecordingSensitivity);
                 }
                 
                 NSString *video_type;
                 if ([FORMATSTRING(VALUEFORKEY(videoRecoord, @"type")) isEqualToString:@"0"]) {
                     
                     video_type = @"标清（800*480)";
                 }
                 else if ([FORMATSTRING(VALUEFORKEY(videoRecoord, @"type")) isEqualToString:@"1"])
                 {
                     video_type = @"高清（1280*720)";
                 }
                 else
                 {
                     video_type = @"全高清（1920*1080)";
                 }
                 [weakSelf.subtitlesArray replaceObjectAtIndex:7 withObject:@"全高清（1920*1080)"];
                 
                 NSString *video_mode;
                 if([FORMATSTRING(VALUEFORKEY(videoRecoord, @"mode")) isEqualToString:@"0"])
                 {
                     video_mode = @"全屏模式（16:9)";
                 }
                 else
                 {
                     video_mode = @"影院宽屏模式（2.4:1)";
                 }
                 [weakSelf.subtitlesArray replaceObjectAtIndex:8 withObject:video_mode];
                 
                 self.edogSwitch.on = [FORMATSTRING(VALUEFORKEY(weakSelf.cdrSystemCfg, @"eDog")) intValue]?YES:NO;
                 self.relateVideoSwitch.on = [FORMATSTRING(VALUEFORKEY(weakSelf.cdrSystemCfg, @"photoWithVideo")) intValue] ?YES:NO;
                 
                 [self.tableView reloadData];
                 
                 
                 } andFailed:^(NSError *error) {
                     
                 }];
                
                [self getSDData];
                
                NSString *fmFrequency = FORMATSTRING(VALUEFORKEY(weakSelf.cdrSystemCfg, @"fmFrequency"));
                if (fmFrequency.length == 0)
                {
                    fmFrequency = @"0";
                }
//                [_subtitlesArray replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%@%%",fmFrequency]];
            
        }];
        
//
    //192.168.1.105   192.168.100.2
        
//        [RequestManager getRequestWithUrlString:@"http://192.168.100.2/tmp/cdr_sdinfo.xml" params:nil succeed:^(id responseObject) {
//            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
//            cdrSdInformation = VALUEFORKEY(dic, @"cdrSdInformation");
//            [_subtitlesArray replaceObjectAtIndex:10 withObject:[NSString stringWithFormat:@"剩余可用容量%@M",FORMATSTRING(VALUEFORKEY(cdrSdInformation, @"free")])];
//             MMLog(@"%@",dic);
//             [self.tableView reloadData];
//             } andFailed:^(NSError *error) {
//                 
//        }];
}


- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGBACOLOR(227, 227, 227, 1);
        _tableView.contentInset = UIEdgeInsetsMake(6, 0, 84 * PSDSCALE_Y, 0);
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    
    return _tableView;
}

- (UISwitch *)edogSwitch {
    
    if (!_edogSwitch) {
        _edogSwitch = [[UISwitch alloc] init];
        _edogSwitch.frame = CGRectMake(SCREEN_WIDTH - 15 - VIEW_W(_edogSwitch), (50 - VIEW_H(_edogSwitch)) / 2, VIEW_W(_edogSwitch), VIEW_H(_edogSwitch));
        _edogSwitch.onTintColor = RGBSTRING(@"b11c22");
        
        
    }
    
    return _edogSwitch;
}

- (UISwitch *)relateVideoSwitch {
    
    if (!_relateVideoSwitch) {
        _relateVideoSwitch = [[UISwitch alloc] init];
        _relateVideoSwitch.frame = CGRectMake(SCREEN_WIDTH - 15 - VIEW_W(_relateVideoSwitch), (50 - VIEW_H(_relateVideoSwitch)) / 2, VIEW_W(_relateVideoSwitch), VIEW_H(_relateVideoSwitch));
        _relateVideoSwitch.onTintColor = RGBSTRING(@"b11c22");
        
    }
    
    return _relateVideoSwitch;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 7;
    } else if (section == 2) {
        return 3;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kIdentifier];
    }
    else{
        while ([cell.contentView.subviews lastObject] != nil) {
            
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont systemFontOfSize:28 * FONTCALE_Y];
    cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);

    cell.detailTextLabel.font = [UIFont systemFontOfSize:25 * FONTCALE_Y];
    cell.detailTextLabel.textColor = RGBACOLOR(119, 119, 119, 1);
    cell.detailTextLabel.text = nil;
    if (indexPath.section == 0)
    {
        
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.subtitlesArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        
        
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row + 2];
        if (indexPath.row == 4) {
//            // 电子狗开关
//            [cell addSubview:self.edogSwitch];
//            [_edogSwitch addTarget:self action:@selector(edogSwitch_click:) forControlEvents:UIControlEventValueChanged];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        } else if (indexPath.row == 5) {
            // 视频关联开关
            [cell addSubview:self.relateVideoSwitch];
            [_relateVideoSwitch addTarget:self action:@selector(relateVideoSwitch_click:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.detailTextLabel.text = [self.subtitlesArray objectAtIndex:indexPath.row + 2];
        }
    }
    else if (indexPath.section == 2)
    {
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row + 9];
        
        
        if (indexPath.row == 1)
        {
            cell.detailTextLabel.text = [self.subtitlesArray objectAtIndex:indexPath.row + 9];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.000001;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    _isPush = YES;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                // 摄像头名称
                CameraNameViewController *nameVC = [[CameraNameViewController alloc] init];
                [self.navigationController pushViewController:nameVC animated:YES];
            }
                break;
            case 1:
            {
                // 摄像头密码
                CameraPwdViewController *pwdVC = [[CameraPwdViewController alloc] init];
                [self.navigationController pushViewController:pwdVC animated:YES];
            }
                break;
                
            default:
                break;
        }

    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                // 音量调节
                CameraVolumeCtrlViewController *volumeCtrlVC = [[CameraVolumeCtrlViewController alloc] init];
                volumeCtrlVC.volumeString = FORMATSTRING(VALUEFORKEY(self.cdrSystemCfg, @"volume"));
                [self.navigationController pushViewController:volumeCtrlVC animated:YES];
            }
                break;
            case 1:
            {
                // 录像时录音
                CameraRecordingSensitivityViewController *cameraRecordingVC = [[CameraRecordingSensitivityViewController alloc] init];
                cameraRecordingVC.detailString = FORMATSTRING(VALUEFORKEY(self.cdrSystemCfg, @"volumeRecordingSensitivity"));
                [self.navigationController pushViewController:cameraRecordingVC animated:YES];
            }
                break;
            case 2:
            {
                // 蓝牙免提
                CameraBluetoothHFViewController *bluetoothVC = [[CameraBluetoothHFViewController alloc] init];
                bluetoothVC.detailString = FORMATSTRING(VALUEFORKEY(self.cdrSystemCfg, @"bluetooth"));
                [self.navigationController pushViewController:bluetoothVC animated:YES];
            }
                break;
                
            case 3:
            {
                //FM发射设置
                CameraFMSettingViewController *FMSettingVC = [[CameraFMSettingViewController alloc] init];
                FMSettingVC.fmFrequencyString = FORMATSTRING(VALUEFORKEY(self.cdrSystemCfg, @"fmFrequency"));
        
                [self.navigationController pushViewController:FMSettingVC animated:YES];
                
            }
                break;
                
            case 5:
            {
                // 图片质量
                CameraImageQualityViewController *imageQualityVC = [[CameraImageQualityViewController alloc] init];
                NSDictionary *videoRecoord = VALUEFORKEY(self.cdrSystemCfg, @"videoRecord");
                imageQualityVC.detailString = FORMATSTRING(VALUEFORKEY(videoRecoord, @"type"));
                [self.navigationController pushViewController:imageQualityVC animated:YES];
            }
                break;
            case 6:
            {
                // 摄像模式
                CameraModeViewController *cameraModeVC = [[CameraModeViewController alloc] init];
                NSDictionary *videoRecoord = VALUEFORKEY(self.cdrSystemCfg, @"videoRecord");
                cameraModeVC.detailString = FORMATSTRING(VALUEFORKEY(videoRecoord, @"mode"));
                [self.navigationController pushViewController:cameraModeVC animated:YES];
            }
                break;
                
            default:
                break;
        }

    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                // 高级设置
                CameraHighSettingViewController *highSettingVC = [[CameraHighSettingViewController alloc] init];
                highSettingVC.deatil_dic = [self.cdrSystemCfg mutableCopy];
                [self.navigationController pushViewController:highSettingVC animated:YES];
            }
                break;
            case 1:
            {
                // 摄像头存储管理
                CameraStoreManagementViewController *storeManageVC = [[CameraStoreManagementViewController alloc] init];
                storeManageVC.detail_dic = [self.cdrSdInformation mutableCopy];
                [self.navigationController pushViewController:storeManageVC animated:YES];
            }
                break;
            case 2:
            {
                // 摄像机信息
                CameraInfoViewController *cameraInfoVC = [[CameraInfoViewController alloc] init];
                cameraInfoVC.detail_dic = [self.cdrSystemCfg mutableCopy];
                cameraInfoVC.SD_dic = [self.cdrSdInformation mutableCopy];
                [self.navigationController pushViewController:cameraInfoVC animated:YES];
            }
                break;
                
            default:
                break;
        }

    }
}

@end
