//
//  EyeBreakRulesController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBreakRulesController.h"
#import "EyeBreakRuleCell.h"
#import "EyeBreakRuleSelectedCell.h"
#import "EyeBreakRuleTextFieldCell.h"
#import "EyeBreakRuleModel.h"
#import "EyeBreakRulePictureController.h"
#import "ImageTextButton.h"
#import "EyeBreakRulesAddressController.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordModel.h"
#import "ItemList.h"
#import "Credentials.h"
#import <AliyunOSSiOS/OSSService.h>
#import "EyeAddressModel.h"
#import "EyeTrafficViolation.h"
#import "EyeBreakRulesTypeController.h"
#import "SDAVAssetExportSession.h"

//#import "avformat.h"
//#import "avcodec.h"
//#import "mathematics.h"

#define yaSuoPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"yaSuo.mp4"]//压缩视频路径
#define leftOrginPicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"leftOrginPic.jpg"]//左边大图路径
#define rightOrginPicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"rightOrginPic.jpg"]//右边大图路径
#define yaSuoPicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"yaSuoPic.jpg"]//视频大图路径
#define leftSuoluePicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"leftSuoluePic.jpg"]//左边缩略图路径
#define rightSuoluePicPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"rightSuoluePic.jpg"]//右边缩略图路径



@interface EyeBreakRulesController ()<UITableViewDelegate,UITableViewDataSource>
//{
//    AVOutputFormat *outFormat;
//    AVFormatContext *outfmt_ctx;
//    NSString *movBasePath;
//    NSString *filePath;
//
//}

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<EyeBreakRuleModel *> *dataArr;

/** 分享 */
@property (nonatomic, strong) UIButton *shareButton;

/** CredentialsArr */
@property (nonatomic, strong) NSArray *credentialsArr;
/** ItemListArr */
@property (nonatomic, strong) NSArray *itemListArr;

/** 上传的文件路径数组 */
@property (nonatomic, strong) NSArray *pathArr;

/** 违章地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;

/** 违章举报参数 */
@property (nonatomic, strong) EyeTrafficViolation *trafficViolation;

/** 栏目ID */
@property (nonatomic, copy) NSString *columnId;

@end

int credentialCount = 0;
int itemListCount = 0;
@implementation EyeBreakRulesController

-(EyeTrafficViolation *)trafficViolation
{
    if (!_trafficViolation) {
        _trafficViolation = [[EyeTrafficViolation alloc] init];
    }
    return _trafficViolation;
}

-(void)dealloc
{
    [self deleteTmpFile:yaSuoPath];
    [self deleteTmpFile:leftOrginPicPath];
    [self deleteTmpFile:rightOrginPicPath];
    [self deleteTmpFile:yaSuoPicPath];
    [self deleteTmpFile:leftSuoluePicPath];
    [self deleteTmpFile:rightSuoluePicPath];
    
    ZYLog(@"EyeBreakRulesController  dealloc");
}


#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    credentialCount = 0;
    itemListCount = 0;
    
    
    [self setupNav];
    self.view.backgroundColor = ZYGlobalBgColor;
    
    
    [self shareButton];
    //解决跳转卡顿的问题
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.tableView.tableHeaderView = self.headerView;
    });
   
    [self setupDataArr];
    
}



- (void)setupNav
{
    self.title = @"违章举报";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}

- (void)back
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出分享" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    
    [alert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//确认
        [self.headerView.playView pause];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)setupDataArr{
    // /var/mobile/Containers/Data/Application/569DA469-80E3-4425-9F50-023C73A476C8/Library/Caches/13113610723/E0B94D6C952C/Video/Video/20160928092837_13.mp4
    
    NSString *watermark = [self getWatermark:self.path];
    
    NSArray *titleArr = @[@"时间水印",@"违章地点",@"车辆类型",@"车牌号码",@"违章类型",@"联系人"];
    NSArray *desArr = @[watermark,@"违章位置",@"",@"例:粤B12345",@"选择违章类型",@"填写手机号码"];
    for (NSInteger i = 0; i < titleArr.count; i++) {
        EyeBreakRuleModel *model = [[EyeBreakRuleModel alloc] init];
        model.title = titleArr[i];
        model.des = desArr[i];
        [self.dataArr addObject:model];
    }
}
/**
 *  获得水印时间
 *
 *  @param str 视频路径
 *
 *  @return 水印时间
 */
