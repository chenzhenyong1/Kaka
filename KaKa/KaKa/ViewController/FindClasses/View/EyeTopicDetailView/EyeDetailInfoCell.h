//
//  EyeDetailInfoCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  详细信息的个人信息cell（头像，名字等）

#import <UIKit/UIKit.h>

@class Subject;
@class EyeAddressModel;
@class TrafficViolation;
@interface EyeDetailInfoCell : UITableViewCell

/** 地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;

/** 心情描述 */
@property (nonatomic, copy) NSString *mood;

- (void)refreshUI:(Subject *)subject;

- (void)refreshCheckUI:(EyeAddressModel *)model;
/** 有违章举报时刷新 */
- (void)refreshBreakRulesUI:(TrafficViolation *)trafficViolation;

@end
