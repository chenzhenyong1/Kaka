//
//  MeSettingViewCotrollerTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeParentModel;
@interface MeSettingViewCotrollerTableViewCell : UITableViewCell
@property (nonatomic, strong) MeParentModel *item;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) UISwitch *settingSwitch;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