-(NSString *)getWatermark:(NSString *)str
{
    NSRange range1 = [str rangeOfString:@"/" options:NSBackwardsSearch];
    
    
    NSString *subStr = [str substringWithRange:NSMakeRange(range1.location + 1 , 14)];
    
    
    
    NSMutableString *sub = [subStr mutableCopy];
    int index = 4;
    [sub insertString:@"-" atIndex:index];
    [sub insertString:@"-" atIndex:index+=3];
    [sub insertString:@" " atIndex:index+=3];
    [sub insertString:@":" atIndex:index+=3];
    [sub insertString:@":" atIndex:index+=3];
    
    self.trafficViolation.violateTime = sub;
    
    return sub;
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EyeBreakRuleModel *model = self.dataArr[indexPath.row];
    
    
    //车辆类型cell
    if (2 == indexPath.row){
        EyeBreakRuleSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EyeBreakRuleSelectedCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell refreshUIWithModel:model];
        
        self.trafficViolation.vehType = @"2";
        
        cell.btnClickBlock = ^(EyeBreakRuleSelectedCellButtonClick buttonClik){
        
            if (buttonClik == EyeBreakRuleSelectedCellButtonClickLeft) {
                
                ZYLog(@"左");
                self.trafficViolation.vehType = @"1";
                
            }else{
                
                ZYLog(@"右");
                self.trafficViolation.vehType = @"2";
            }
        
        
        };
        
        return cell;
    }else if (3 == indexPath.row || 5 == indexPath.row){// 车牌号码/联系人 cell
        EyeBreakRuleTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EyeBreakRuleTextFieldCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell isShowRightArrow:NO];
        [cell refreshUIWithModel:model];
        
        if (3 == indexPath.row) {
            cell.textfieldBlock = ^(NSString *text){
                
                self.trafficViolation.plate = text;
                
            };
        }else if (5 == indexPath.row){
        
            cell.textfieldBlock = ^(NSString *text){
                
                self.trafficViolation.contactPhoneNum = text;
            };
        }
        
        
        return cell;
    }
    //其它的cell
    EyeBreakRuleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EyeBreakRuleCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell isShowRightArrow:indexPath.row];
    [cell refreshUIWithModel:model];
    
//    if (0 == indexPath.row) {
//        [cell isShowRightArrow:NO];
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.row) {//跳转违章地点选择页面
        EyeBreakRulesAddressController *addressCtl = [[EyeBreakRulesAddressController alloc] init];
       
        addressCtl.changeAddressBlock = ^(EyeAddressModel *addressModel){
            
            self.addressModel = addressModel;
            self.trafficViolation.violateLocation = self.addressModel.address;
            EyeBreakRuleModel *model = self.dataArr[indexPath.row];
            model.des = addressModel.address;
            //刷新某一行
            NSIndexPath *indexPat=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPat,nil] withRowAnimation:UITableViewRowAnimationNone];
        };

        [self.navigationController pushViewController:addressCtl animated:YES];
    }else if (4 == indexPath.row){//跳转到违章类型选择页面
        
        EyeBreakRulesTypeController *breakRuleTypeCtl = [[EyeBreakRulesTypeController alloc] init];
        
        breakRuleTypeCtl.breakRulesTypeBlock = ^(NSString *typeStr){
            
            self.trafficViolation.violateTypeCode = typeStr;
            
            EyeBreakRuleModel *model = self.dataArr[indexPath.row];
            model.des = typeStr;
            //刷新某一行
            NSIndexPath *indexPat=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPat,nil] withRowAnimation:UITableViewRowAnimationNone];
        };
        
        [self.navigationController pushViewController:breakRuleTypeCtl animated:YES];
    
    }
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }

}


#pragma mark -- private


#pragma mark -- properties



-(UIButton *)shareButton
{
    if (!_shareButton) {
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [shareButton setBackgroundImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
        
        [shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:shareButton];
        
        [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.bottom.right.equalTo(self.view);
            make.height.equalTo(@49);
            
        }];

        _shareButton = shareButton;
    }
    
    return _shareButton;
}



