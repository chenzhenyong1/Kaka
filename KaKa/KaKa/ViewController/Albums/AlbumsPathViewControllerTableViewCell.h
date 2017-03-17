//
//  AlbumsPathViewControllerTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumsPathModel.h"
@class AlbumsPathViewControllerTableViewCell;
@protocol AlbumsPathViewControllerTableViewCellDelegate <NSObject>

//删除
- (void)deleteDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell;

//收藏
- (void)collectDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell;

//分享
- (void)shareDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell;

@end

@interface AlbumsPathViewControllerTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *addressLab;//地址
@property (nonatomic, strong) UILabel *timeLab;//时间
@property (nonatomic, strong) UILabel *average_speed_lab;//平均速度
@property (nonatomic, strong) UILabel *all_time_lab;//总时间
@property (nonatomic, strong) UILabel *all_mileage_lab;//总里程
@property (nonatomic, strong) UIImageView *mapImage;//图片
@property (nonatomic, strong) AlbumsPathModel *model;

@property (nonatomic, weak) id <AlbumsPathViewControllerTableViewCellDelegate> delegate;


+ (instancetype)cellWithTableView:(UITableView*)tableView;

- (void)refreshData:(AlbumsPathModel *)model;



@end
