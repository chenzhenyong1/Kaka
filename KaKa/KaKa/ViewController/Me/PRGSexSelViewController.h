//
//  PRGSexSelViewController.h
//  AiFuKa
//
//  Created by Change_pan on 16/6/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SexRefresh)(NSString *detailStr);

@interface PRGSexSelViewController : BaseViewController
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, copy) SexRefresh block;
@end
