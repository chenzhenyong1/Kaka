//
//  EyeHeaderView.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyePlayView.h"
typedef enum {
    
    EyeHeaderViewBtnLeft,   //左边
    EyeHeaderViewBtnRight   //右边

}EyeHeaderViewBtn;

@interface EyeHeaderView : UIView

- (void)refreshUIWithMovieResouceUrl:(NSURL *)movieResouceUrl showImage:(UIImage *)showImage;


/** 点击左边违章图片 */
@property (nonatomic, copy) void (^addPicture)(EyeHeaderViewBtn btn);

@property (nonatomic, weak) EyePlayView *playView;
/** 左边违章按钮 */
@property (nonatomic, weak) UIButton *leftBtn;
/** 右边违章按钮 */
@property (nonatomic, weak) UIButton *rightBtn;

@end
