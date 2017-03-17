//
//  CameraDetailCycleVideoCollectionViewCell.h
//  KaKa
//
//  Created by 陈振勇 on 2017/1/12.
//  Copyright © 2017年 深圳市秀软科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^progress)(CGFloat rate);
typedef void(^completion)();
@interface CameraDetailCycleVideoCollectionViewCell : UICollectionViewCell



/**
 循环视频
 
 @param dic <#dic description#>
 
 */
- (void)refreshCycleVideoDataWith:(NSDictionary *)dic macAddress:(NSString *)macAddress;


/**
 下载视频

 @param fileName <#fileName description#>
 */
- (void)downloadCycleVideoWithFileName:(NSString *)fileName macAddress:(NSString *)macAddress progress:(progress)progressRate completion:(completion)completion;


@end
