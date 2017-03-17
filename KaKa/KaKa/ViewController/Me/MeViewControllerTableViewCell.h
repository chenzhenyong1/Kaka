//
//  MeViewControllerTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeParentModel;
@interface MeViewControllerTableViewCell : UITableViewCell

@property (nonatomic, strong) MeParentModel *item;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *titleImage;
@property (nonatomic, strong) UILabel *subLab;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
