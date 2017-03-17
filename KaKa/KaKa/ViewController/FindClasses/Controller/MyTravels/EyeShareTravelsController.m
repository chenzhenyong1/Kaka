//
//  EyeShareTravelsController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeShareTravelsController.h"
#import "AlbumsTravelDetailModel.h"
#import "RecordModel.h"
#import "Credentials.h"
#import "ItemList.h"
#import <AliyunOSSiOS/OSSService.h>
#import "MyTools.h"
#import "EyeChangeCoverController.h"//封面选择控制器
#import "EyeCheckTravelsController.h"//查看游记
@interface EyeShareTravelsController ()

/** CredentialsArr */
@property (nonatomic, strong) NSArray *credentialsArr;
/** ItemListArr */
@property (nonatomic, strong) NSArray *itemListArr;

/** 上传图片路径数组 */
@property (nonatomic, strong) NSMutableArray *pathArr;

/** 栏目ID */
@property (nonatomic, copy) NSString *columnId;

/** 分享图片数组 */
@property (nonatomic, strong) NSMutableArray *travelDetailArray;

@end

@implementation EyeShareTravelsController
int travelsCredentialCount = 0;
int travelsItemListCount = 0;
-(void)dealloc
{
    
    for (NSString *path in self.pathArr) {
        
        [self deleteTmpFile:path];
    }
    
    ZYLog(@"EyeBreakRulesController  dealloc");
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    self.title = @"游记分享";
    self.view.backgroundColor = ZYGlobalBgColor;
    travelsCredentialCount = 0;
    travelsItemListCount = 0;
    
}
- (void)setupNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                            } forState:UIControlStateNormal];
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)rightClick
{
    ZYLog(@"点击游记查看");
    EyeCheckTravelsController *checkCtl = [EyeCheckTravelsController new];
    
    checkCtl.addressModel = self.addressModel;
    checkCtl.coverImageName = self.coverImageName;
    
    checkCtl.model = self.model;
    checkCtl.mood = self.textView.text;
    [self.navigationController pushViewController:checkCtl animated:YES];
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
    ZYLog(@"点击游记分享更换页面按钮");
    EyeChangeCoverController *ctl = [EyeChangeCoverController new];
    
    ctl.model = self.model;
    
    ctl.imageBlock = ^(AlbumsTravelDetailModel *coverModel){
        
        self.coverImageView.image =[self getTraverlPicture:coverModel];
        self.coverImageName = coverModel.fileName;
    };
    
    [self.navigationController pushViewController:ctl animated:YES];
}

/**
 *  点击分享按钮
 *
 *  @param button button description
 */
- (void)shareButtonClick:(UIButton *)button
{
    //心情的字符数
    NSUInteger count = [self GetStringCharSize:self.textView.text];
    
    if (count > 250) {//大于250个字符
        [self addActityText:@"您的心情描述过长，最大支持250个字符！" deleyTime:1];
        return;
    }else if (self.textView.text.length == 0)
    {
        [self addActityText:@"请填写您心情描述！" deleyTime:1];
        return;
    }
    
    ZYLog(@"点击游记分享");
    //1.封装请求参数
    [self addActityLoading:@"正在上传与创建游记，请稍等！" subTitle:@"可能需要几分钟，这取决您的游记大小！"];
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
    params[@"propName"] = TRAVEL_SUBJ_COLUM_ID;
    //请求
    [HttpTool get:qryProfile_URL params:params success:^(id responseObj) {
        
        self.columnId = responseObj[@"result"][@"itemList"][0][@"propValue"];
        //创建媒体记录 (创建完成后上传文件)
        [self createMediaRecord];
        
    } failure:^(NSError *error) {
        
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
        
    }];
    
}