- (EyeHeaderView *)headerView {
    if (!_headerView){
        _headerView = [[EyeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        
        [_headerView refreshUIWithMovieResouceUrl:[NSURL fileURLWithPath:self.videoPath] showImage:[UIImage imageNamed:@"find_breakRules_play"]];
        
        _headerView.playView.musicName = self.musicName;
        _headerView.playView.playTapCount++;
        _headerView.playView.player.volume = self.mute ? 0 : 1;
        __weak typeof(self) weakSelf = self;
        _headerView.addPicture = ^(EyeHeaderViewBtn btn){
            //跳转到封面选择
            EyeBreakRulePictureController *addPictureCtl = [[EyeBreakRulePictureController alloc] init];
            addPictureCtl.videoPath = weakSelf.videoPath;
            addPictureCtl.breakRulesImageBlock = ^(UIImage *image){
                if (btn == EyeHeaderViewBtnLeft) {//左边封面
                    [weakSelf.headerView.leftBtn setBackgroundImage:image forState:UIControlStateNormal];
                }else if (btn == EyeHeaderViewBtnRight){//右边封面
                    [weakSelf.headerView.rightBtn setBackgroundImage:image forState:UIControlStateNormal];
                }
                
                
            };
            
            
            
            [weakSelf.navigationController pushViewController:addPictureCtl animated:YES];
        };
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView){
        UITableView *tableView = [[UITableView alloc] init];
//        tableView.bounces = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerClass:[EyeBreakRuleCell class] forCellReuseIdentifier:NSStringFromClass([EyeBreakRuleCell class])];
        [tableView registerClass:[EyeBreakRuleSelectedCell class] forCellReuseIdentifier:NSStringFromClass([EyeBreakRuleSelectedCell class])];
        [tableView registerClass:[EyeBreakRuleTextFieldCell class] forCellReuseIdentifier:NSStringFromClass([EyeBreakRuleTextFieldCell class])];
        
        // 分割线从左侧开始
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [tableView setSeparatorInset:UIEdgeInsetsZero];
            
        }
        
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [tableView setLayoutMargins:UIEdgeInsetsZero];
            
        }
        
        
        [self.view addSubview:tableView];
        _tableView = tableView;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view.mas_top).offset(0);
            make.bottom.equalTo(self.shareButton.mas_top);
        }];
    }
    return _tableView;
}

- (NSMutableArray<EyeBreakRuleModel *> *)dataArr {
    if (!_dataArr){
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}


#pragma mark -- 分享点击事件

- (void)shareButtonClick:(UIButton *)btn
{
    if ([self judgmentSubject]) {//过滤漏填数据
        
        if ([self judgmentFormat]) {//判断手机和车牌格式
            
            [self addActityLoading:@"正在请求数据..." subTitle:nil];
            
            [self qryColomID];
        }
        
    }

}
/**
 *  过滤漏填的信息
 *
 *  @return return value description
 */
-(BOOL)judgmentSubject
{
    if (!self.trafficViolation.violateLocation) {
        [self addActityText:@"请选取违章位置" deleyTime:0.5];
        return NO;
    }else if (!self.trafficViolation.plate){
        [self addActityText:@"请填写车牌号码" deleyTime:0.5];
        return NO;
    }else if (!self.trafficViolation.vehType){
        [self addActityText:@"请选择车辆类型" deleyTime:0.5];
        return NO;
    }else if (!self.trafficViolation.violateTypeCode){
        [self addActityText:@"请选择违章类型" deleyTime:0.5];
        return NO;
        
    }else if (!self.trafficViolation.contactPhoneNum){
    
        [self addActityText:@"请填写手机号码" deleyTime:0.5];
        
        return NO;
    }else{
        return YES;
    }
}
/**
 *  手机和车牌号码的正则表达式
 *
 *  @return
 */
- (BOOL)judgmentFormat
{
    if (![self validateCarNo:self.trafficViolation.plate]) {
        [self addActityText:@"请填写正确的车牌号码" deleyTime:1.0];
        return NO;
    }else if (![self valiMobile:self.trafficViolation.contactPhoneNum]) {
        [self addActityText:@"请填写正确的手机号码" deleyTime:1.0];
        return NO;
    }else
    {
        return YES;
    }
    
    
}

//判断手机号码格式是否正确
- (BOOL)valiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}

