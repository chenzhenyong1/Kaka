//
//  PRGSettingDataViewController.h
//  AiFuKa
//
//  Created by Change_pan on 16/6/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SettingDataRefreshBlock)(NSString *detailStr);
@interface PRGSettingDataViewController : BaseViewController
@property (nonatomic, strong) NSString *selStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, copy) SettingDataRefreshBlock block;
@end