- (NSArray *)arrayMediaListParams
{
    NSMutableArray *travelDetailArray = [self changeUploadPicArr];
    
    //流水号ID
    int waterID = 0;
    int index = 0;
    //创建媒体时间
    long long mediaCreateTime= [[NSDate date] timeIntervalSince1970]*1000;
    NSMutableArray *mediaList = [NSMutableArray array];
    
    for (AlbumsTravelDetailModel *detailModel in travelDetailArray) {
        
//        ZYLog(@"detailModel = %@",detailModel.type);
        index ++;
        if (![detailModel.type isEqualToString:@"video"]) {
            
            //大图图片媒体记录参数
            NSMutableDictionary *picParams = [NSMutableDictionary dictionary];
            picParams[@"id"] = [NSString stringWithFormat:@"#%d",index];
            picParams[@"mediaType"] = @"i";
            picParams[@"format"] = @"jpg";
            picParams[@"shareState"] = @"1";
            picParams[@"uploadTrigger"] = @"4";
            picParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
            picParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation([self getTraverlPicture:detailModel], 1).length];
            picParams[@"attachToTrackSeqNum"] = [NSString stringWithFormat:@"%d",waterID];
            [mediaList addObject:picParams];
            
            //大图对应的缩略图媒体记录参数
        
            NSMutableDictionary *smallPicParams = [NSMutableDictionary dictionary];
            smallPicParams[@"id"] = [NSString stringWithFormat:@"#%d", ++index];
            smallPicParams[@"orgMediaId"] = picParams[@"id"];
            smallPicParams[@"mediaType"] = @"h";
            smallPicParams[@"format"] = @"jpg";
            smallPicParams[@"shareState"] = @"1";
            smallPicParams[@"uploadTrigger"] = @"4";
            smallPicParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
            smallPicParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation([self getTraverlPicture:detailModel], 0.5).length];
            [mediaList addObject:smallPicParams];
            
            //图片对应的写入路径
            [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:detailModel.fileName]];
            
            [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"suoLue%@",detailModel.fileName]]];
        }
        
       
        waterID ++;
        
    }
    
    return mediaList;
}


//创建媒体记录
- (void)createMediaRecord
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mediaList"] = [self arrayMediaListParams];
    params[@"loginToken"] = LoginToken;
    
    //请求
    [HttpTool post:createMedias_URL params:params success:^(id responseObj) {
        
        ZYLog(@"responseObj = %@",responseObj);
//        
        RecordModel *model = [RecordModel mj_objectWithKeyValues:responseObj[@"result"]];

        self.credentialsArr = model.credentials;
        
        self.itemListArr = model.itemList;

//        //上传文件
//        [self addActityLoading:@"正在上传文件中..." subTitle:@"请等待"];
        //将要上传的图片写入文件
        [self savePicToDocu];
//
//        self.pathArr = @[yaSuoPath,leftOrginPicPath,rightOrginPicPath,yaSuoPicPath,leftSuoluePicPath,rightSuoluePicPath];
        
        [self upLoadFile:travelsCredentialCount itemList:travelsItemListCount];
        //        NSLog(@"model = %@",model.credentials[2]);
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
    }];
    
    
}

/**
 *  上传文件
 */

- (void)upLoadFile:(int)credentialCount itemList:(int)itemListCount
{
    Credentials *credentials = self.credentialsArr[credentialCount];
    ItemList *itemList = self.itemListArr[itemListCount];
    NSString *endpoint = credentials.endPoint;
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:credentials.keyId secretKeyId:credentials.keySecret securityToken:credentials.securityToken];
    
    if (credentials.securityToken) {
        
//        ZYLog(@"securityToken ==== %@",credentials.securityToken);
        
        OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
        
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = credentials.bucket;
        put.objectKey = itemList.storePath;
        
        put.uploadingFileURL = [NSURL fileURLWithPath:self.pathArr[itemListCount]];
        
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
            // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
            ZYLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
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
        
        
    }else
    {
        [self addActityText:@"上传失败" deleyTime:2.0];
        
        return;
        
    }
    
    
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
        
        travelsItemListCount ++;
