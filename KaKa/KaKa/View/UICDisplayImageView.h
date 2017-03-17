//
//  UICDisplayImageView.h
//  UICEditSDK
//
//  Created by Cc on 14/12/11.
//  Copyright (c) 2014年 PinguoSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICDisplayImageView : UIImageView

@property (nonatomic,strong,readonly) UIImage *mOrigImage;
@property (nonatomic,strong,readonly) UIImage *mPreviewImage;

- (void)pSetupOrigImage:(UIImage*)image;

- (void)pSetupPreviewImage:(UIImage *)image;
@end
