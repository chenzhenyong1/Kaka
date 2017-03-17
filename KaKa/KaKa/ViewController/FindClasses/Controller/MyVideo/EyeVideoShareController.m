//
//  EyeVideoShareController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/19.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeVideoShareController.h"
#import "EyePlayView.h"
#import "EyeVideoPictureSelectedController.h"
#import "RecordModel.h"
#import "Credentials.h"
#import "ItemList.h"
#import <AliyunOSSiOS/OSSService.h>
#import "EyeCheckVideoController.h"
#import "SDAVAssetExportSession.h"//压缩的第三方库

#define yaSuoPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"yaSuo.mp4"]//压缩视频路径
#define yaSuoPicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"yaSuoPic.jpg"]//视频缩略图路径


@interface EyeVideoShareController ()

@property (nonatomic, strong) EyePlayView *playView;
/** 视频封面 */
@property (nonatomic, weak) UIImageView *videoCoverImageView;

/** CredentialsArr */
@property (nonatomic, strong) NSArray *credentialsArr;
/** ItemListArr */
@property (nonatomic, strong) NSArray *itemListArr;
/** 上传的文件路径数组 */
@property (nonatomic, strong) NSArray *pathArr;
/** 栏目ID */
@property (nonatomic, copy) NSString *columnId;
@end

@implementation EyeVideoShareController


int videoCredentialCount = 0;
int videoItemListCount = 0;

-(void)dealloc
{
    [self deleteTmpFile:yaSuoPath];
    
    [self deleteTmpFile:yaSuoPicPath];
    
    
    ZYLog(@"EyeBreakRulesController  dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
       
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置导航栏
    [self setupNav];
    self.view.backgroundColor = ZYGlobalBgColor;
    
    
    
    [self playView];
    
    
    videoCredentialCount = 0;
    videoItemListCount = 0;
    
}




/**
 *  设置导航栏
 */
- (void)setupNav
{
    
    self.title = @"视频分享";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
}


- (void)back
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出分享" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    
    [alert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//确认
        [self.playView pause];
        [self.playView removeFromSuperview];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)rightClick
{
    ZYLog(@"点击视频查看");
    EyeCheckVideoController *checkCtl = [EyeCheckVideoController new];
    
    checkCtl.addressModel = self.addressModel;
    
    checkCtl.videoPath = self.videoPath;
    checkCtl.musicName = self.playView.musicName;
    checkCtl.mute = self.playView.player.volume == 0 ? YES:NO;
    checkCtl.coverImage = self.videoCoverImageView.image;
    checkCtl.mood = self.textView.text;
    [self.navigationController pushViewController:checkCtl animated:YES];
}

#pragma mark -- property
//视频封面
-(UIImageView *)videoCoverImageView
{
    if (!_videoCoverImageView) {
        
        UIImageView *videoCoverImageView = [UIImageView new];
        
        videoCoverImageView.image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.videoPath] atTime:1.0/30];
        
        videoCoverImageView.frame = self.coverImageView.bounds;
        
        [self.playView insertSubview:videoCoverImageView belowSubview:self.playView.subviews[self.playView.subviews.count - 1]];
        
        _videoCoverImageView = videoCoverImageView;
        
        
        
    }
    
    return _videoCoverImageView;
}



- (EyePlayView *)playView {
    if (!_playView){
        _playView = [[EyePlayView alloc] initWithFrame:self.coverImageView.bounds];
        
#warning 修改地址
        //剪辑前的视频地址
//        NSBundle *mainBundle = [NSBundle mainBundle];
//        self.originalVideoPath = [mainBundle pathForResource: @"tmpMp4" ofType: @"mp4"];
        if (self.videoPath) {
            
            NSURL *videoFileUrl = [NSURL fileURLWithPath:self.videoPath];
            [_playView refreshUIWithMovieResouceUrl:videoFileUrl showImage:[UIImage imageNamed:@"find_breakRules_play"]];
            _playView.musicName = self.musicName;
            _playView.player.volume = self.mute ? 0 : 1;
            _playView.playTapCount++;
            //点击视频画面的时候，隐藏封面
            __weak typeof (self) weakSelf = self;
            _playView.touchBlock = ^{
                
                weakSelf.videoCoverImageView.hidden = YES;
            };
            
        }
        _playView.backgroundColor = [UIColor blackColor];
        
        [self.coverImageView addSubview:_playView];
    }
    return _playView;
}