//        travelsCredentialCount ++;
        if (travelsItemListCount % 2 != 0) {//缩略图存放
            travelsCredentialCount = (int)self.credentialsArr.count - 1;
        }else{//大图存放
            travelsCredentialCount = 0;
        }
        //更新完最后一个时，发表话题
        if (travelsItemListCount == self.itemListArr.count) {
            [self addActityText:@"上传成功" deleyTime:1.0];
            //发表话题
            [self submitSubject];
            return ;
        }
        //更新上传完后接着上传
        [self upLoadFile:travelsCredentialCount itemList:travelsItemListCount];
        
        
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
    subjectParams[@"subjectKind"] = @1;
    if (self.textView.text.length != 0) {
        
        subjectParams[@"shortText"] = self.textView.text;
    }else{
         subjectParams[@"shortText"] = @" ";
    }
    subjectParams[@"title"] = [self cutStringTill25:subjectParams[@"shortText"]];
    subjectParams[@"lon"] = @(self.addressModel.coordinate.longitude);
    subjectParams[@"lat"] = @(self.addressModel.coordinate.latitude);
    subjectParams[@"location"] = self.addressModel.address;
    subjectParams[@"mileage"] = self.model.tirpMileage;
#warning
    NSString *startTimestring = [MyTools yearToTimestamp:_model.startTime];
    NSTimeInterval startTimestamp = [startTimestring longLongValue];
    
    // 结束时间
    NSString *endTimestring = [MyTools yearToTimestamp:_model.endTime];
    NSTimeInterval endTimestamp = [endTimestring longLongValue];
    
    // 总时间
    NSTimeInterval allTimestamp = endTimestamp - startTimestamp;
    NSString *allMinuteStr = [NSString stringWithFormat:@"%.0f", allTimestamp / 60];
    
    subjectParams[@"timeLength"] = allMinuteStr;
    
    subjectParams[@"columnId"] = self.columnId;
    //缩略图媒体信息列表
    NSMutableArray *thumbList = [NSMutableArray array];
    //话题媒体列表
    NSMutableArray *mediaList = [NSMutableArray array];
    
    NSMutableArray *travelDetailArray1 = [self changeUploadPicArr];
    int j = 0;
    for (int i = 0; i < self.itemListArr.count; i ++) {
    
        if (i % 2 != 0) {
            NSMutableDictionary *thumbMediaIdParams = [NSMutableDictionary dictionary];
            thumbMediaIdParams[@"thumbMediaId"] = [self.itemListArr[i] ID];
            [thumbList addObject:thumbMediaIdParams];
        }else
        {
            AlbumsTravelDetailModel *detailModel = travelDetailArray1[j];
            j++;
            
            NSMutableDictionary *mediaListParams = [NSMutableDictionary dictionary];
            mediaListParams[@"mediaId"] = [self.itemListArr[i] ID];
            mediaListParams[@"mediaType"] = @"i";
            mediaListParams[@"attachToTrackSeqNum"] = [self.itemListArr[i] attachToTrackSeqNum];
            mediaListParams[@"shortText"] = detailModel.mood;
            [mediaList addObject:mediaListParams];
        }
        
    }
    subjectParams[@"thumbList"] = thumbList;
    
    
    //话题轨迹列表
    
    int trackWaterID = 0;
    
    NSMutableArray *trackList = [NSMutableArray array];
    
