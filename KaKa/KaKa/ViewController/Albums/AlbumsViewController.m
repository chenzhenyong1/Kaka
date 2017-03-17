//
//  AlbumsViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsViewController.h"
#import "AlbumsVideoViewController.h"
#import "AlbumsPhotoViewController.h"
#import "AlbumsPathViewController.h"
#import "AlbumsTravelViewController.h"
#import "MyTools.h"
@implementation AlbumsViewController
{
   
    UIImageView *pathImage1;
    UIImageView *pathImage2;
    UIImageView *photoImage1;
    UIImageView *photoImage2;
    UIImageView *travelsImage1;
    UIImageView *travelsImage2;
    UIImageView *videoImage1;
    UIImageView *videoImage2;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}


- (void)getData
{
//    CameraListModel *model = [SettingConfig shareInstance].currentCameraModel;
    NSMutableArray *pathArr;
    //轨迹
    pathArr =[MyTools getAllDataWithPath:Path_Photo(nil) mac_adr:nil];
    pathArr = [self newArray:pathArr];
    if (pathArr.count) {
        if (pathArr.count >= 2)
        {
            pathImage2.hidden = NO;
            UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:pathArr[1]];
            pathImage1.image = image1;
            UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            pathImage2.image = image2;
        }
        else
        {
            pathImage2.hidden = YES;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            pathImage1.image = image;
        }
        
    }
    else
    {
        pathImage2.hidden = YES;
        pathImage1.image = GETYCIMAGE(@"albums_index_default");
    }
    
    //视频图片
    pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
    pathArr = [self newArray:pathArr];
    if (pathArr.count) {
        if (pathArr.count >= 2)
        {
            videoImage2.hidden = NO;
            UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:pathArr[1]];
            videoImage1.image = image1;
            UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            videoImage2.image = image2;
        }
        else
        {
            videoImage2.hidden = YES;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            videoImage1.image = image;
        }
    }
    else
    {
        videoImage2.hidden = YES;
        videoImage1.image = GETYCIMAGE(@"albums_index_default");
    }
    
    //照片
    pathArr = [MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
    pathArr = [self newArray:pathArr];
    if (pathArr.count) {
        if (pathArr.count >= 2)
        {
            photoImage2.hidden = NO;
            UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:pathArr[1]];
            photoImage1.image = image1;
            UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            photoImage2.image = image2;
        }
        else
        {
            photoImage2.hidden = YES;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            photoImage1.image = image;
        }
    }
    else
    {
        photoImage2.hidden = YES;
        photoImage1.image = GETYCIMAGE(@"albums_index_default");
    }
    
    //游记
    pathArr = [[self getTravelDatas] mutableCopy];
    if (pathArr.count) {
        if (pathArr.count >= 2)
        {
            travelsImage2.hidden = NO;
            UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:pathArr[pathArr.count-2]];
            travelsImage1.image = image1;
            UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:pathArr[pathArr.count-1]];
            travelsImage2.image = image2;
        }
        else
        {
            travelsImage2.hidden = YES;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathArr[0]];
            travelsImage1.image = image;
        }
    }
    else
    {
        travelsImage2.hidden = YES;
        travelsImage1.image = GETYCIMAGE(@"albums_index_default");
    }
}


//遍历数组，将数据按时间重新排序
- (NSMutableArray *)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj2] longLongValue]] compare:[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj1] longLongValue]]];
        return result;
    }];
    [arr removeAllObjects];
    [arr addObjectsFromArray:sortedArray];
    
    return arr;
    
}

//获取时间
- (NSString *)getTimeWithFilePath:(NSString *)filePath
{
    NSString *file_path = [filePath componentsSeparatedByString:@"/"].lastObject;
    file_path = [file_path componentsSeparatedByString:@"."].firstObject;
    if ([file_path hasPrefix:@"G"])
    {
        file_path = [file_path substringFromIndex:1];
    }
    
    if ([file_path hasPrefix:@"gps_"])
    {
        file_path = [file_path componentsSeparatedByString:@"_"][1];
    }
    
    if ([file_path containsString:@"_"])
    {
        file_path = [file_path componentsSeparatedByString:@"_"].firstObject;
    }
    return file_path;
    
}