#pragma mark -- super
- (void)addressBtnClick:(UIButton *)btn
{
    EyeSelectedAdressController *ctl = [EyeSelectedAdressController new];
    
    ctl.addressBlock = ^(NSString *address){
        
        self.addressModel.address = address;
        [self.addressBtn setTitle:address forState:UIControlStateNormal];
        [self.addressBtn sizeToFit];
    };
    
    [self.navigationController pushViewController:ctl animated:YES];
}


/**
 *  点击更换封面
 *
 *  @param button button description
 */
-(void)changCovImageBtnClick:(UIButton *)button
{
    ZYLog(@"changVideoCovImageBtnClick");
    
    EyeVideoPictureSelectedController *picSelectCtl = [EyeVideoPictureSelectedController new];
    
    picSelectCtl.videoPath = self.videoPath;
    
    picSelectCtl.selectedImageBlock = ^(UIImage *image){
        
        self.videoCoverImageView.hidden =NO;
        self.videoCoverImageView.image = image;
        
    };
    
    [self.navigationController pushViewController:picSelectCtl animated:YES];
    
}
/**
 *  点击视频分享按钮
 *
 *  @param button button description
 */
-(void)shareButtonClick:(UIButton *)button
{
    
    //心情的字符数
    NSUInteger count = [self GetStringCharSize:self.textView.text];
    
    if (count > 250) {//大于250个字符
        [self addActityText:@"心情描述不能超过250个字符" deleyTime:1];
        return;
    }else if (self.textView.text.length == 0)
    {
        [self addActityText:@"请写上你的心情..." deleyTime:1];
        return;
    }
    
    
    [self addActityLoading:@"正在请求数据..." subTitle:nil];
    
    [self qryColomID];
   
}

/**
 *  查询栏目ID
 */
- (void)qryColomID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"scope"] = @"*";
    params[@"loginToken"] = LoginToken;
    params[@"propName"] = VIDEO_SUBJ_COLUM_ID;
    //请求
    [HttpTool get:qryProfile_URL params:params success:^(id responseObj) {
        
        [self addActityLoading:@"正在压缩视频..." subTitle:nil];
        
        self.columnId = responseObj[@"result"][@"itemList"][0][@"propValue"];
        
        //视频压缩
        [self compressingMovie:[NSURL fileURLWithPath:self.videoPath]];
        
    } failure:^(NSError *error) {
        
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
        
    }];
    
}



/**
 *  视频压缩
 *
 *  @param url 视频地址
 */
- (void)compressingMovie:(NSURL *)url {
    
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    encoder.outputFileType = AVFileTypeMPEG4;
    
    [[NSFileManager defaultManager]removeItemAtPath:yaSuoPath error:nil];
    
    encoder.outputURL = [NSURL fileURLWithPath:yaSuoPath];;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @640,
    AVVideoHeightKey: @480,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @400000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @8000,
    AVEncoderBitRateKey: @41000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             
             ZYLog(@"Video export succeeded");
             ZYLog(@"导出完成! %@", [NSThread currentThread]);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 [self addActityText:@"压缩完成" deleyTime:0.5];
                 
                 //创建媒体记录 (创建完成后上传文件)
                 [self createMediaRecord];
                 
             });
             
             
             
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             ZYLog(@"Video export cancelled");
         }
         else
         {
             ZYLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
         }
     }];
}

