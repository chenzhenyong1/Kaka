//
//  CameraDetailViewControllerTableViewCell4.h
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraTime_lineModel;
@interface CameraDetailViewControllerTableViewCell4 : UITableViewCell
@property (nonatomic, strong) UILabel *time_lab;
@property (nonatomic, strong) UILabel *average_velocity;
@property (nonatomic, strong) UILabel *mileage_lab;
@property (nonatomic, strong) UIImageView *tishiImage;
@property (nonatomic, strong) UIView *line1;
+ (instancetype)cellWithTableView:(UITableView*)tableView;

- (void)refreshData:(CameraTime_lineModel *)model dataSource:(NSMutableArray *)dataSource indexPath:(NSIndexPath *)indexPath;
@end
