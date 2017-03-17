//
//  EyeShareTrackController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeShareTrackController.h"
#import "MyTools.h"
#import "AlbumsPathModel.h"
#import "EyeCheckTrackController.h"

@interface EyeShareTrackController ()

/** 栏目ID */
@property (nonatomic, copy) NSString *columnId;

/** 上传图片路径数组 */
@property (nonatomic, strong) NSMutableArray *pathArr;
/** CredentialsArr */
@property (nonatomic, strong) NSArray *credentialsArr;
/** ItemListArr */
@property (nonatomic, strong) NSArray *itemListArr;
@end

@implementation EyeShareTrackController


int trackCredentialCount = 0;
int trackItemListCount = 0;

-(void)dealloc
{
    
    for (NSString *path in self.pathArr) {
        
        [self deleteTmpFile:path];
    }
    
    ZYLog(@"EyeShareTrackController  dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNav];
    
    self.changeCovImageBtn.hidden = YES;
    
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;

}

/**
 *  设置导航栏
 */
- (void)setupNav
{
    
    self.title = @"轨迹分享";
    self.view.backgroundColor = ZYGlobalBgColor;
    
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
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}



- (void)rightClick
{
    ZYLog(@"点击轨迹查看");
    EyeCheckTrackController *checkCtl = [EyeCheckTrackController new];

    
    checkCtl.model = self.model;
    checkCtl.addressModel = self.addressModel;
    checkCtl.mood = self.textView.text;
    [self.navigationController pushViewController:checkCtl animated:YES];
}

#pragma mark -- property
-(void)setModel:(AlbumsPathModel *)model
{
    
    
    
    _model = model;
    
    NSArray *pathArr =[MyTools getAllDataWithPath:Path_Photo(model.mac_adr) mac_adr:model.mac_adr];
    for (NSString *str in pathArr)
    {
        NSString *temp_str1 = [model.fileName componentsSeparatedByString:@"."][0];
        NSString *temp_str2 = [str componentsSeparatedByString:@"/"].lastObject;
        temp_str2 = [temp_str2 componentsSeparatedByString:@"."][0];
        if ([temp_str1 isEqualToString:temp_str2])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:str];
            self.coverImageView.image = image;
        }
        
    }
}

-(NSMutableArray *)pathArr
{
    if (!_pathArr) {
        
        _pathArr = [NSMutableArray array];
        
    }
    
    return _pathArr;
}

#pragma mark ---------------super
#pragma mark -- 点击分享

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



- (void)shareButtonClick:(UIButton *)button
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
    
    ZYLog(@"点击轨迹分享");
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
    params[@"propName"] = TRACK_SUBJ_COLUM_ID;
    //请求
    [HttpTool get:qryProfile_URL params:params success:^(id responseObj) {
        
        self.columnId = responseObj[@"result"][@"itemList"][0][@"propValue"];
        //创建媒体记录 (创建完成后上传文件)
        [self createMediaRecord];
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
        
    }];
    
}


- (NSArray *)arrayMediaListParams
{
    
    //创建媒体时间
    long long mediaCreateTime= [[NSDate date] timeIntervalSince1970]*1000;
    NSMutableArray *mediaList = [NSMutableArray array];
    
    //大图图片媒体记录参数
    NSMutableDictionary *picParams = [NSMutableDictionary dictionary];
    picParams[@"id"] = @"#1";
    picParams[@"mediaType"] = @"i";
    picParams[@"format"] = @"jpg";
    picParams[@"shareState"] = @"1";
    picParams[@"uploadTrigger"] = @"4";
    picParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    picParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.coverImageView.image, 1).length];
    
    [mediaList addObject:picParams];
    
    //大图对应的缩略图媒体记录参数
    
    NSMutableDictionary *smallPicParams = [NSMutableDictionary dictionary];
    smallPicParams[@"id"] = @"#2";
    smallPicParams[@"orgMediaId"] = picParams[@"id"];
    smallPicParams[@"mediaType"] = @"h";
    smallPicParams[@"format"] = @"jpg";
    smallPicParams[@"shareState"] = @"1";
    smallPicParams[@"uploadTrigger"] = @"4";
    smallPicParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    smallPicParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.coverImageView.image, 0.5).length];
    [mediaList addObject:smallPicParams];
    
    //图片对应的写入路径
    [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:self.model.fileName]];
    
    [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"suoLue%@",self.model.fileName]]];
    
    return mediaList;
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
        //
        RecordModel *model = [RecordModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        self.credentialsArr = model.credentials;
        
        self.itemListArr = model.itemList;
        
        //        //上传文件
        [self addActityLoading:@"正在上传文件中..." subTitle:@"请等待"];
        //将要上传的图片写入文件
        [self savePicToDocu];
        
        [self upLoadFile:trackCredentialCount itemList:trackItemListCount];
        //        NSLog(@"model = %@",model.credentials[2]);
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
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
   
        
    //按照顺序把大图和缩略图写入文件路径
    [self saveImage:self.coverImageView.image atPath:self.pathArr[0] compressionQuality:1.0];
    
    [self saveImage:self.coverImageView.image atPath:self.pathArr[1] compressionQuality:UpLoadPicQuality];
  
    
}


//保存图片
- (void)saveImage:(UIImage *)tempImage atPath:(NSString *)path compressionQuality:(CGFloat)compressionQuality
{
    NSData* imageData = UIImageJPEGRepresentation(tempImage, compressionQuality);
    
    //图片数据保存到 document
    [imageData writeToFile:path atomically:NO];
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
            [self addActityText:@"上传失败" deleyTime:1.0];
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
        
        trackItemListCount ++;
        //        travelsCredentialCount ++;
        if (trackItemListCount % 2 != 0) {//缩略图存放
            trackCredentialCount = (int)self.credentialsArr.count - 1;
        }else{//大图存放
            trackCredentialCount = 0;
        }
        //更新完最后一个时，发表话题
        if (trackItemListCount == self.itemListArr.count) {
            [self addActityText:@"上传成功" deleyTime:1.0];
            //发表话题
            [self submitSubject];
            return ;
        }
        //更新上传完后接着上传
        [self upLoadFile:trackCredentialCount itemList:trackItemListCount];
        
        
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
    subjectParams[@"subjectKind"] = @4;//轨迹
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
    
    //缩略图媒体信息列表
    NSMutableArray *thumbList = [NSMutableArray array];
    //话题媒体列表
    NSMutableArray *mediaList = [NSMutableArray array];
    for (int i = 0; i < self.itemListArr.count; i ++) {
        
        if (i % 2 != 0) {
            NSMutableDictionary *thumbMediaIdParams = [NSMutableDictionary dictionary];
            thumbMediaIdParams[@"thumbMediaId"] = [self.itemListArr[i] ID];
            [thumbList addObject:thumbMediaIdParams];
        }else
        {
            NSMutableDictionary *mediaListParams = [NSMutableDictionary dictionary];
            mediaListParams[@"mediaId"] = [self.itemListArr[i] ID];
            mediaListParams[@"mediaType"] = @"i";
            mediaListParams[@"attachToTrackSeqNum"] = [self.itemListArr[i] attachToTrackSeqNum];
            [mediaList addObject:mediaListParams];
        }
        
    }
    subjectParams[@"thumbList"] = thumbList;
    
    
    NSMutableDictionary *submitSubjectParams = [NSMutableDictionary dictionary];
    submitSubjectParams[@"subject"] = subjectParams;
    submitSubjectParams[@"mediaList"] = mediaList;
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
@end
