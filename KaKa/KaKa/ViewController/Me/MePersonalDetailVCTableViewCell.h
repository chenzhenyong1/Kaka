//
//  MePersonalDetailVCTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MeParentModel;
@interface MePersonalDetailVCTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UILabel *detailLab;
@property (nonatomic, strong) MeParentModel *item;
+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
