//
//  MeTrjectoryViewControllerTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumsPathModel.h"
@interface MeTrajectoryViewControllerTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *addressLab;//地址
@property (nonatomic, strong) UILabel *timeLab;//时间
@property (nonatomic, strong) UILabel *average_speed_lab;//平均速度
@property (nonatomic, strong) UILabel *all_time_lab;//总时间
@property (nonatomic, strong) UILabel *all_mileage_lab;//总里程
@property (nonatomic, strong) UIImageView *mapImage;//图片

+ (instancetype)cellWithTableView:(UITableView*)tableView;


- (void)refreshData:(AlbumsPathModel *)model;

@end
