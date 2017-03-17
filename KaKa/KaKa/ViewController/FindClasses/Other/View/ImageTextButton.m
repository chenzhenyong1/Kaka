//
//  ImageTextButton.m
//  ButtonMul
//
//  Created by Jonren on 15/12/29.
//  Copyright © 2015年 Jonren. All rights reserved.
//

#import "ImageTextButton.h"
#import <Masonry.h>
@implementation ImageTextButton


-(instancetype)init
{
    self=[super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    
    
    //default Alignment is in order to facilitate the layout
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.imgTextDistance = 10;
}
- (void)setButtonTitleWithImageAlignment:(UIButtonTitleWithImageAlignment)buttonTitleWithImageAlignment {
    _buttonTitleWithImageAlignment = buttonTitleWithImageAlignment;
    [self alignmentValueChanged];
}

- (void)alignmentValueChanged {
    

    CGFloat imgWidth = self.imageView.image.size.width;
    CGFloat imgHeight = self.imageView.image.size.height;
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    CGFloat textWitdh = textSize.width;
    CGFloat textHeight = textSize.height;
    
    CGFloat interval;      // distance between the whole image title part and button

    CGFloat titleOffsetX;  // horizontal offset of title
    CGFloat titleOffsetY;  // vertical offset of title
    
    
    //居上
    if (_buttonTitleWithImageAlignment == UIButtonTitleWithImageAlignmentUp) {
        
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset((textHeight+self.imgTextDistance)/2);
            make.centerX.equalTo(self.mas_centerX).offset(0);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        interval = -imgHeight-_imgTextDistance;
        titleOffsetX =  -imgWidth;
        titleOffsetY = interval;
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(titleOffsetY, titleOffsetX, 0, 0)];
    }
    //居左
    else if (_buttonTitleWithImageAlignment == UIButtonTitleWithImageAlignmentLeft) {
        
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset(0);
            make.centerX.equalTo(self.mas_centerX).offset((textWitdh+self.imgTextDistance)/2 );
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        interval = self.imageView.frame.origin.x-_imgTextDistance-textWitdh-imgWidth*2;
       
        titleOffsetX = interval;
        titleOffsetY = 0;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(titleOffsetY, titleOffsetX, 0, 0)];
    }
    //居下
    else if (_buttonTitleWithImageAlignment == UIButtonTitleWithImageAlignmentDown) {
       
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset(-(textHeight+self.imgTextDistance)/2);
            make.centerX.equalTo(self.mas_centerX).offset(0);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        interval = imgHeight+_imgTextDistance;
        titleOffsetX = -imgWidth;
        titleOffsetY = interval;
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(titleOffsetY, titleOffsetX, 0, 0)];
    }
    //居右
    else if (_buttonTitleWithImageAlignment == UIButtonTitleWithImageAlignmentRight) {

        
        return;
        
    }

   
   
}


@end
