//
//  ImageTextButton.h
//  ButtonMul
//
//  ImageTextButton is inherited from UIButton, so all the methods of UIButton apply to ImageTextButton
//

//  果动校园
//
//  Created by     songguolin on 15/7/22.
//  Copyright (c) 2015年 GDSchool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIButtonTitleWithImageAlignmentUp = 0,  // title is up
    UIButtonTitleWithImageAlignmentLeft,    // title is left
    UIButtonTitleWithImageAlignmentDown,    // title is down
    UIButtonTitleWithImageAlignmentRight    // title is right
} UIButtonTitleWithImageAlignment;

@interface ImageTextButton : UIButton


//图片 文字间距
@property (nonatomic) CGFloat imgTextDistance;  // distance between image and title, default is 5
@property (nonatomic) UIButtonTitleWithImageAlignment buttonTitleWithImageAlignment;  // need to set a value when used

- (UIButtonTitleWithImageAlignment)buttonTitleWithImageAlignment;
- (void)setButtonTitleWithImageAlignment:(UIButtonTitleWithImageAlignment)buttonTitleWithImageAlignment;




@end
