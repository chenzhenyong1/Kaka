//
//  CameraDetailCycleVideoCollectionViewCell.m
//  KaKa
//
//  Created by 陈振勇 on 2017/1/12.
//  Copyright © 2017年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailCycleVideoCollectionViewCell.h"
#include <sys/mount.h>
#import "FMDBTools.h"
#import "MyTools.h"

@interface CameraDetailCycleVideoCollectionViewCell ()

@property (nonatomic, strong) UIImageView *itemImage;
@property (nonatomic, strong) UIImageView *play_image;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downTask;

/** 下载的百分比 */
@property (nonatomic, weak) UILabel *downloadRateLabel;
/** UIActivityIndicatorView菊花样式 */
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@end


@implementation CameraDetailCycleVideoCollectionViewCell
{
    UIView *_cover;//蒙版
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        _itemImage.userInteractionEnabled = YES;
       
        UIActivityIndicatorView *activityIndicatorView = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        activityIndicatorView.center = _itemImage.center;
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView startAnimating];
//        activityIndicatorView.hidden = NO;
        [_itemImage addSubview:activityIndicatorView];
        _activityIndicatorView = activityIndicatorView;
//        [_activityIndicatorView startAnimating];
    }
    
    return self;
}


- (void)refreshCycleVideoDataWith:(NSDictionary *)dic macAddress:(NSString *)macAddress
{

    _play_image.hidden = NO;
    _cover.hidden = NO;
//    self.activityIndicatorView.hidden = NO;
    
    NSString *fileName = VALUEFORKEY(dic, @"fileName");
    //判断是否下载过
    NSString *file_Path = [[NSString alloc] init];
    file_Path = [CycleVideo_Path(macAddress) stringByAppendingPathComponent:fileName];
    
    //不存在就下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:file_Path])
//    if ([FMDBTools selectDownloadWithFile_name:fileName])
    {
        [self completeDownload];
//        NSArray *pathArr =[MyTools getAllDataWithPath:CyclePhoto_Path(nil) mac_adr:nil];
//        fileName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
//        fileName = [fileName stringByAppendingString:@".jpg"];
//        
//        NSString *path_sandox = Video_Photo_Path(nil);
//        //设置一个图片的存储路径
//        NSString *imagePath = [path_sandox stringByAppendingPathComponent:fileName];
//        
//        [pathArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([imagePath isEqualToString:(NSString *)obj]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    _itemImage.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
//                    
//                    *stop = YES;
//                });
//                
////                [self setNeedsDisplay];
//            }
//        }];
    }else//未下载
    {
        if ([[dic allKeys] containsObject:@"rate"]) {//rate有值代表正在下载或者等待下载
            
            [self downloading:VALUEFORKEY(dic, @"rate")];
            
        }else{
            self.downloadRateLabel.hidden = YES;
            [self.activityIndicatorView stopAnimating];
            _play_image.image = GETYCIMAGE(@"Camera_no_download");
//            [self.activityIndicatorView ];
        }
    }
    fileName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    fileName = [fileName stringByAppendingString:@".jpg"];
    
    [_itemImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/VIDEO/%@", [SettingConfig shareInstance].ip_url,fileName]]  placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage") options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        //        if (![[dic allKeys] containsObject:@"rate"]) {//如果不是正在下载视频就开始
        //
        //            [self.activityIndicatorView startAnimating];
        //        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            _itemImage.image = GETYCIMAGE(@"camera_timeLine_defaultImage");
        }
        
        
    }];
    
    
    
   

}

/**
 下载完成操作
 */
- (void)completeDownload
{
    self.downloadRateLabel.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    _play_image.hidden = NO;
    _play_image.image = GETYCIMAGE(@"camera_play");
    _cover.hidden = YES;
    
}

/**
 正在下载操作
 */