- (NSArray *)getTravelDatas {
    
    NSMutableArray *travelImages = [MyTools getAllDataWithPath:Travel_Path(nil) mac_adr:nil];
    
    for (NSInteger i = 0; i < travelImages.count; i++) {
        if (i < travelImages.count) {
            NSString *pathStr = travelImages[i];
            if (![pathStr hasSuffix:@".jpg"]) {
                [travelImages removeObject:pathStr];
                i = 0;
            }
        }
    }
    
    NSArray *sortTravelImages = [travelImages sortedArrayUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
        path1 = [[path1 componentsSeparatedByString:@"/"] lastObject];
        path1 = [[path1 componentsSeparatedByString:@"."] firstObject];
        path1 = [[path1 componentsSeparatedByString:@"_"] firstObject];
        
        path2 = [[path2 componentsSeparatedByString:@"/"] lastObject];
        path2 = [[path2 componentsSeparatedByString:@"."] firstObject];
        path2 = [[path2 componentsSeparatedByString:@"_"] firstObject];
        
        NSNumber *number1 = [NSNumber numberWithLongLong:[path1 longLongValue]];
        NSNumber *number2 = [NSNumber numberWithLongLong:[path2 longLongValue]];
        NSComparisonResult result = [number1 compare:number2];
        
        return (result == NSOrderedDescending); // 升序
    }];
    
    return sortTravelImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTitle:@"相册"];
    self.view.backgroundColor = RGBSTRING(@"fafafa");
    
    [self initUI];
    
}

- (void)initUI
{
    UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(70*PSDSCALE_X, 52*PSDSCALE_Y, 250*PSDSCALE_X, 294*PSDSCALE_Y)];
    videoView.userInteractionEnabled = YES;
    videoView.tag = 1;
    [self.view addSubview:videoView];
    
    videoImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, 10*PSDSCALE_Y, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    videoImage1.image = GETYCIMAGE(@"albums_video_bg2");
    videoImage1.contentMode = UIViewContentModeScaleAspectFill;
    videoImage1.clipsToBounds = YES;
    [videoView addSubview:videoImage1];
    
    videoImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    videoImage2.image = GETYCIMAGE(@"albums_video_bg1");
    videoImage2.layer.shadowColor=[UIColor grayColor].CGColor;
    videoImage2.layer.shadowOffset=CGSizeMake(10*PSDSCALE_X, 10*PSDSCALE_Y);
    videoImage2.layer.shadowOpacity=0.8;
    videoImage2.layer.shadowRadius=5*PSDSCALE_X;
    videoImage2.contentMode = UIViewContentModeScaleAspectFill;
    videoImage2.clipsToBounds = YES;
    [videoView addSubview:videoImage2];
    
    UILabel *videoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(videoImage1)+17*PSDSCALE_Y, 250*PSDSCALE_X, 37*PSDSCALE_Y)];
    videoLab.text = @"视频";
    videoLab.textAlignment = NSTextAlignmentCenter;
    videoLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    [videoView addSubview:videoLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_click:)];
    [videoView addGestureRecognizer:tap];
    
    
    
    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W_X(videoView)+110*PSDSCALE_X, 52*PSDSCALE_Y, 250*PSDSCALE_X, 294*PSDSCALE_Y)];
    photoView.userInteractionEnabled = YES;
    
    photoView.tag = 2;
    [self.view addSubview:photoView];
    
    photoImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, 10*PSDSCALE_Y, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    photoImage1.image = GETYCIMAGE(@"albums_video_bg1");
    photoImage1.contentMode = UIViewContentModeScaleAspectFill;
    photoImage1.clipsToBounds = YES;
    [photoView addSubview:photoImage1];
    
    photoImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
    
//    photoImage2.image = GETYCIMAGE(@"albums_video_bg2");
    photoImage2.layer.shadowColor=[UIColor grayColor].CGColor;
    photoImage2.layer.shadowOffset=CGSizeMake(10*PSDSCALE_X, 10*PSDSCALE_Y);
    photoImage2.layer.shadowOpacity=0.8;
    photoImage2.layer.shadowRadius=5*PSDSCALE_X;
    photoImage2.contentMode = UIViewContentModeScaleAspectFill;
    photoImage2.clipsToBounds = YES;
    [photoView addSubview:photoImage2];
    
    UILabel *photoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(photoImage1)+17*PSDSCALE_Y, 250*PSDSCALE_X, 37*PSDSCALE_Y)];
    photoLab.text = @"照片";
    photoLab.textAlignment = NSTextAlignmentCenter;
    photoLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    [photoView addSubview:photoLab];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_click:)];
    [photoView addGestureRecognizer:tap1];
    
    
    UIView *pathView = [[UIView alloc] initWithFrame:CGRectMake(70*PSDSCALE_X, VIEW_H_Y(videoView)+56*PSDSCALE_Y, 250*PSDSCALE_X, 294*PSDSCALE_Y)];
    pathView.userInteractionEnabled = YES;
    pathView.tag = 3;
    [self.view addSubview:pathView];
    
    pathImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, 10*PSDSCALE_Y, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    pathImage1.contentMode = UIViewContentModeScaleAspectFit;
