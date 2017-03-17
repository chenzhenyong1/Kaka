//
//  MeLocalCollectTableViewCell.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/9/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectModel.h"

typedef void(^cancelCollectBlock)(BOOL isCancelSuccess);
@interface MeLocalCollectTableViewCell : UITableViewCell

@property (nonatomic, strong) CollectModel *model;
@property (nonatomic, copy) cancelCollectBlock cancelCollectBlock;
@end