- (void)downloading:(NSString *)rate
{
    if (!self.activityIndicatorView.isAnimating) {
        
        [self.activityIndicatorView startAnimating];
    }
    self.downloadRateLabel.text = rate;
    [self.downloadRateLabel sizeToFit];
    self.downloadRateLabel.hidden = NO;
    _play_image.hidden = YES;
    if ([self.downloadRateLabel.text isEqualToString:@"100.00%"]) {//下载完毕
        [self completeDownload];
    }
}
#pragma mark ------------------- 下载文件 ------------------
-(void)downloadCycleVideoWithFileName:(NSString *)fileName macAddress:(NSString *)macAddress progress:(progress) progressRate completion:(completion)completion
{
    

    //手机存储小于500MB时
    if (![self Reserved])
    {
//        [self addActityText:@"手机内存不足" deleyTime:1];
        
        return;
    }
    
    //    [self addActityLoading:@"正在加载内容" subTitle:nil];
    NSString *file_Path = [[NSString alloc] init];
    file_Path = [CycleVideo_Path(macAddress) stringByAppendingPathComponent:fileName];
    
    //不存在就下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/Video/CycleVideo",macAddress]];
        
        
        NSString *file_Path = [documentsDirectoryURL absoluteString];
        // 判断文件夹是否存在，如果不存在，则创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
        else
        {
            NSLog(@"文件夹已存在");
        }
        
        //添加通知(当退出直播页面时,取消下载任务)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelTask) name:@"CameraDetailViewControllerBackNotification" object:nil];
        
        
        __weak typeof(self) weakSelf = self;
        NSString *url_str = [NSString stringWithFormat:@"http://%@/video/%@", [SettingConfig shareInstance].ip_url, fileName];
        
        __block NSString *finish_fileName = fileName;
        
        self.downTask = [RequestManager downloadWithURL:url_str savePathURL:documentsDirectoryURL progress:^(NSProgress *progress) {
            ZYLog(@"完成百分 = %.2lf%%",((progress.completedUnitCount + 0.0) / progress.totalUnitCount) * 100);
            CGFloat rate = ((progress.completedUnitCount + 0.0) / progress.totalUnitCount) * 100;
    
            if (progress) {//监听下载进度
                progressRate(rate);
            }
        } succeed:^(id responseObject) {
            ZYLog(@"responseObject = %@",responseObject);
            //判断是否下载过
//            if (![FMDBTools selectDownloadWithFile_name:fileName])
//            {
                if ([FMDBTools saveDownloadFileWithFileName:fileName is_del:@"0"]) {
                    MMLog(@"保存成功！");
                }
                finish_fileName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
                finish_fileName = [finish_fileName stringByAppendingString:@".jpg"];
                
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:finish_fileName])
                {
                    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
                    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/Video/CyclePhoto",macAddress]];
                    
                    
                    NSString *file_Path = [documentsDirectoryURL absoluteString];
                    // 判断文件夹是否存在，如果不存在，则创建
                    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
                    {
                        [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    else
                    {
                        NSLog(@"文件夹已存在");
                    }
                }
                //保存图片到沙盒
                UIImage *imagesave = _itemImage.image;
                NSString *path_sandox = CyclePhoto_Path(macAddress);
                //设置一个图片的存储路径
                NSString *imagePath = [path_sandox stringByAppendingPathComponent:finish_fileName];
                //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                [UIImagePNGRepresentation(imagesave) writeToFile:imagePath atomically:YES];

//            }
            
            if (completion) {//下载完成后调用
                completion();
            }
            
        } andFailed:^(NSError *error) {
            ZYLog(@"error = %@",error);
            NSString *temp_str = fileName;
            NSArray *pathArr;
            
            pathArr =[MyTools getAllDataWithPath:Video_Path(macAddress) mac_adr:macAddress];
            
            for (NSString *str in pathArr)
            {
                
                if ([str containsString:temp_str])
                {
                    temp_str = str;
                    break;
                }
            }
            BOOL isdeleteVideo = [weakSelf deleteDirInCache:temp_str];
            
            if (isdeleteVideo)
            {
                MMLog(@"删除成功");
                if ([FMDBTools selectDownloadWithFile_name:fileName])
                {
                    if ([FMDBTools updateDowloaddelWithFile_name:fileName])
                    {
                        MMLog(@"修改成功！");
                    }
                }
            }
        }];
        
        
    }
}


/**
 取消下载
 */
- (void)cancelTask
{
//    ZYLog(@"cancelTask");
    [self.downTask cancel];
}

#pragma mark ------------------- 判断手机剩余容量是否大于500MB--------------
//判断手机剩余容量是否大于500MB
-(BOOL)Reserved
{
    if ([[self freeDiskSpaceInBytes] integerValue]>500)
    {
        return YES;
    }
    return NO;
}
#pragma mark ------------------- 获取手机剩余空间-------------------------

//获取手机剩余空间
- (NSString *)freeDiskSpaceInBytes{
    
    struct statfs buf;
    
    long long freeSpace = -1;
    
    if(statfs("/var", &buf) >= 0){
        
        freeSpace = (long long)(buf.f_bsize * buf.f_bfree);
        
    }
    
    return [NSString stringWithFormat:@"%.2f" ,(double)roundf(freeSpace/1024/1024.0)];
    
}

#pragma mark --------------------- 删除文件 --------------------
//删除文件

-(BOOL)deleteDirInCache:(NSString *)dirName
{
    BOOL isDeleted = NO;
    //不存在就下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirName])
    {
        isDeleted = [[NSFileManager defaultManager] removeItemAtPath:dirName error:nil];
        return isDeleted;
    }
    return isDeleted;
}

#pragma mark --------------------- 懒加载 --------------------
//菊花样式
//-(UIActivityIndicatorView *)activityIndicatorView
//{
//    if (!_activityIndicatorView) {
//        UIActivityIndicatorView *activityIndicatorView = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
//        activityIndicatorView.center = _itemImage.center;
//        activityIndicatorView.hidesWhenStopped = YES;
////        [activityIndicatorView startAnimating];
////        activityIndicatorView.hidden = YES;
//        [_itemImage addSubview:activityIndicatorView];
//        _activityIndicatorView = activityIndicatorView;
//        ZYLog(@"_activityIndicatorView");
//    }
//    return _activityIndicatorView;
//}

- (UILabel *)downloadRateLabel
{
    if (!_downloadRateLabel) {
        UILabel *downloadRateLabel = [[UILabel alloc] init];
        
        downloadRateLabel.textAlignment = NSTextAlignmentCenter;
        downloadRateLabel.font = [UIFont systemFontOfSize:14];
        [_itemImage addSubview:downloadRateLabel];
        
        [downloadRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.activityIndicatorView.mas_bottom).offset(15 * PSDSCALE_Y);
            make.centerX.equalTo(self.activityIndicatorView.mas_centerX);
        }];
        
        
        _downloadRateLabel = downloadRateLabel;
    }
    return _downloadRateLabel;
}
@end
