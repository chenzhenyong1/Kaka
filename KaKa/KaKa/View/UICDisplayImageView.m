//
//  UICDisplayImageView.m
//  UICEditSDK
//
//  Created by Cc on 14/12/11.
//  Copyright (c) 2014年 PinguoSDK. All rights reserved.
//

#import "UICDisplayImageView.h"

@interface UICDisplayImageView ()

//原始图
@property (nonatomic,strong) UIImage *mOrigImage;

//原始缩略图
@property (nonatomic,strong) UIImage *mOrigPreviewImage;

//编辑后效果图
@property (nonatomic,strong) UIImage *mPreviewImage;

@property (nonatomic,assign) BOOL     mIsShowOrigImage;

@end

@implementation UICDisplayImageView

- (void)awakeFromNib
{
    self.userInteractionEnabled = YES;
    self.mIsShowOrigImage = NO;
}

- (void)pSetupOrigImage:(UIImage *)image
{
    self.mOrigImage = image;
    {
        CGFloat w = self.frame.size.width;
        CGFloat h = w / (image.size.width / image.size.height);
        self.mOrigPreviewImage = [self resizedImage:CGSizeMake(w, h)
                               interpolationQuality:(kCGInterpolationDefault)
                                          withImage:image];
    }
    [self pSetupPreviewImage:nil];
}

- (void)pSetupPreviewImage:(UIImage *)image
{
    self.mPreviewImage = image;
    [self pUpdateDisplay];
}

- (void)pUpdateDisplay
{
    __weak __typeof (&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.mIsShowOrigImage) {
            
            [weakSelf setImage:weakSelf.mOrigPreviewImage];
        }
        else {
            
            if (weakSelf.mPreviewImage) {
                
                [weakSelf setImage:weakSelf.mPreviewImage];
            }
            else {
                
                [weakSelf setImage:weakSelf.mOrigPreviewImage];
            }
        }
    });
}



- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality withImage:(UIImage*)image
{
    BOOL drawTransposed;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize withImage:image]
               drawTransposed:drawTransposed
         interpolationQuality:quality
                    withImage:image];
}

- (CGAffineTransform)transformForOrientation:(CGSize)newSize withImage:(UIImage*)image
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    int iOrien = image.imageOrientation;
    switch (iOrien)
    {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI);
            break;
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (iOrien)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
                withImage:(UIImage*)image
{
    @autoreleasepool
    {
        CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        CGRect transposedRect;
        if (transpose)
        {
            transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
        }
        else
        {
            transposedRect = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
        }
        CGImageRef imageRef = image.CGImage;
        
        // Build a context that's the same dimensions as the new size
        CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                    newRect.size.width,
                                                    newRect.size.height,
                                                    CGImageGetBitsPerComponent(imageRef),
                                                    0,
                                                    CGImageGetColorSpace(imageRef),
                                                    CGImageGetBitmapInfo(imageRef));
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform);
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality);
        
        CGContextSetAllowsAntialiasing(bitmap, FALSE);
        CGContextSetShouldAntialias(bitmap, NO);
        //CGContextSetFlatness(bitmap, 0);
        
        // Draw into the context; this scales the image
        //CGContextDrawTiledImage(bitmap, transposedRect, imageRef);
        CGContextDrawImage(bitmap, transposedRect, imageRef);
        
        // Get the resized image from the context and a UIImage
        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
        
        // Clean up
        if (bitmap != NULL)
        {
            CFRelease(bitmap);
        }
        
        if (newImageRef != NULL)
        {
            CFRelease(newImageRef);
        }
        
        return newImage;
    }
}
@end
