//
//  MeSettingViewCotrollerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeSettingViewCotrollerTableViewCell.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
#import "MeSwitchItemModel.h"
@implementation MeSettingViewCotrollerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    MeSettingViewCotrollerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MeSettingViewCotrollerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    else{
        while ([cell.contentView.subviews lastObject] != nil) {
            
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    return cell;
}

- (void)setItem:(MeParentModel *)item
{
    _item = item;
    [self setupData];
}

- (void)setupData
{
    self.titleLab = nil;
    self.accessoryView = nil;
    self.detailLab = nil;
    self.settingSwitch = nil;
    
    if ([_item isKindOfClass:[MeArrowItemModel class]])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else if ([_item isKindOfClass:[MeSwitchItemModel class]])
    {
        self.settingSwitch = [[UISwitch alloc] init];
        self.settingSwitch.onTintColor = RGBSTRING(@"b11c22");
        [self.settingSwitch addTarget:self action:@selector(switch_value_changed:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.settingSwitch;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([_item.title isEqualToString:@"自动下载拍照文件"]) {
            if ([UserDefaults objectForKey:[NSString stringWithFormat:@"%@_autoDownloadPicture", UserName]]) {
                self.settingSwitch.on = [UserDefaults boolForKey:[NSString stringWithFormat:@"%@_autoDownloadPicture", UserName]];
            } else {
                // 默认打开
                self.settingSwitch.on = YES;
            }
            
        } else if ([_item.title isEqualToString:@"仪表盘显示"]) {
            if ([UserDefaults objectForKey:[NSString stringWithFormat:@"%@_displayDashboard", UserName]]) {
                // 默认打开
                self.settingSwitch.on = [UserDefaults boolForKey:[NSString stringWithFormat:@"%@_displayDashboard", UserName]];
            } else {
                // 默认打开
                self.settingSwitch.on = YES;
            }
            
        }
    }
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(33*PSDSCALE_X, 35*PSDSCALE_Y, 263*PSDSCALE_X, 35*PSDSCALE_Y)];
    self.titleLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    self.titleLab.textColor = RGBSTRING(@"333333");
    self.titleLab.text = _item.title;
    [self.contentView addSubview:self.titleLab];
    
    self.detailLab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(self.titleLab), 34*PSDSCALE_Y, 395*PSDSCALE_X, 32*PSDSCALE_Y)];
    self.detailLab.text = _item.detail;
    self.detailLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    self.detailLab.textAlignment = NSTextAlignmentRight;
    self.detailLab.textColor = RGBSTRING(@"777777");
    [self.contentView addSubview:self.detailLab];
}

- (void)switch_value_changed:(UISwitch *)sender {
    
    if ([_item.title isEqualToString:@"自动下载拍照文件"]) {
        [UserDefaults setObject:@(sender.on) forKey:[NSString stringWithFormat:@"%@_autoDownloadPicture", UserName]];
    } else if ([_item.title isEqualToString:@"仪表盘显示"]) {
        [UserDefaults setObject:@(sender.on) forKey:[NSString stringWithFormat:@"%@_displayDashboard", UserName]];
    }
}

@end
