//
//  EyeSharePictureController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeMyPictureController.h"
#import "EyePictureListModel.h"
#import "EyeMyPictureCollectionCell.h"
#import "EyeAddPictureController.h"
#import "RecordModel.h"
#import "Credentials.h"
#import "ItemList.h"
#import <AliyunOSSiOS/OSSService.h>
#import "EyePictureChangeController.h" //更换封面页面
#import "EyeCheckPictureController.h"//查看页面


@interface EyeMyPictureController () <UICollectionViewDataSource, UICollectionViewDelegate>

/** 图片collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;


/** 上传图片路径数组 */
@property (nonatomic, strong) NSMutableArray *pathArr;

/** CredentialsArr */
@property (nonatomic, strong) NSArray *credentialsArr;
/** ItemListArr */
@property (nonatomic, strong) NSArray *itemListArr;

/** 栏目ID */
@property (nonatomic, copy) NSString *columnId;



@end

@implementation EyeMyPictureController

int pictureCredentialCount = 0;
int pictureItemListCount = 0;
static NSString * const PhotoId = @"EyeSharePhotoCell";


-(void)dealloc
{
    
    for (NSString *path in self.pathArr) {
        
        [self deleteTmpFile:path];
    }
    
    ZYLog(@"EyeMyPictureController  dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

     pictureCredentialCount = 0;
     pictureItemListCount = 0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNav];
    [self collectionView];
}


/**
 *  设置导航栏
 */
- (void)setupNav
{
//    [self setupNavBar];
    self.title = @"图片分享";
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
    ZYLog(@"点击图片查看");
    EyeCheckPictureController *checkCtl = [EyeCheckPictureController new];
    
    //交换发表顺序
    NSMutableArray *mutablePicArr = [self.picArr mutableCopy];
    
    for (int i = 0; i < mutablePicArr.count; i ++) {
        
        if ([self.coverImageName isEqualToString:[mutablePicArr[i] imageName]]) {
            
            [mutablePicArr exchangeObjectAtIndex:0 withObjectAtIndex:i];
            
        }
        
    }
    
    
    checkCtl.dataArr = mutablePicArr;
    checkCtl.addressModel = self.addressModel;
    checkCtl.mood = self.textView.text;
    [self.navigationController pushViewController:checkCtl animated:YES];
}



#pragma mark -- property

-(NSMutableArray *)pathArr
{
    if (!_pathArr) {
        
        _pathArr = [NSMutableArray array];
        
    }
    
    return _pathArr;
}


-(void)setPicArr:(NSArray *)picArr
{
    _picArr = picArr;
    
    self.coverImageName = [picArr[0] imageName];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.coverImageName];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.coverImageView.image = [UIImage imageWithData:imageData];
            
        });
    });
}



-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        //1.初始化layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        
        //2.初始化collectionView
        UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, self.coverImageView.bottom + 10, self.view.width - 10 , 150 * PSDSCALE_Y) collectionViewLayout:layout];
        mainCollectionView.showsHorizontalScrollIndicator = NO;
        
        mainCollectionView.backgroundColor = [UIColor clearColor];
        
        //3.注册collectionViewCell   注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
        [mainCollectionView registerClass:[EyeMyPictureCollectionCell class] forCellWithReuseIdentifier:@"EyeMyPictureCollectionCell"];
        //4.设置代理
        mainCollectionView.delegate = self;
        mainCollectionView.dataSource = self;
        [self.view addSubview:mainCollectionView];
        _collectionView = mainCollectionView;
        
        
    }
    
    return _collectionView;
    
}
#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picArr.count + 1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EyeMyPictureCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EyeMyPictureCollectionCell" forIndexPath:indexPath];
    
    //    cell.backgroundColor = [UIColor purpleColor];
    if (self.picArr.count == indexPath.row) {
        
        [cell refreshUI:@"bg_add_photo"];
        
    }else
    {
        EyePictureListModel *model = self.picArr[indexPath.row];
        [cell refreshUI: model.imageName];
    }

    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(150 * PSDSCALE_X, 150 * PSDSCALE_Y);
}

//间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.picArr.count) {
        
        
        EyeAddPictureController *ctl = [EyeAddPictureController new];
        
        ctl.dataArr = self.picArr;
        
        ctl.addPicCtlBlock = ^(NSArray *picArr){
            
            self.picArr = picArr;
            
            [self.collectionView reloadData];
        };
        
        
        [self.navigationController pushViewController:ctl animated:YES];
        
        
    }
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
 *  点击更换界面按钮
 *
 *  @param button button description
 */
-(void)changCovImageBtnClick:(UIButton *)button
{
    EyePictureChangeController *ctl = [EyePictureChangeController new];
    
    ctl.dataArr = self.picArr;
    
    ctl.imageBlock = ^(NSString *imageName){
    
        if (imageName) {
            
            self.coverImageName = imageName;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.coverImageName];
                NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.coverImageView.image = [UIImage imageWithData:imageData];
                    
                });
            });
            
        }
    };
    
    [self.navigationController pushViewController:ctl animated:YES];
}


