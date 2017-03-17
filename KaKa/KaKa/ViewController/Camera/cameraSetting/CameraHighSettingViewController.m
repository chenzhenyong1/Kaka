//
//  CameraHighSettingViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraHighSettingViewController.h"
#import "CameraAccelerationSensorSensitivityViewController.h"
#import "CameraPersonalizedSignatureViewController.h"

@interface CameraHighSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *titlesArray;
// 遥控器配对开启按钮
@property (nonatomic, strong) UIButton *remoteMatchOnBtn;

@property (nonatomic, strong) NSString *detailText;
@end

@implementation CameraHighSettingViewController
{
    NSMutableDictionary *dataSource_Dic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titlesArray = [NSMutableArray arrayWithArray:@[@"遥控器配对", @"时间水印", @"显示速度", @"发动机转速", @"个性文字", @"开机提示音", @"碰撞感应灵敏度"]];
    
    dataSource_Dic = [self.deatil_dic mutableCopy];
    [self addTitle:@"高级设置"];
    
    [self addBackButtonWith:nil];
    
    [self.view addSubview:self.tableView];
}



- (void)socketWithBody:(NSString *)body setting:(NSString *)setting
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0E";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    
    msg.msgBody = [NSString stringWithFormat:@"%@=\"%@\"",setting,body];
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            [self addActityText:@"修改成功" deleyTime:1];
            if ([setting isEqualToString:@"cdrSystemCfg.telecontroller"])
            {
                if ([body intValue])
                {
                    if (![body isEqualToString:@"2"])
                    {
                        [weakSelf socketWithBody:@"2" setting:@"cdrSystemCfg.telecontroller"];
                    }
//                    [weakSelf.remoteMatchOnBtn setTitle:@"关闭" forState:UIControlStateNormal];
                    
                }
//                else
//                {
//                    [weakSelf.remoteMatchOnBtn setTitle:@"开启" forState:UIControlStateNormal];
//                }
//                [dataSource_Dic setValue:body forKey:@"telecontroller"];
//                
//                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.collisionVideoUploadAuto"])
            {
                [dataSource_Dic setValue:body forKey:@"collisionVideoUploadAuto"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:3];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.bootVoice"])
            {
                [dataSource_Dic setValue:body forKey:@"bootVoice"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:4 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            if ([setting isEqualToString:@"cdrSystemCfg.photoVideoUploadAuto"]) {
                
                [dataSource_Dic setValue:body forKey:@"photoVideoUploadAuto"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:3];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.graphicCorrect"])//遥控器配对
            {
                [dataSource_Dic setValue:body forKey:@"graphicCorrect"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.osd.time"])//时间水印
            {
                NSMutableDictionary *osd_dic = [VALUEFORKEY(dataSource_Dic, @"osd") mutableCopy];
                [osd_dic setValue:body forKey:@"time"];
                [dataSource_Dic setObject:osd_dic forKey:@"osd"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.osd.speed"])//显示速度
            {
                NSMutableDictionary *osd_dic = [VALUEFORKEY(dataSource_Dic, @"osd") mutableCopy];
                [osd_dic setValue:body forKey:@"speed"];
                [dataSource_Dic setObject:osd_dic forKey:@"osd"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.osd.engineSpeed"])//发动机转速
            {
                NSMutableDictionary *osd_dic = [VALUEFORKEY(dataSource_Dic, @"osd") mutableCopy];
                [osd_dic setValue:body forKey:@"engineSpeed"];
                [dataSource_Dic setObject:osd_dic forKey:@"osd"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if ([setting isEqualToString:@"cdrSystemCfg.osd.position"])
            {
                NSMutableDictionary *osd_dic = [VALUEFORKEY(dataSource_Dic, @"osd") mutableCopy];
                [osd_dic setValue:body forKey:@"position"];
                [dataSource_Dic setObject:osd_dic forKey:@"osd"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:2];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
        else
        {
            [self addActityText:@"网络连接异常" deleyTime:1];
        }
        
    }];
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGBACOLOR(227, 227, 227, 1);
        _tableView.contentInset = UIEdgeInsetsMake(11, 0, 84 * PSDSCALE_Y, 0);
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (UIButton *)remoteMatchOnBtn {
    if (!_remoteMatchOnBtn) {
        _remoteMatchOnBtn = [self buttonWithFrame:CGRectMake(0, 0, 72, 33) inView:nil title:@"配对"titleColorNormal:RGBSTRING(@"333333") titleColorSelected:nil titleFontSize:28 * FONTCALE_Y backgroundNormal:nil backgroundSelected:nil cornerRadius:4 borderWidth:1 borderColor:RGBACOLOR(119, 119, 119, 1) block:^(UIButton *sender) {
            
            [self socketWithBody:@"2" setting:@"cdrSystemCfg.telecontroller"];
            
        }];
    }
    
    return _remoteMatchOnBtn;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 5;
    } else if (section == 2) {
        return 1;
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
    
    cell.accessoryView = nil;
    if (indexPath.section !=0)
    {
        UISwitch *loc_switch = [[UISwitch alloc] init];
        loc_switch.onTintColor = RGBSTRING(@"b11c22");
        [loc_switch addTarget:self action:@selector(loc_switch_click:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = loc_switch;
    }
    
    if (indexPath.section == 0) {
        
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row];
        
        cell.accessoryView = self.remoteMatchOnBtn;

    } else if (indexPath.section == 1) {
        
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row + 1];
        
        NSDictionary *osd_dic = VALUEFORKEY(dataSource_Dic, @"osd");
        
        if (indexPath.row == 0) {
            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
            temp_switch.tag = 2;
            temp_switch.on = [FORMATSTRING(VALUEFORKEY(osd_dic, @"time")) intValue]?YES:NO;
        }
        if (indexPath.row == 1) {
            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
            temp_switch.tag = 3;
            temp_switch.on = [FORMATSTRING(VALUEFORKEY(osd_dic, @"speed")) intValue]?YES:NO;
        }
        if (indexPath.row == 2) {
            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
            temp_switch.tag = 4;
            temp_switch.on = [FORMATSTRING(VALUEFORKEY(osd_dic, @"engineSpeed")) intValue]?YES:NO;
        }
//        if (indexPath.row == 3) {
//            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
//            temp_switch.tag = 5;
//            temp_switch.on = [FORMATSTRING(VALUEFORKEY(osd_dic, @"position")) intValue]?YES:NO;
//        }
        if (indexPath.row == 3) {
            
            if (self.detailText.length)
            {
                cell.detailTextLabel.text = self.detailText;
            }
            else
            {
                cell.detailTextLabel.text = FORMATSTRING(VALUEFORKEY(osd_dic, @"personalizedSignature"));
            }
            
            cell.accessoryView = nil;
        }
        if (indexPath.row == 4) {
            
            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
            temp_switch.tag = 6;
            temp_switch.on = [FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"bootVoice")) intValue]?YES:NO;
        }
    } else if (indexPath.section == 2) {
        
        cell.textLabel.text = [self.titlesArray objectAtIndex:indexPath.row + 6];
        
        if (indexPath.row == 0) {
            if ([FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"accelerationSensorSensitivity")) isEqualToString:@"0"])
            {
                cell.detailTextLabel.text = @"关闭";
            }
            else if ([FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"accelerationSensorSensitivity")) isEqualToString:@"1"])
            {
                cell.detailTextLabel.text = @"低";
            }
            else if ([FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"accelerationSensorSensitivity")) isEqualToString:@"2"])
            {
                cell.detailTextLabel.text = @"中";
                
            }else
            {
                cell.detailTextLabel.text = @"高";
            }
            
            cell.accessoryView = nil;
        }
//        if (indexPath.row == 1) {
//            
//            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
//            temp_switch.tag = 7;
//            temp_switch.on = [FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"collisionVideoUploadAuto")) intValue]?YES:NO;
//        }
//        if (indexPath.row == 2) {
//            
//            UISwitch *temp_switch = (UISwitch *)cell.accessoryView;
//            temp_switch.tag = 8;
//            temp_switch.on = [FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"photoVideoUploadAuto")) intValue]?YES:NO;
//        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) {
        return 0.000001;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return 46;
    }
    
    return 0.000001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
        UILabel *label = [self labelWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 31) textColor:RGBSTRING(@"999999") textFont:22 * FONTCALE_Y text:@"启动配对后，将遥控器靠近摄像机并连续按下3-5次。"];
        [bgView addSubview:label];
        
        return bgView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1)
    {
        if (indexPath.row == 3)
        {
            CameraPersonalizedSignatureViewController *cameraVC = [[CameraPersonalizedSignatureViewController alloc] init];
            __weak typeof(self) weakSelf = self;
            cameraVC.block = ^(NSString *text){
                weakSelf.detailText = text;
                
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:1];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:cameraVC animated:YES];
        }
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            CameraAccelerationSensorSensitivityViewController *camerVC = [[CameraAccelerationSensorSensitivityViewController alloc] init];
            camerVC.detailString = FORMATSTRING(VALUEFORKEY(dataSource_Dic, @"accelerationSensorSensitivity"));
            
            camerVC.block = ^(NSString *str)
            {
                [dataSource_Dic setValue:str forKey:@"accelerationSensorSensitivity"];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                if ([str isEqualToString:@"0"])
//                {
//                    cell.detailTextLabel.text = @"关闭";
//                }
//                else if ([str isEqualToString:@"1"])
//                {
//                    cell.detailTextLabel.text = @"低";
//                }
//                else if ([str isEqualToString:@"2"])
//                {
//                    cell.detailTextLabel.text = @"中";
//                    
//                }else
//                {
//                    cell.detailTextLabel.text = @"高";
//                }
                
                
            };
            [self.navigationController pushViewController:camerVC animated:YES];
        }
    }
}

- (void)loc_switch_click:(UISwitch *)sender
{
    switch (sender.tag) {
        case 1:
        {
            //图像矫正
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.graphicCorrect"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.graphicCorrect"];
            }
        }
            break;
        case 2:
        {
            //时间水印
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.osd.time"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.osd.time"];
            }
        }
            break;
        case 3:
        {
            //显示速度
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.osd.speed"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.osd.speed"];
            }
        }
            break;
        case 4:
        {
            //发送机转速
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.osd.engineSpeed"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.osd.engineSpeed"];
            }
        }
            break;
        case 5:
        {
            //经纬度
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.osd.position"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.osd.position"];
            }
        }
            break;
        case 6:
        {
            //开机提示音
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.bootVoice"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.bootVoice"];
            }
        }
            break;
        case 7:
        {
            //自动上传碰撞视频
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.collisionVideoUploadAuto"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.collisionVideoUploadAuto"];
            }
            
        }
            break;
        case 8:
        {
            
            
            if (sender.on)
            {
                [self socketWithBody:@"1" setting:@"cdrSystemCfg.photoVideoUploadAuto"];
            }
            else
            {
                [self socketWithBody:@"0" setting:@"cdrSystemCfg.photoVideoUploadAuto"];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