//    pathImage1.image = GETYCIMAGE(@"albums_video_bg2");
    pathImage1.contentMode = UIViewContentModeScaleAspectFill;
    pathImage1.clipsToBounds = YES;
    [pathView addSubview:pathImage1];
    
    pathImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    pathImage2.contentMode = UIViewContentModeScaleAspectFit;
//    pathImage2.image = GETYCIMAGE(@"albums_video_bg1");
    pathImage2.layer.shadowColor=[UIColor grayColor].CGColor;
    pathImage2.layer.shadowOffset=CGSizeMake(10*PSDSCALE_X, 10*PSDSCALE_Y);
    pathImage2.layer.shadowOpacity=0.8;
    pathImage2.layer.shadowRadius=5*PSDSCALE_X;
    pathImage2.contentMode = UIViewContentModeScaleAspectFill;
    pathImage2.clipsToBounds = YES;
    [pathView addSubview:pathImage2];
    
    UILabel *pathLab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(pathImage1)+17*PSDSCALE_Y, 250*PSDSCALE_X, 37*PSDSCALE_Y)];
    pathLab.text = @"轨迹";
    pathLab.textAlignment = NSTextAlignmentCenter;
    pathLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    [pathView addSubview:pathLab];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_click:)];
    [pathView addGestureRecognizer:tap2];
    
    
    UIView *travelsView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W_X(pathView)+110*PSDSCALE_X, VIEW_H_Y(videoView)+56*PSDSCALE_Y, 250*PSDSCALE_X, 294*PSDSCALE_Y)];
    travelsView.userInteractionEnabled = YES;
    travelsView.tag = 4;
    [self.view addSubview:travelsView];
    
    travelsImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(10*PSDSCALE_X, 10*PSDSCALE_Y, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    travelsImage1.image = GETYCIMAGE(@"albums_video_bg2");
    travelsImage1.contentMode = UIViewContentModeScaleAspectFill;
    travelsImage1.clipsToBounds = YES;
    [travelsView addSubview:travelsImage1];
    
    travelsImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240*PSDSCALE_X, 240*PSDSCALE_Y)];
//    travelsImage2.image = GETYCIMAGE(@"albums_video_bg1");
    
    travelsImage2.layer.shadowColor=[UIColor grayColor].CGColor;
    travelsImage2.layer.shadowOffset=CGSizeMake(10*PSDSCALE_X, 10*PSDSCALE_Y);
    travelsImage2.layer.shadowOpacity=0.8;
    travelsImage2.layer.shadowRadius=5*PSDSCALE_X;
    travelsImage2.contentMode = UIViewContentModeScaleAspectFill;
    travelsImage2.clipsToBounds = YES;
    [travelsView addSubview:travelsImage2];
    
    UILabel *travelsLab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(travelsImage1)+17*PSDSCALE_Y, 250*PSDSCALE_X, 37*PSDSCALE_Y)];
    travelsLab.text = @"游记";
    travelsLab.textAlignment = NSTextAlignmentCenter;
    travelsLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    [travelsView addSubview:travelsLab];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_click:)];
    [travelsView addGestureRecognizer:tap3];

}

- (void)tap_click:(UITapGestureRecognizer *)sender
{
    switch (sender.view.tag) {
        case 1:
        {
            MMLog(@"视频");
            AlbumsVideoViewController *albumsVideoVC = [[AlbumsVideoViewController alloc] init];
            albumsVideoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:albumsVideoVC animated:YES];
        }
            break;
        case 2:
        {
            MMLog(@"照片");
            AlbumsPhotoViewController *albumsPhotoVC = [[AlbumsPhotoViewController alloc] init];
            albumsPhotoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:albumsPhotoVC animated:YES];
        }
            break;
        case 3:
        {
            MMLog(@"轨迹");
            AlbumsPathViewController *albumsPathVC = [[AlbumsPathViewController alloc] init];
            albumsPathVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:albumsPathVC animated:YES];
        }
            break;
        case 4:
        {
            MMLog(@"游记");
            AlbumsTravelViewController *albumsTravelVC = [[AlbumsTravelViewController alloc] init];
            albumsTravelVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:albumsTravelVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
