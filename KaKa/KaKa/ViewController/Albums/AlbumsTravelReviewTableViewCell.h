//
//  AlbumsTravelReviewTableViewCell.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/30.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumsTravelReviewTableViewCellSubview.h"

@protocol AlbumsTravelReviewTableViewCellDelegate <NSObject>

-(void)btn_clickWithModel:(AlbumsTravelReviewHourModel *)model;

@end

@interface AlbumsTravelReviewTableViewCell : UITableViewCell <AlbumsTravelReviewTableViewCellSubviewDelegate>

@property (nonatomic, weak) id<AlbumsTravelReviewTableViewCellDelegate> delegate;

@property (nonatomic, copy) NSString *cameraMac;//摄像头mac地址

@property (nonatomic, strong) NSArray *dataSource;

@end