/*车牌号验证 MODIFIED BY HELENSONG*/
- (BOOL)validateCarNo:(NSString *)carNo
{
    NSString *carRegex = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[警京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼]{0,1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
//    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}


/**
 *  查询栏目ID
 */
- (void)qryColomID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"scope"] = @"*";
    params[@"loginToken"] = LoginToken;
    params[@"propName"] = TV_SUBJ_COLUM_ID;
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



// 压缩视频
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
            
                [self addActityText:@"压缩完成" deleyTime:0.5];
            
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

        self.pathArr = @[yaSuoPath,leftOrginPicPath,rightOrginPicPath,yaSuoPicPath,leftSuoluePicPath,rightSuoluePicPath];
        
        [self upLoadFile:credentialCount itemList:itemListCount];
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
    [self deleteTmpFile:leftOrginPicPath];
    [self deleteTmpFile:rightOrginPicPath];
    [self deleteTmpFile:leftSuoluePicPath];
    [self deleteTmpFile:rightSuoluePicPath];
    [self deleteTmpFile:yaSuoPicPath];
    
    
    [self saveImage:self.headerView.leftBtn.currentBackgroundImage atPath:leftOrginPicPath compressionQuality:1.0];
    [self saveImage:self.headerView.rightBtn.currentBackgroundImage atPath:rightOrginPicPath compressionQuality:1.0];
   [self saveImage:self.headerView.rightBtn.currentBackgroundImage atPath:rightSuoluePicPath compressionQuality:UpLoadPicQuality];
    [self saveImage:self.headerView.leftBtn.currentBackgroundImage atPath:leftSuoluePicPath compressionQuality:UpLoadPicQuality];
    [self saveImage:self.headerView.leftBtn.currentBackgroundImage atPath:yaSuoPicPath compressionQuality:UpLoadPicQuality];
    
    

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
        
        itemListCount ++;
        if (itemListCount > self.itemListArr.count / 2 - 1) {
            credentialCount = (int)self.credentialsArr.count - 1;
        }
        //更新完最后一个时，发表话题
        if (itemListCount == self.itemListArr.count) {
            [self addActityText:@"上传成功" deleyTime:1.0];
            //发表话题
            [self submitSubject];
            return ;
        }
        //更新上传完后接着上传
        [self upLoadFile:credentialCount itemList:itemListCount];
        
        
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
    subjectParams[@"subjectKind"] = @5;
    subjectParams[@"shortText"] = @" ";
    subjectParams[@"title"] = @" ";
    subjectParams[@"lon"] = [NSNumber numberWithDouble:self.addressModel.coordinate.longitude];
    subjectParams[@"lat"] = [NSNumber numberWithDouble:self.addressModel.coordinate.latitude];
    
    subjectParams[@"location"] = self.trafficViolation.violateLocation;
    
    
    subjectParams[@"columnId"] = self.columnId;
    
    NSMutableDictionary *thumbMediaIdParams1 = [NSMutableDictionary dictionary];
    thumbMediaIdParams1[@"thumbMediaId"] = [self.itemListArr[3] ID];
    NSMutableDictionary *thumbMediaIdParams2 = [NSMutableDictionary dictionary];
    thumbMediaIdParams2[@"thumbMediaId"] = [self.itemListArr[4] ID];
    NSMutableDictionary *thumbMediaIdParams3 = [NSMutableDictionary dictionary];
    thumbMediaIdParams3[@"thumbMediaId"] = [self.itemListArr[5] ID];
    
    subjectParams[@"thumbList"] = @[thumbMediaIdParams1,thumbMediaIdParams2,thumbMediaIdParams3];
    
    
    NSArray *mediaListArr = [self mediaList];
    
    
    NSMutableDictionary *trafficViolationParams = [NSMutableDictionary dictionary];
    
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[format dateFromString:self.trafficViolation.violateTime];
    long long mediaCreateTime= [date timeIntervalSince1970]*1000;
    
    trafficViolationParams[@"violateTime"] = @(mediaCreateTime);
    
    trafficViolationParams[@"violateLocation"] = self.trafficViolation.violateLocation;
    
    trafficViolationParams[@"vehType"] = self.trafficViolation.vehType;
    trafficViolationParams[@"plate"] = self.trafficViolation.plate;
    trafficViolationParams[@"violateTypeCode"] = self.trafficViolation.violateTypeCode;
    trafficViolationParams[@"contact"] = @"test";
    trafficViolationParams[@"contactPhoneNum"] = self.trafficViolation.contactPhoneNum;
    
    
    NSMutableDictionary *submitSubjectParams = [NSMutableDictionary dictionary];
    submitSubjectParams[@"subject"] = subjectParams;
    submitSubjectParams[@"mediaList"] = mediaListArr;
    submitSubjectParams[@"trafficViolation"] = trafficViolationParams;
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


-(NSArray *)mediaList
{
    //视频
    NSMutableDictionary *mediaVideoParams = [NSMutableDictionary dictionary];
    mediaVideoParams[@"mediaId"] = [self.itemListArr[0] ID];
    mediaVideoParams[@"mediaType"] = @"v";
    //两张大图
    NSMutableDictionary *leftPicParams = [NSMutableDictionary dictionary];
    leftPicParams[@"mediaId"] = [self.itemListArr[1] ID];
    leftPicParams[@"mediaType"] = @"i";
    NSMutableDictionary *rightPicParams = [NSMutableDictionary dictionary];
    rightPicParams[@"mediaId"] = [self.itemListArr[2] ID];
    rightPicParams[@"mediaType"] = @"i";
    
    return @[mediaVideoParams,leftPicParams,rightPicParams];
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
    
    //左边大图媒体记录参数
    NSMutableDictionary *leftOrginListParams = [NSMutableDictionary dictionary];
    leftOrginListParams[@"id"] = @"#2";
    leftOrginListParams[@"mediaType"] = @"i";
    leftOrginListParams[@"format"] = @"jpg";
    leftOrginListParams[@"shareState"] = @"1";
    leftOrginListParams[@"uploadTrigger"] = @"4";
    leftOrginListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    leftOrginListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.headerView.leftBtn.currentBackgroundImage, 1).length];
    
    //右边大图媒体记录参数
    NSMutableDictionary *rightOrginListParams = [NSMutableDictionary dictionary];
    rightOrginListParams[@"id"] = @"#3";
    rightOrginListParams[@"mediaType"] = @"i";
    rightOrginListParams[@"format"] = @"jpg";
    rightOrginListParams[@"shareState"] = @"1";
    rightOrginListParams[@"uploadTrigger"] = @"4";
    rightOrginListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    rightOrginListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.headerView.rightBtn.currentBackgroundImage, 1).length];
    
    //视频缩略图媒体记录参数
    NSMutableDictionary *videoJpgListParams = [NSMutableDictionary dictionary];
    videoJpgListParams[@"id"] = @"#4";
    videoJpgListParams[@"orgMediaId"] = @"#1";
    videoJpgListParams[@"mediaType"] = @"t";
    videoJpgListParams[@"format"] = @"jpg";
    videoJpgListParams[@"shareState"] = @"1";
    videoJpgListParams[@"uploadTrigger"] = @"4";
    videoJpgListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    videoJpgListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.headerView.leftBtn.currentBackgroundImage, 0.5).length];
   
    //左边缩略图媒体记录参数
    NSMutableDictionary *leftJpgListParams = [NSMutableDictionary dictionary];
    leftJpgListParams[@"id"] = @"#5";
    leftJpgListParams[@"orgMediaId"] = @"#2";
    leftJpgListParams[@"mediaType"] = @"h";
    leftJpgListParams[@"format"] = @"jpg";
    leftJpgListParams[@"shareState"] = @"1";
    leftJpgListParams[@"uploadTrigger"] = @"4";
    leftJpgListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    leftJpgListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.headerView.leftBtn.currentBackgroundImage, 0.5).length];
    
    //右边缩略图媒体记录参数
    NSMutableDictionary *rightJpgListParams = [NSMutableDictionary dictionary];
    rightJpgListParams[@"id"] = @"#6";
    rightJpgListParams[@"orgMediaId"] = @"#3";
    rightJpgListParams[@"mediaType"] = @"h";
    rightJpgListParams[@"format"] = @"jpg";
    rightJpgListParams[@"shareState"] = @"1";
    rightJpgListParams[@"uploadTrigger"] = @"4";
    rightJpgListParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    rightJpgListParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(self.headerView.rightBtn.currentBackgroundImage, 0.5).length];
   
    
    NSArray *mediaList = @[videoListParams,leftOrginListParams,rightOrginListParams,videoJpgListParams,leftJpgListParams,rightJpgListParams];
    
    return mediaList;
}



@end
