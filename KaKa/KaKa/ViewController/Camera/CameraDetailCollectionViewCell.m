//
//  CameraDetailCollectionViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/8/13.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation CameraDetailCollectionViewCell
{
    UIView *_cover;//蒙版
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _itemImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _itemImage.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _itemImage.contentMode = UIViewContentModeScaleAspectFill;
        _itemImage.clipsToBounds = YES;
        _itemImage.image = GETYCIMAGE(@"albums_video_bg2");
        [self.contentView addSubview:_itemImage];
        
        
        _cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
        _cover.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [_itemImage addSubview:_cover];
        
        _play_image = [[UIImageView alloc] initWithFrame:CGRectMake((VIEW_W(_itemImage)-80*PSDSCALE_X)/2, (VIEW_H(_itemImage)-80*PSDSCALE_Y)/2, 80*PSDSCALE_X, 80*PSDSCALE_Y)];
        _play_image.contentMode = UIViewContentModeScaleAspectFill;
        _play_image.image = GETYCIMAGE(@"camera_play");
        [_itemImage addSubview:_play_image];
    }
    
    return self;
}

- (void)refreshDataWith:(NSDictionary *)dic macAddress:(NSString *)macAddress BSSID:(NSString *)BSSID
{
    _itemImage.image = nil;
    NSString *fileName = VALUEFORKEY(dic, @"fileName");
    
    NSString *file_Path;
    
    if ([dic isKindOfClass:[NSDictionary class]])
    {
        if ([[dic allKeys] containsObject:@"local"])
        {
            file_Path = fileName;
        }
        else
        {
            if ([fileName containsString:@"_pre"]||![fileName containsString:@"_"])//图片路径
            {
                if ([fileName containsString:@"_pre"])
                {
                    fileName = [fileName componentsSeparatedByString:@"_"][0];
                    fileName = [NSString stringWithFormat:@"%@.jpg",fileName];
                }
                
                file_Path = [Photo_Path(macAddress) stringByAppendingPathComponent:fileName];
            }
            else//为视频路径
            {
                
                file_Path = [Video_Photo_Path(macAddress) stringByAppendingPathComponent:fileName];
            }
        }
        
        
        //不存在就下载
        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
        {
            _cover.hidden = NO;
            _play_image.image = GETYCIMAGE(@"Camera_no_download");
            _play_image.hidden = NO;
        }
        else
        {
            _cover.hidden = YES;
            _play_image.image = GETYCIMAGE(@"camera_play");
            NSString *temp_fileName;
            if ([fileName containsString:@"/"])
            {
                temp_fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
            }
            else
            {
                temp_fileName = fileName;
            }
            
            if (![temp_fileName containsString:@"_pre"])
            {
                if ([temp_fileName containsString:@"_"])
                {
                    _play_image.hidden = NO;
                }
                else
                {
                    _play_image.hidden = YES;
                }
            }
            else
            {
                _play_image.hidden = YES;
            }
        }
        
        if ([[dic allKeys] containsObject:@"local"])
        {
            if ([BSSID isEqualToString:macAddress])
            {
                if ([fileName containsString:@"/"])
                {
                    fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                    if (![fileName containsString:@"_"])
                    {
                        fileName = [fileName componentsSeparatedByString:@"."][0];
                        fileName = [fileName stringByAppendingString:@"_pre.jpg"];
//                        [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
                        
                        
                            __block UIActivityIndicatorView *activityIndicator;
                            [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                if (!activityIndicator) {
                                    [_itemImage addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
                                    activityIndicator.center = _itemImage.center;
                                    [activityIndicator startAnimating];
                                }
                            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                [activityIndicator removeFromSuperview];
                                activityIndicator = nil;
                            }];
                        
                        
                        
                        
                    }
                    else
                    {
//                        [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
                        
                        __block UIActivityIndicatorView *activityIndicator;
                        [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            if (!activityIndicator) {
                                [_itemImage addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
                                activityIndicator.center = _itemImage.center;
                                [activityIndicator startAnimating];
                            }
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            [activityIndicator removeFromSuperview];
                            activityIndicator = nil;
                        }];
                    }
                    
                }
            }
            else
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:fileName];
                self.itemImage.image = image;
            }
        }
        else
        {
            if (![fileName containsString:@"_"])
            {
                fileName = [fileName componentsSeparatedByString:@"."][0];
                fileName = [fileName stringByAppendingString:@"_pre.jpg"];
//                [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
                
                __block UIActivityIndicatorView *activityIndicator;
                [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    if (!activityIndicator) {
                        [_itemImage addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
                        activityIndicator.center = _itemImage.center;
                        [activityIndicator startAnimating];
                    }
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [activityIndicator removeFromSuperview];
                    activityIndicator = nil;
                }];
                
            }
            else
            {
//                [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage")];
                
                __block UIActivityIndicatorView *activityIndicator;
                [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    if (!activityIndicator) {
                        [_itemImage addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
                        activityIndicator.center = _itemImage.center;
                        [activityIndicator startAnimating];
                    }
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [activityIndicator removeFromSuperview];
                    activityIndicator = nil;
                }];
            }
        }
    }
    
}

- (void)refreshCycleVideoDataWith:(NSDictionary *)dic
{
    
    _play_image.hidden = YES;
    
    NSString *fileName = VALUEFORKEY(dic, @"fileName");
    fileName = [[fileName componentsSeparatedByString:@"_"] objectAtIndex:0];
    fileName = [fileName stringByAppendingString:@".jpg"];
    __block UIActivityIndicatorView *activityIndicator;
    [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/INDEX/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (!activityIndicator) {
            [_itemImage addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)]];
            activityIndicator.center = _itemImage.center;
            [activityIndicator startAnimating];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [activityIndicator removeFromSuperview];
        activityIndicator = nil;
    }];
    ZYLog(@"fileName = %@",fileName);
}

@end