//创建媒体记录
- (void)createMediaRecord
{
    //1.封装请求参数
    [self addActityLoading:@"创建媒体记录中..." subTitle:@"请等待"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mediaList"] = [self arrayMediaListParams];
    params[@"loginToken"] = LoginToken;
    
    //请求
    [HttpTool post:createMedias_URL params:params success:^(id responseObj) {
        
//        ZYLog(@"responseObj = %@",responseObj);
        
        RecordModel *model = [RecordModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        self.credentialsArr = model.credentials;
        
        self.itemListArr = model.itemList;
        
        //上传文件
        [self addActityLoading:@"正在上传文件中..." subTitle:@"请等待"];
        //将要上传的图片写入文件
        [self savePicToDocu];
//
        self.pathArr = @[yaSuoPath,yaSuoPicPath];
//
        [self upLoadFile:videoCredentialCount itemList:videoItemListCount];
        //        NSLog(@"model = %@",model.credentials[2]);
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
    }];
    
    
    
}
- (NSArray *)arrayMediaListParams
{
    NSFileManager *fm  = [NSFileManager defaultManager];
    // 取文件大小
    
    NSError *error = nil;
    NSDictionary* dictFile = [fm attributesOfItemAtPath:yaSuoPath error:&error];
    if (error)
        
    {
        ZYLog(@"getfilesize error: %@", error);
    }
    unsigned long long nFileSize = [dictFile fileSize]; //得到文件大小
    
    
    long long mediaCreateTime= [[NSDate date] timeIntervalSince1970]*1000;
    ZYLog(@"mediaCreateTime = %lld",mediaCreateTime);
    //视频媒体记录参数
    NSMutableDictionary *videoListParams = [NSMutableDictionary dictionary];
    videoListParams[@"id"] = @"#1";
    videoListParams[@"mediaType"] = @"v";
    videoListParams[@"format"] = @"mp4";
    videoListParams[@"shareState"] = @"1";
    videoListParams[@"uploadTrigger"] = @"4";
    videoListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    videoListParams[@"fileSize"] = [NSNumber numberWithUnsignedLongLong:nFileSize];
    
    videoListParams[@"backgroundMusic"] = self.musicName;
    videoListParams[@"mute"] = self.mute == YES ? @"true":@"false";
    
    videoListParams[@"producerDevId"] = @"iOS";
    
    //视频缩略图媒体记录参数
    NSMutableDictionary *videoJpgListParams = [NSMutableDictionary dictionary];
    videoJpgListParams[@"id"] = @"#2";
    videoJpgListParams[@"orgMediaId"] = @"#1";
    videoJpgListParams[@"mediaType"] = @"t";
    videoJpgListParams[@"format"] = @"jpg";
    videoJpgListParams[@"shareState"] = @"1";
    videoJpgListParams[@"uploadTrigger"] = @"4";
    videoJpgListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    videoJpgListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.videoCoverImageView.image, 0.5).length];
    
    NSArray *mediaList = @[videoListParams,videoJpgListParams];
    
    return mediaList;
}

/**
 *  将要上传的图片写入文件
 */
- (void)savePicToDocu
{
    
    [self deleteTmpFile:yaSuoPicPath];
    NSData* imageData = UIImageJPEGRepresentation(self.videoCoverImageView.image, UpLoadPicQuality);
    
    //图片数据保存到 document
    [imageData writeToFile:yaSuoPicPath atomically:NO];

    
}
/**
 *  上传文件
 */

- (void)upLoadFile:(int)credentialCount itemList:(int)itemListCount
{
    Credentials *credentials = self.credentialsArr[credentialCount];
    ItemList *itemList = self.itemListArr[itemListCount];
    NSString *endpoint = credentials.endPoint;
    
    if (credentials.securityToken == NULL) {
        [self addActityText:@"上传失败" deleyTime:2.0];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return;
    }
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:credentials.keyId secretKeyId:credentials.keySecret securityToken:credentials.securityToken];
    
    ZYLog(@"securityToken ==== %@",credentials.securityToken);
    
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = credentials.bucket;
    put.objectKey = itemList.storePath;
    
    put.uploadingFileURL = [NSURL fileURLWithPath:self.pathArr[itemListCount]];
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
        ZYLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        
    
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            ZYLog(@"upload object success!");
            // 更新媒体状态
            [self updateMediaState:itemList];
            
            
            
        } else {
            ZYLog(@"upload object failed, error: %@" , task.error);
            [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
        }
        return nil;
    }];
    
}

