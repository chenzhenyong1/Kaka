//
//  CameraCarBrandTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CarBrandModel;
@interface CameraCarBrandTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *car_nameLab;
@property (nonatomic, strong) UIImageView *car_imageView;

- (void)refreshData:(CarBrandModel *)model;

+ (instancetype)cellWithTableView:(UITableView*)tableView;
@end