//    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
    
    for (AlbumsTravelDetailModel *detailModel in self.travelDetailArray) {
        
        NSMutableDictionary *trackListParams = [NSMutableDictionary dictionary];
        trackListParams[@"seqNum"] = @(trackWaterID);
        trackListParams[@"lon"] = @([MyTools getLocationWithGPRMC:detailModel.gps].longitude);
        trackListParams[@"lat"] = @([MyTools getLocationWithGPRMC:detailModel.gps].latitude);
        trackListParams[@"gpsTime"] = @([detailModel.date longLongValue]);
        trackListParams[@"sysTime"] = detailModel.time;
        trackListParams[@"spd"] = @22;
        trackListParams[@"head"] = @27;
        [trackList addObject:trackListParams];
        trackWaterID ++;
    }
    
    
    NSMutableDictionary *submitSubjectParams = [NSMutableDictionary dictionary];
    submitSubjectParams[@"subject"] = subjectParams;
    submitSubjectParams[@"mediaList"] = mediaList;
    submitSubjectParams[@"trackList"] = trackList;
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
 *  将要上传的图片写入文件
 */
- (void)savePicToDocu
{
    for (NSString *path in self.pathArr) {
        
        [self deleteTmpFile:path];
    }
    
    NSMutableArray *travelDetailArray = [self changeUploadPicArr];
    
    
    int pathCount = 0;
    for (AlbumsTravelDetailModel *detailModel in travelDetailArray) {
        if (![detailModel.type isEqualToString:@"video"]) {
            
            //按照顺序把大图和缩略图写入文件路径
            [self saveImage:[self getTraverlPicture:detailModel] atPath:self.pathArr[pathCount] compressionQuality:1.0];
            
            [self saveImage:[self getTraverlPicture:detailModel] atPath:self.pathArr[++pathCount] compressionQuality:UpLoadPicQuality];
            pathCount++;
            
        }
        
    }
}


//保存图片
- (void)saveImage:(UIImage *)tempImage atPath:(NSString *)path compressionQuality:(CGFloat)compressionQuality
{
    NSData* imageData = UIImageJPEGRepresentation(tempImage, compressionQuality);
    
    //图片数据保存到 document
    [imageData writeToFile:path atomically:NO];
}




#pragma mark -- 获取游记图片

- (UIImage *)getTraverlPicture:(AlbumsTravelDetailModel *)detailModel
{

    NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
   
    ZYLog(@"imagePath = %@",imagePath);
    return image;
}


#pragma mark -- property

-(NSMutableArray *)travelDetailArray
{
    if (!_travelDetailArray) {
        _travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
        NSMutableArray *arr = [_travelDetailArray mutableCopy];
        for (AlbumsTravelDetailModel *detailModel in arr) {
            if (!detailModel.shared) {
                [_travelDetailArray removeObject:detailModel];
            }
        }
    }
    
    return _travelDetailArray;
}


-(NSMutableArray *)pathArr
{
    if (!_pathArr) {
        
        _pathArr = [NSMutableArray array];
        
    }
    
    return _pathArr;
}

-(void)setModel:(AlbumsTravelModel *)model
{
    
    _model = model;
    
    
    
    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:model.travelId];
    NSMutableArray *arr = [travelDetailArray mutableCopy];
    for (AlbumsTravelDetailModel *detailModel in arr) {
        if (!detailModel.shared) {
            [travelDetailArray removeObject:detailModel];
        }
    }
    
    
    AlbumsTravelDetailModel *detailModel = travelDetailArray[0];
    //封面图片
    self.coverImageView.image = [self getTraverlPicture:detailModel];
    
    self.coverImageName = detailModel.fileName;
//    for (AlbumsTravelDetailModel *detailModel in travelDetailArray) {
//        
//        CLLocationCoordinate2D D = [MyTools getLocationWithGPRMC:detailModel.gps];
//        ZYLog(@"2D = %lf",D.longitude);
//    }

}

#pragma mark -- 交换图片发表的顺序
- (NSMutableArray *)changeUploadPicArr
{
//    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
    
    
    //交换发表顺序
    
    for (int i = 0; i < self.travelDetailArray.count; i ++) {
        
        if ([self.coverImageName isEqualToString:[self.travelDetailArray[i] fileName]]) {
            
            [self.travelDetailArray exchangeObjectAtIndex:0 withObjectAtIndex:i];
            
        }
        
    }
    
    return self.travelDetailArray;
}
@end
