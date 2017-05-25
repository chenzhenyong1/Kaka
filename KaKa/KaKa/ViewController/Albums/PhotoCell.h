//
//  PhotoCell.h
//  KaKa
//
//  Created by 陈振勇 on 2017/4/24.
//  Copyright © 2017年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumsTravelDetailModel;
@interface PhotoCell : UICollectionViewCell

///**  */
//@property (nonatomic, strong) AlbumsTravelDetailModel *model;

- (void)refreshWithAlbumsTravelDetailModel:(AlbumsTravelDetailModel *)model cameraMac:(NSString *)cameraMac;

@end
