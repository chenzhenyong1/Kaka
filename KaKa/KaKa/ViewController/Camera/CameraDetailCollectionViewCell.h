//
//  CameraDetailCollectionViewCell.h
//  KaKa
//
//  Created by Change_pan on 16/8/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraDetailCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *itemImage;
@property (nonatomic, strong) UIImageView *play_image;



- (void)refreshDataWith:(NSDictionary *)dic macAddress:(NSString *)macAddress BSSID:(NSString *)BSSID;

/**
 循环视频

 @param dic <#dic description#>

 */
- (void)refreshCycleVideoDataWith:(NSDictionary *)dic;

@end