/**
 *  更新媒体状态
 *
 *  @param itemList itemList description
 */
- (void)updateMediaState:(ItemList *)itemList
{
    // 1.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"mediaId"] = itemList.ID;
    params[@"mediaState"] = @"2";
    
    [HttpTool post:updateMediaState_URL params:params success:^(id responseObj) {
        ZYLog(@"媒体状态更新成功responseObj = %@ itemListID = %@",responseObj,itemList.ID);
        
        videoItemListCount ++;
        //        travelsCredentialCount ++;
        if (videoItemListCount % 2 != 0) {//缩略图存放
            videoCredentialCount = (int)self.credentialsArr.count - 1;
        }else{//大图存放
            videoCredentialCount = 0;
        }
        //更新完最后一个时，发表话题
        if (videoItemListCount == self.itemListArr.count) {
            [self addActityText:@"上传成功" deleyTime:1.0];
            //发表话题
            [self submitSubject];
            return ;
        }
        //更新上传完后接着上传
        [self upLoadFile:videoCredentialCount itemList:videoItemListCount];
        
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
    }];
    
}
/**
 *  发表话题
 */
- (void)submitSubject
{
    NSMutableDictionary *subjectParams = [NSMutableDictionary dictionary];
    subjectParams[@"subjectKind"] = @3;//视频
    if (self.textView.text.length != 0) {
        
        subjectParams[@"shortText"] = self.textView.text;
    }else{
        subjectParams[@"shortText"] = @" ";
    }
    subjectParams[@"title"] = [self cutStringTill25:subjectParams[@"shortText"]];
    subjectParams[@"lon"] = [NSNumber numberWithDouble:self.addressModel.coordinate.longitude];
    subjectParams[@"lat"] = [NSNumber numberWithDouble:self.addressModel.coordinate.latitude];
    
    subjectParams[@"location"] = self.addressModel.address;
    
    
    subjectParams[@"columnId"] = self.columnId;
    
    NSMutableDictionary *thumbMediaIdParams1 = [NSMutableDictionary dictionary];
    thumbMediaIdParams1[@"thumbMediaId"] = [self.itemListArr[self.itemListArr.count -1] ID];
    
    
    subjectParams[@"thumbList"] = @[thumbMediaIdParams1];
    
    //话题媒体列表
    NSArray *mediaListArr = [self mediaList];
    

    NSMutableDictionary *submitSubjectParams = [NSMutableDictionary dictionary];
    submitSubjectParams[@"subject"] = subjectParams;
    submitSubjectParams[@"mediaList"] = mediaListArr;
    submitSubjectParams[@"loginToken"] = LoginToken;
    
    ZYLog(@"submitSubjectParams = %@",submitSubjectParams);
    
    [HttpTool post:submitSubject_URL params:submitSubjectParams success:^(id responseObj) {
        ZYLog(@"responseObj = %@---------发表成功",responseObj);
        [self addActityText:@"发表成功" deleyTime:2.0];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@---------发表失败",error);
        [self addActityText:@"发表失败" deleyTime:1.0];
    }];
    
}
/**
 *  话题媒体列表
 *
 *  @return return value description
 */
-(NSArray *)mediaList
{
    //视频
    NSMutableDictionary *mediaVideoParams = [NSMutableDictionary dictionary];
    mediaVideoParams[@"mediaId"] = [self.itemListArr[0] ID];
    mediaVideoParams[@"mediaType"] = @"v";

    
    return @[mediaVideoParams];
}

@end
