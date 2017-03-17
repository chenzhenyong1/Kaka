//
//  MeNewsViewControllerTableViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface MeNewsViewControllerTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *detaillab;
@property (nonatomic, strong) UILabel *timelab;
@property (nonatomic, strong) UIView *pointView;

@property (nonatomic, strong) MessageModel *msgModel;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
