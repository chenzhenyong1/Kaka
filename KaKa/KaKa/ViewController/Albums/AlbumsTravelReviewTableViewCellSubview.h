//
//  AlbumsTravelReviewTableViewCellSubview.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumsTravelReviewHourModel.h"
#import "MyTools.h"

@protocol AlbumsTravelReviewTableViewCellSubviewDelegate <NSObject>

@optional
- (void)didClickBtnWithModel:(AlbumsTravelReviewHourModel *)model;

@end
@interface AlbumsTravelReviewTableViewCellSubview : UIView

@property (nonatomic, strong) AlbumsTravelReviewHourModel *model;

@property (nonatomic, copy) NSString *cameraMac;//摄像头mac地址

@property (nonatomic, weak) id <AlbumsTravelReviewTableViewCellSubviewDelegate> delegate;
@end
