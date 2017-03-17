//
//  CameraDetailViewControllerTableViewCell2.h
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraTime_lineModel;
@interface CameraDetailViewControllerTableViewCell2 : UITableViewCell
@property (nonatomic, strong) UILabel *time_lab;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

//- (void)refreshData:(CameraTime_lineModel *)model;

- (void)refreshData:(CameraTime_lineModel *)model dataSource:(NSMutableArray *)dataSource indexPath:(NSIndexPath *)indexPath;
@end
