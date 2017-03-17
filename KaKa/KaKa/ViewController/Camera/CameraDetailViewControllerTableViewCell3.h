//
//  CameraDetailViewControllerTableViewCell3.h
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraTime_lineModel;
@class CameraDetailViewControllerTableViewCell3;
@protocol Time_lineDelegate <NSObject>

- (void)showBIgImageWithCell:(CameraDetailViewControllerTableViewCell3 *)cell;

@end

@interface CameraDetailViewControllerTableViewCell3 : UITableViewCell

@property (nonatomic, strong) UIImageView *detailImage;
@property (nonatomic, strong) UILabel *time_lab;

@property (nonatomic, weak) id<Time_lineDelegate>delegate;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

- (void)refreshData:(CameraTime_lineModel *)model;
@end