/**
 *  点击分享
 *
 *  @param button button description
 */

-(void)shareButtonClick:(UIButton *)button
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
    
    if (!self.addressModel.address) {
        [self addActityText:@"获取不到当前地址，请重新检查网络..." deleyTime:1.0];
        
        return;
    }
    
    
     [self addActityLoading:@"正在上传与创建话题，请稍等" subTitle:@"可能需要几分钟，这取决您的图片数量！"];
    //查询栏目ID
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
    params[@"propName"] = PHOTO_SUBJ_COLUM_ID;
    //请求
    [HttpTool get:qryProfile_URL params:params success:^(id responseObj) {
        
        self.columnId = responseObj[@"result"][@"itemList"][0][@"propValue"];
        //创建媒体记录 (创建完成后上传文件)
        [self createMediaRecord];
        
    } failure:^(NSError *error) {
        
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
        
    }];

}


//创建媒体记录
- (void)createMediaRecord
{
    //1.封装请求参数
   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mediaList"] = [self arrayMediaListParams];
    params[@"loginToken"] = LoginToken;
    
    //请求
    [HttpTool post:createMedias_URL params:params success:^(id responseObj) {
        
          ZYLog(@"responseObj = %@",responseObj);
        
        RecordModel *model = [RecordModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        self.credentialsArr = model.credentials;
        
        self.itemListArr = model.itemList;
        
        //上传文件
//        [self addActityLoading:@"正在上传文件中..." subTitle:@"请等待"];
        //将要上传的图片写入文件
        [self savePicToDocu];
        
        [self upLoadFile:pictureCredentialCount itemList:pictureItemListCount];
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"网络不给力,请检查网络后重试!" deleyTime:1.0];
    }];
    
}

- (NSArray *)arrayMediaListParams
{
    
    int index = 0;
    //创建媒体时间
    long long mediaCreateTime= [[NSDate date] timeIntervalSince1970]*1000;
    NSMutableArray *mediaList = [NSMutableArray array];
    
    //交换发表顺序
    NSMutableArray *mutablePicArr = [self.picArr mutableCopy];
    
    for (int i = 0; i < mutablePicArr.count; i ++) {
        
        if ([self.coverImageName isEqualToString:[mutablePicArr[i] imageName]]) {
            
            [mutablePicArr exchangeObjectAtIndex:0 withObjectAtIndex:i];
            
        }
        
    }
    
    self.picArr = mutablePicArr;
    
    for (EyePictureListModel *model in self.picArr) {
        
        index ++;
        
        //大图图片媒体记录参数
        NSMutableDictionary *picParams = [NSMutableDictionary dictionary];
        picParams[@"id"] = [NSString stringWithFormat:@"#%d",index];
        picParams[@"mediaType"] = @"i";
        picParams[@"format"] = @"jpg";
        picParams[@"shareState"] = @"1";
        picParams[@"uploadTrigger"] = @"4";
        picParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
        picParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation([[UIImage alloc] initWithContentsOfFile:model.imageName] , 1).length];
        
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
        
        smallPicParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation([[UIImage alloc] initWithContentsOfFile:model.imageName], 0.5).length];
        
        [mediaList addObject:smallPicParams];
            
        
        //图片对应的写入路径
        
        [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:picParams[@"id"]]];
        
        [self.pathArr addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",smallPicParams[@"id"]]]];
        
    
        
    }
    
    return mediaList;
}

/**
 *  将要上传的图片写入文件
 */
- (void)savePicToDocu
{
    for (NSString *path in self.pathArr) {
        
        [self deleteTmpFile:path];
    }
    
    
    int pathCount = 0;
    for (EyePictureListModel *model in self.picArr) {
        
            
        //按照顺序把大图和缩略图写入文件路径
        [self saveImage:[[UIImage alloc] initWithContentsOfFile:model.imageName] atPath:self.pathArr[pathCount] compressionQuality:1.0];
            
        [self saveImage:[[UIImage alloc] initWithContentsOfFile:model.imageName] atPath:self.pathArr[++pathCount] compressionQuality:UpLoadPicQuality];
            pathCount++;
            
        
        
    }
    
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
        
        pictureItemListCount ++;
        //        travelsCredentialCount ++;
        if (pictureItemListCount % 2 != 0) {//缩略图存放
            pictureCredentialCount = (int)self.credentialsArr.count - 1;
        }else{//大图存放
            pictureCredentialCount = 0;
        }
        //更新完最后一个时，发表话题
        if (pictureItemListCount == self.itemListArr.count) {
            [self addActityText:@"上传成功" deleyTime:1.0];
            //发表话题
            [self submitSubject];
            return ;
        }
        //更新上传完后接着上传
        [self upLoadFile:pictureCredentialCount itemList:pictureItemListCount];
        
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
        [self addActityText:@"上传失败" deleyTime:1.0];

    }];
    
}

/**
 *  发表话题
 */
- (void)submitSubject
{
    NSMutableDictionary *subjectParams = [NSMutableDictionary dictionary];
    subjectParams[@"subjectKind"] = @2;//图片
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
