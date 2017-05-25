//
//  CameraDetailViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/21.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailViewController.h"
#import "CameraSettingViewController.h"
#import "MyTools.h"
#import "CameraCarBrandViewController.h"
#import "CameraDetailViewControllerTableViewCell.h"
#import "CameraDetailViewControllerTableViewCell2.h"
#import "CameraDetailViewControllerTableViewCell3.h"
#import "CameraDetailViewControllerTableViewCell4.h"
#import "CarBrandModel.h"
#import "WHC_XMLParser.h"
#import <CoreLocation/CoreLocation.h>
#import "CameraTime_lineModel.h"
#import "CameraDetailCollectionViewCell.h"
#import "MoviePlayerViewController.h"
#import "AlbumsModel.h"
#import "MsgModel.h"
#import "CameraVideoPlayer.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "FMDBTools.h"
#import "LHPhotoBrowser.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CameraDetailCycleVideoCollectionViewCell.h"

#define MiddleCollectViewTag 1001
#define rightCollectViewTag 1002

@interface CameraDetailViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, BMKLocationServiceDelegate,Time_lineDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *videoBgImageView;
// 视频播放
@property (nonatomic, copy) NSString *videoLiveUrlStr;
// 回放地址
@property (nonatomic, copy) NSString *videoLiveRecUrlStr;
@property (nonatomic, strong) CameraVideoPlayer *videoPlayer;

// 正常情况下显示的视频菜单按钮
@property (nonatomic, strong) UIView *videoNormalMenuBg;
// 选中情况下显示的视频菜单按钮
@property (nonatomic, strong) UIView *videoSelMenuBg;

// 红色线条
@property (nonatomic, strong) UIView *menuLine;
// 选中的菜单按钮
@property (nonatomic, strong) UIButton *selectedMenuBtn;
@property (nonatomic, strong) NSMutableArray *menuBtnsArray;

@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) UITableView *tableView1;
@property (nonatomic, strong) UITableView *tableView2;
@property (nonatomic, strong) UITableView *tableView3;

@property (nonatomic, strong) NSMutableArray *collectionDataSource;//数据数组（包含.jpg _10.jpg数据,不包含_pre.jpg数据）
@property (nonatomic, strong) NSMutableArray *xml_pre_Array;//数据数组（包含_pre.jpg _10.jpg数据）
@property (nonatomic, strong) NSMutableArray *download_arr;//下载资源数组
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *progress_lab;
@property (nonatomic, strong) UILabel *freeProgressView;




//录音按钮
@property (nonatomic, strong) UIButton *record_btn;

//循环视频视图
@property (nonatomic, strong) UICollectionView *cyclevideoCollectionView;
/** 循环视频数据源 */
@property (nonatomic, strong) NSMutableArray *cycleVideoArray;
/** 正在下载的视频文件 */
@property (nonatomic, copy) NSString *currentDownloadingFileName;
/** 下载循环视频的数组 */
@property (nonatomic, strong) NSMutableArray *downloadCycleVideoArray;
/** 在数组中下载第哪个视频  */
@property (nonatomic, assign) int downTag;
@end

@implementation CameraDetailViewController
{
    BOOL isShowSettingButton; // 是否显示设置按钮，默认显示，再点击视频隐藏，显示另一排按钮
    UIScrollView *_time_line_scrollView;//时间线
    UILabel *time_line_timeLab;//日期
    UIImageView *carBrandImage1;
    UILabel *all_mileage_lab1;//总里程
    UILabel *all_time_lab1;//总时间
    
    UIImageView *carBrandImage2;
    UILabel *all_mileage_lab2;//总里程
    UILabel *all_time_lab2;//总时间
    
    UIImageView *carBrandImage3;
    UILabel *all_mileage_lab3;//总里程
    UILabel *all_time_lab3;//总时间
    NSMutableArray *dataSource;
    
    NSDictionary *cdrSystemCfg;
    UIScrollView *imagesScrollView;//下载文件
    UISwitch *downloadSwitch;//下载开关
    int time_line_num;//计数
    
//    BMKMapView *_mapView; // 地图
//    BMKLocationService *_locationService; // 定位服务
    
    NSInteger _timeLineRequest_index; // 请求计数
    NSArray *_timeLineRequest_array; // 请求数组
    
    
    NSIndexPath *_indexPath;
    
    UIImageView *circleLeft;
    UIImageView *leftNeedle;// 左边指针
    UIImageView *rightNeedle;// 左边指针
    UILabel *speedLabel; // 速度
    
    UIButton *time_right_btn; // 后一日
    NSString *currentDateString; // 当前日期
    
    //遮盖
    UIView *_cover;
    //是否显示
    BOOL _isOpen;
    
    //是否下载完成
    BOOL isDownloadOver;
    
    //当前网络的mac地址
    NSString *_BSSID;
    
    
}

#pragma mark ------------------- life cycle ----------------------------

- (void)dealloc {
    NSLog(@"释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    if (_mapView) {
//        _mapView = nil;
//    }
}

-(void)viewWillAppear:(BOOL)animated {
//    [_mapView viewWillAppear];
//    //    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
//    _locationService.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (self.videoPlayer.ffmpegPlayer && self.videoPlayer.ffmpegPlayer.paused) {
        // 返回当前页面时，重新播放
        [self.videoPlayer.ffmpegPlayer play];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
//    [_mapView viewWillDisappear];
    //    _mapView.delegate = nil; // 不用时，置nil
//    _locationService.delegate = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
//    if (self.videoPlayer.ffmpegPlayer) {
//        // 离开当前页面把直播暂停
//        [self.videoPlayer.ffmpegPlayer pause];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isShowSettingButton = YES;
    time_line_num = 0;
    self.xml_pre_Array = [[NSMutableArray alloc] init];
    
    [self addTitle:@"咔咔"];
    
    // 添加返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton setImage:[UIImage imageNamed:@"me_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem * leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;

    // 视频视图
    [self addVideoView];
    
    //"时间线", "地图", "下载文件"
    [self addMenuButtonView];
    
    [self addBgScrollView];
    
    dataSource = [[NSMutableArray alloc] init];
    self.collectionDataSource = [[NSMutableArray alloc] init];
    self.download_arr = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    //判断摄像头是否在线
    if (self.model.is_on_line)
    {
        //摄像头时间校验
        if ([UserDefaults objectForKey:@"time_check"])
        {
            NSString *timeStr = [MyTools yearToTimestamp:[UserDefaults objectForKey:@"time_check"]];
            NSLog(@"%@",timeStr);
            //判断保存的时间是否大于一周
            if ([[MyTools getCurrentTimestamp] longLongValue] > ([timeStr longLongValue]+86400*7))
            {
                //时间校验
                [weakSelf time_check];
            }
        }
        else
        {
            //时间校验
            [weakSelf time_check];
        }
        // 读取实时视频文件
        [self getDeviceConfig];
        
        // 获取时间线数据
        [self requestTime_lineDataWithFlag:0];

    }
    else
    {
        // 从数据库加载时间线数据
        [self loadTime_line_dateFromDBWithTimeString:time_line_timeLab.text];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:@"fullScreenBtnClickNotice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoBackBtnClick:)
                                                 name:@"videoBackBtnClick"
                                               object:nil
     ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:@"dowload_Video" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle) name:@"ON_RESIGN_ACTIVE" object:nil];
    
}

#pragma mark ----------------- 点击返回按钮 ----------------------------

- (void)backButtonAction:(UIButton *)sender
{
    //退出时,如果正在下载循环视频是,取消下载任务,发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraDetailViewControllerBackNotification" object:nil];
    
    // 点击返回按钮，释放直播或者回放播放器
    if (self.videoPlayer) {
        if (self.videoPlayer.ffmpegPlayer) {
            self.videoPlayer.ffmpegPlayer = nil;
        }
        [self.videoPlayer removeFromSuperview];
        self.videoPlayer = nil;
    }
    
//    [[AsyncSocketManager sharedAsyncSocketManager] disconnectSocket];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark ----------------- 摄像头时间校验 ----------------------------

//摄像头时间校验
- (void)time_check
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"0F";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody = [MyTools getCurrentStandarTimeWithMinute1];
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"OK"])
        {
            [UserDefaults setObject:[MyTools getCurrentStandarTimeWithMinute1] forKey:@"time_check"];
            [UserDefaults synchronize];
        }
        else
        {
            [weakSelf addActityText:@"网络连接异常" deleyTime:1];
        }
        
    }];
}

#pragma mark ------------------------ 进入前台 -------------------------

- (void)onApplicationDidBecomeActiveHandle {
    
    // 进入前台，判断是不是当前页面，即视频详情页面
    if ([[SettingConfig shareInstance].currentViewController isKindOfClass:[self class]]) {
//        _locationService.delegate = self;
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        // 进入前台，重新加载播放器
        if (self.videoPlayer.ffmpegPlayer) {
            [self.videoPlayer initPlayer];
        }
    }
    
}

#pragma mark ------------------------ 进入后台 -------------------------


- (void)onApplicationWillResignActiveHandle
{
    // 进入后台，判断是不是当前页面，即视频详情页面
    if ([[SettingConfig shareInstance].currentViewController isKindOfClass:[self class]]) {
//        _locationService.delegate = nil;
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        // 进入后台，停止播放
        if (self.videoPlayer.ffmpegPlayer && !self.videoPlayer.ffmpegPlayer.paused) {
            [self.videoPlayer.ffmpegPlayer stop];
        }
    }
}

#pragma mark ---------------- 获取摄像机列表封面图片 --------------------------

// 获取摄像机列表封面图片
- (void)getCoverImage {
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"08";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
        // 从记录仪请求图片列表
        [RequestManager getRequestWithUrlString:[NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url,msg.msgBody] params:nil succeed:^(id responseObject) {
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            MMLog(@"%@",dic);
            NSDictionary *cdJpg = VALUEFORKEY(dic, @"cdJpg");
            
            NSString *coverStr = nil;
            if ([VALUEFORKEY(cdJpg, @"jpg") isKindOfClass:[NSArray class]])
            {
                NSArray *jpgs = VALUEFORKEY(cdJpg, @"jpg");
                if (jpgs.count > 0)
                {
                    // 获取最后一张当作摄像头背景图片
                    NSDictionary *coverDic = [jpgs lastObject];
                    coverStr = FORMATSTRING(VALUEFORKEY(coverDic, @"fileName"));
                }
            }
            else
            {
                coverStr = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(cdJpg, @"jpg"), @"fileName"));
            }
            
            // 把“_”去掉，有时候返回的数据有"_pre"
            if ([coverStr containsString:@"_"]) {
                NSArray *strArr = [coverStr componentsSeparatedByString:@"_"];
                NSString *preStr = [strArr firstObject];
                NSString *sufStr = [strArr lastObject];
                // 后缀名
                sufStr = [[sufStr componentsSeparatedByString:@"."] lastObject];
                coverStr = [NSString stringWithFormat:@"%@.%@", preStr, sufStr];
            }
            
            // 更新当前登录摄像头的背景图片
            [SettingConfig shareInstance].currentCameraModel.bgImage = coverStr;
            [CacheTool updateCameraListWithCameraListModel:[SettingConfig shareInstance].currentCameraModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                [NotificationCenter postNotificationName:@"CameraListNeedToReloadDataNoti" object:nil];
            });
            
        } andFailed:^(NSError *error) {
            
        }];
        
    }];

}

- (void)back_liveShow_click
{
    MMLog(@"回到直播");
}


#pragma mark ----------------- 关联视频拍照后 接收到第二次数据去请求视频 ------------------------

//关联视频拍照后 接收到第二次数据去请求视频
- (void)getData:(NSNotification *)not
{
    MsgModel *model = not.object;
    MMLog(@"%@",model.msgBody);
    
    NSArray *temp = [model.msgBody componentsSeparatedByString:@"."];
    NSString *temp_str = temp[0];
    if ([temp_str containsString:@"_"])
    {
        // 延时5秒后再去请求视频，不然会报参数错误
//        [self performSelector:@selector(sendReadViewCMDToCameraWithVideoString:) withObject:temp_str afterDelay:5];
        [self sendReadViewCMDToCameraWithVideoString:temp_str];
    }
    
}

#pragma mark ----------------- 根据视频名称请求一段视频 ------------------------------

// 根据视频名称请求一段视频
- (void)sendReadViewCMDToCameraWithVideoString:(NSString *)videoStr {
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *msg = [[MsgModel alloc] init];
    msg.cmdId = @"06";
    msg.token = [SettingConfig shareInstance].deviceLoginToken;
    msg.msgBody =videoStr;
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        if ([msg.msgBody hasSuffix:@".mp4"])
        {
                 [weakSelf getPhotoAndVideoWithisPhoto:NO isVideo:YES];
        }
    }];

}

#pragma mark -------------- 时间线(已废弃) ------------------------------------
//时间线 （已废弃）
-(void)getTime_lineData
{
    // 获取当天时间
    NSString *currentDateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMdd" date:[NSDate dateWithTimeIntervalSinceNow:-24*3600]];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/log/cdr_log%@.xml", [SettingConfig shareInstance].ip_url, currentDateStr];
    
    // 下载xml文件
    [self downloadTime_lineXMLWithURL:urlString];
    [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {

        NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
        NSArray *items = VALUEFORKEY(VALUEFORKEY(dic, @"log"), @"item");
        if (![items isKindOfClass:[NSArray class]])
        {
            return ;
        }
        if (![items isKindOfClass:[NSArray class]]) {
            return;
        }
        for (NSDictionary *dic in items)
        {
            if ([VALUEFORKEY(dic, @"type") isEqualToString:@"App login"])
            {
                continue;
            }
            if ([VALUEFORKEY(dic, @"type") isEqualToString:@"App login off"]) {
                continue;
            }
            
            if ([VALUEFORKEY(dic, @"type") isEqualToString:@"Video"]) {
                continue;
            }
            
            CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [dataSource addObject:model];
        }
        NSDictionary *dic1 = items[0];
        CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
        model.type = @"P";
        model.gps = VALUEFORKEY(dic1, @"gps");
        model.time = VALUEFORKEY(dic1, @"time");
        [dataSource insertObject:model atIndex:0];
        
        NSMutableArray *temp_arr = [dataSource mutableCopy];
        
        for (int i = 0; i<temp_arr.count; i ++)
        {
            if ((i+1) < temp_arr.count)
            {
                CameraTime_lineModel *model1 = temp_arr[i];
                CameraTime_lineModel *model2 = temp_arr[i+1];
                if ([model1.type isEqualToString:@"Stop CDR"] && [model2.type isEqualToString:@"Start CDR"])
                {
                    CameraTime_lineModel *model3 = [[CameraTime_lineModel alloc] init];
                    model3.type = @"P";
                    model3.gps = model1.gps;
                    model3.time = model1.time;
                    
                    
                    if (dataSource.count == temp_arr.count)
                    {
                        [dataSource insertObject:model3 atIndex:i+1];
                        
                    }
                    else
                    {
                        [dataSource insertObject:model3 atIndex:i+time_line_num+1];
                    }
                    
                    time_line_num ++;//1 2 3 4 5 6 7 8 9
                    
                    
                }
            }
            
        }
        
        CameraTime_lineModel *start_model = dataSource[1];
        CameraTime_lineModel *end_model = dataSource.lastObject;
        all_mileage_lab2.text = [NSString stringWithFormat:@"里程%dKm",[end_model.endMileage intValue]-[start_model.startMileage intValue]];
        [self.tableView1 reloadData];
        [self.tableView2 reloadData];
        [self.tableView3 reloadData];
    } andFailed:^(NSError *error)
    {
        MMLog(@"%@",error);
        
    }];
}


/**
 根据URL下载xml文件

 @param url url
 */
- (void)downloadTime_lineXMLWithURL:(NSString *)url
{
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Travel"];
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

    [RequestManager downloadWithURL:url savePathURL:documentsDirectoryURL progress:^(NSProgress *progress)
     {
         
     }
    succeed:^(id responseObject)
     {
         
     }
    andFailed:^(NSError *error)
     {
         MMLog(@"%@",error);
     }];
    
    
    
}





#pragma mark -------------------- 实时视频视图 -------------------------

- (void)addVideoView {
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.backgroundColor = [UIColor lightGrayColor];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.clipsToBounds = YES;
    bgImageView.backgroundColor = [UIColor blackColor];
//    bgImageView.image = GETNCIMAGE(@"camera_detail_video_bg.png");
    bgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(SCREEN_WIDTH*(9.0 / 16));
    }];
    _videoBgImageView = bgImageView;
    
    if (_model.bgImage) {
        // 如果有背景，加载背景
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", _model.ipAddress, _model.bgImage]];
        [_videoBgImageView sd_setImageWithURL:imageUrl placeholderImage:nil];
    }
    
    // 点击事件
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoView_action:)];
    [_videoBgImageView addGestureRecognizer:tapGes];
    
    [self addVideoMenuBtnView];
}

- (void)addVideoMenuBtnView {
    
    UIView *menuBgView = [[UIView alloc] init];
    menuBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    menuBgView.userInteractionEnabled = YES;
    [_videoBgImageView addSubview:menuBgView];
    [menuBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_videoBgImageView.mas_left);
        make.right.mas_equalTo(_videoBgImageView.mas_right);
        make.bottom.mas_equalTo(_videoBgImageView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    _videoNormalMenuBg = menuBgView;
    
    CGFloat leftMargin = 14.0;
    CGFloat itemWidth = 50.0;
    CGFloat itemSpace = (SCREEN_WIDTH - 2 * leftMargin - 5 * itemWidth) / 4;
    
    NSString *travelName = @"开始游记";
    // 是否有游记未结束
    BOOL isTraveling = [UserDefaults boolForKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
    if (isTraveling) {
        travelName = @" 游记中...";
    }
    
    // 五个按钮
    NSArray *btnImagesArray = @[GETNCIMAGE(@"camera_detail_setting_icon.png"), GETNCIMAGE(@"camera_detail_microphone_icon.png"), GETNCIMAGE(@"camera_detail_camera_icon.png"), GETNCIMAGE(@"camera_detail_car_icon.png"), GETNCIMAGE(@"camera_detail_fullScreen_icon.png")];
    for (NSInteger i = 0; i < btnImagesArray.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[btnImagesArray objectAtIndex:i] forState:UIControlStateNormal];
        if (i == 1)
        {
            _record_btn = btn;
            [btn setImage:GETYCIMAGE(@"camera_detail_microphone_icon_sel") forState:UIControlStateSelected];
        }
        [btn addTarget:self action:@selector(videoMenu_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 1;
        [menuBgView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftMargin + i * (itemWidth + itemSpace));
            make.centerY.mas_equalTo(menuBgView.mas_centerY);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(itemWidth);
        }];
        
        if (i == 3) {
            [btn setImage:GETNCIMAGE(@"camera_detail_car_icon_sel.png") forState:UIControlStateSelected];
            if (isTraveling) {
                btn.selected = YES;
            }
        }
    }

    UIView *menuSelBgView = [[UIView alloc] init];
    menuSelBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    menuSelBgView.userInteractionEnabled = YES;
    [_videoBgImageView addSubview:menuSelBgView];
    [menuSelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_videoBgImageView.mas_left);
        make.right.mas_equalTo(_videoBgImageView.mas_right);
        make.bottom.mas_equalTo(_videoBgImageView.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    _videoSelMenuBg = menuSelBgView;
    _videoSelMenuBg.hidden = YES;
    
    // 只有两个按钮
    leftMargin = 92.0;
    itemWidth = 50.0;
    itemSpace = SCREEN_WIDTH - 2 * (leftMargin + itemWidth);
    btnImagesArray = @[GETNCIMAGE(@"camera_detail_camera_icon.png"), GETNCIMAGE(@"camera_detail_car_icon.png")];
    NSArray *btnSelImagesArray = @[GETNCIMAGE(@"camera_detail_camera_icon.png"), GETNCIMAGE(@"camera_detail_car_icon_sel.png")];
    
    NSArray *titlesArray = @[@"拍照  ", travelName];
    for (NSInteger i = 0; i < btnImagesArray.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[btnImagesArray objectAtIndex:i] forState:UIControlStateNormal];
        [btn setImage:[btnSelImagesArray objectAtIndex:i] forState:UIControlStateSelected];
        [btn setTitle:titlesArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:RGBSTRING(@"b11c22") forState:UIControlStateSelected];
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:20 * FONTCALE_Y];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-15, 10, 0, 0)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(3, -15, -20, 0)];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btn addTarget:self action:@selector(videoMenu_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 1;
        [_videoSelMenuBg addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftMargin + i * (itemWidth + itemSpace));
            make.centerY.mas_equalTo(menuBgView.mas_centerY);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(40);
        }];
        
        if (i == 1) {
            
            [btn setTitle:@" 游记中..." forState:UIControlStateSelected];
            [btn setTitle:@"开始游记" forState:UIControlStateNormal];
            if (isTraveling) {
                btn.selected = YES;
            }
        }
    }

}

#pragma mark ------------------------ 按钮菜单 ---------------------------------

- (void)addMenuButtonView {
    // 按钮菜单
    NSArray *titlesArray = @[@"时间线", @"拍摄短片", @"循环视频"];
    _menuBtnsArray = [NSMutableArray array];
    for (NSInteger i = 0; i < titlesArray.count; i++) {
        UIButton *menuBtn = [[UIButton alloc] init];
        menuBtn.titleLabel.font = [UIFont systemFontOfSize:FONTCALE_Y * 30];
        [menuBtn setTitle:titlesArray[i] forState:UIControlStateNormal];
        [menuBtn setTitleColor:RGBSTRING(@"333333") forState:UIControlStateNormal];
        menuBtn.tag = i + 1;
        [menuBtn addTarget:self action:@selector(menuBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        CGFloat btnWidth = SCREEN_WIDTH / 3;
        CGFloat btnHeight = 44.0;
        [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_videoBgImageView.mas_bottom);
            make.height.mas_equalTo(btnHeight);
            make.width.mas_equalTo(btnWidth);
            make.left.mas_equalTo(i * btnWidth);
        }];
        
        if (i == 0) {
            menuBtn.enabled = NO;
            _selectedMenuBtn = menuBtn;
        }
        [_menuBtnsArray addObject:menuBtn];
    }
    
    // 黑线
    UIView *blackLine = [[UIView alloc] init];
    blackLine.backgroundColor = RGBSTRING(@"cccccc");
    [self.view addSubview:blackLine];
    [blackLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(_selectedMenuBtn.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    _menuLine = [[UIView alloc] init];
    _menuLine.backgroundColor = RGBSTRING(@"ad1e22");
    [self.view addSubview:_menuLine];
    [_menuLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(_selectedMenuBtn.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH / 3);
        make.height.mas_equalTo(2);
    }];
    
}

#pragma mark --------------------- 底部滑动视图ScrollView ---------------------

- (void)addBgScrollView {
    
    [self.view layoutIfNeeded];
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(_menuLine), SCREEN_WIDTH, SCREEN_HEIGHT_4s - VIEW_H_Y(_menuLine) - NAVIGATIONBARHEIGHT)];
    _bgScrollView.scrollEnabled = NO;
    _bgScrollView.contentSize = CGSizeMake(3 * SCREEN_WIDTH, 0);
    _bgScrollView.pagingEnabled = YES;
    _bgScrollView.bounces = NO;
    _bgScrollView.delegate = self;
    [self.view addSubview:_bgScrollView];
    
//    NSArray *imagesArray = @[GETNCIMAGE(@"camera_time_testbg.png"), GETNCIMAGE(@"camera_map_testBg")];
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, VIEW_H(_bgScrollView))];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.userInteractionEnabled = YES;
        // view.backgroundColor = RGBACOLOR(arc4random() % 256, arc4random() % 256, arc4random() % 256, 1);
        
        
        if (i ==2) {
            // 地图
//            view.image = [imagesArray objectAtIndex:i];
            if (_model.is_on_line) {
                
                [self addMapViewWithSuperView:view];
            }else{
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view.width / 2 - 120 * PSDSCALE_X, view.height / 2 - 100 * PSDSCALE_X, 100, 100)];
                label.text = @"未连接咔咔wifi!!";
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:20];
//                label.center = view.center;
                [label sizeToFit];
//                label.centerX = view.centerX;
//                label.backgroundColor = [UIColor yellowColor];
                [view addSubview:label];
            }
        }
        
        if (i == 1)
        {
            // 下载图片或者视频
            [self addDownloadFileView:view];
        }
        [_bgScrollView addSubview:view];
        if (i == 0)
        {
            // 时间线
            [self initTime_line_UI];
        }
    }
    
}


#pragma mark ----------------- 时间线视图 --------------------------

/**
 时间线视图
 */
- (void)initTime_line_UI
{
    [self.view layoutIfNeeded];
    _time_line_scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - VIEW_H_Y(_menuLine) - NAVIGATIONBARHEIGHT)];
    _time_line_scrollView.pagingEnabled = YES;
    _time_line_scrollView.contentSize = CGSizeMake(3 * SCREEN_WIDTH, 0);
    _time_line_scrollView.delegate = self;
    [_bgScrollView addSubview:_time_line_scrollView];
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 85*PSDSCALE_Y)];
    timeView.backgroundColor = [UIColor whiteColor];
    time_line_timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 85*PSDSCALE_Y)];
    time_line_timeLab.text =[MyTools getCurrentStandarTime];
    time_line_timeLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    time_line_timeLab.textColor = RGBSTRING(@"b22d31");
    time_line_timeLab.textAlignment = NSTextAlignmentCenter;
    [timeView addSubview:time_line_timeLab];
    
    UIButton *left_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160*PSDSCALE_X, 85*PSDSCALE_Y)];
    [left_btn setTitle:@"< 前一日" forState:UIControlStateNormal];
    left_btn.tag = 1;
    [left_btn addTarget:self action:@selector(time_Change:) forControlEvents:UIControlEventTouchUpInside];
    left_btn.titleLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [left_btn setTitleColor:RGBSTRING(@"333333") forState:UIControlStateNormal];
    [timeView addSubview:left_btn];
    
    UIButton *right_btn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-160*PSDSCALE_X, 0, 160*PSDSCALE_X, 85*PSDSCALE_Y)];
    [right_btn setTitle:@"后一日 >" forState:UIControlStateNormal];
    right_btn.tag = 2;
    right_btn.titleLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [right_btn setTitleColor:RGBSTRING(@"333333") forState:UIControlStateNormal];
    [right_btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [right_btn addTarget:self action:@selector(time_Change:) forControlEvents:UIControlEventTouchUpInside];
    [timeView addSubview:right_btn];
    [_bgScrollView addSubview:timeView];
    right_btn.enabled = NO;
    time_right_btn = right_btn;
    
    _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 85*PSDSCALE_Y, SCREEN_WIDTH, SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-85*PSDSCALE_Y-VIEW_H_Y(_menuLine))style:UITableViewStylePlain];
    _tableView1.delegate = self;
    _tableView1.dataSource = self;
    _tableView1.tableFooterView = [UIView new];
    _tableView1.backgroundColor = [UIColor whiteColor];
    
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 85*PSDSCALE_Y, SCREEN_WIDTH, SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-85*PSDSCALE_Y-VIEW_H_Y(_menuLine))style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    _tableView2.tableFooterView = [UIView new];
    _tableView2.backgroundColor = [UIColor whiteColor];
    
    _tableView3 = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 85*PSDSCALE_Y, SCREEN_WIDTH, SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-85*PSDSCALE_Y-VIEW_H_Y(_menuLine))style:UITableViewStylePlain];
    _tableView3.delegate = self;
    _tableView3.dataSource = self;
    _tableView3.tableFooterView = [UIView new];
    _tableView3.backgroundColor = [UIColor whiteColor];
    
    [_time_line_scrollView addSubview:self.tableView1];
    [_time_line_scrollView addSubview:self.tableView2];
    [_time_line_scrollView addSubview:self.tableView3];
    
    self.tableView1.tableHeaderView = [self HeadView1];
    self.tableView2.tableHeaderView = [self HeadView2];
    self.tableView3.tableHeaderView = [self HeadView3];
    
    _time_line_scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
}

- (UIView *)HeadView1
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 190*PSDSCALE_Y)];
    
    carBrandImage1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120*PSDSCALE_X)/2, 14*PSDSCALE_Y, 120*PSDSCALE_X, 120*PSDSCALE_Y)];
    carBrandImage1.layer.masksToBounds = YES;
    carBrandImage1.layer.cornerRadius = 60*PSDSCALE_X;
    NSString *carImageName = [UserDefaults objectForKey:[NSString stringWithFormat:@"%@_%@", UserName, _model.macAddress]];
    if (carImageName) {
        carBrandImage1.image = GETYCIMAGE(carImageName);
    } else {
        carBrandImage1.image = GETYCIMAGE(@"camera_car_default");
    }

    carBrandImage1.contentMode = UIViewContentModeScaleAspectFit;
    carBrandImage1.userInteractionEnabled = YES;
    [headView addSubview:carBrandImage1];
    
    UILabel *my_love_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(carBrandImage1)+20*PSDSCALE_Y, SCREEN_WIDTH, 32*PSDSCALE_Y)];
    my_love_lab.text = @"我的爱车";
    my_love_lab.textAlignment = NSTextAlignmentCenter;
    my_love_lab.textColor = RGBSTRING(@"414141");
    my_love_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:my_love_lab];
    
    UILabel *all_mileage = [[UILabel alloc] initWithFrame:CGRectMake(0, 42*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage.text = @"驾驶里程";
    all_mileage.textAlignment = NSTextAlignmentCenter;
    all_mileage.textColor = RGBSTRING(@"414141");
    all_mileage.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage];
    
    all_mileage_lab1 = [[UILabel alloc] initWithFrame:CGRectMake(31*PSDSCALE_X, VIEW_H_Y(all_mileage)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage_lab1.textColor = RGBSTRING(@"ad1e22");
    all_mileage_lab1.textAlignment = NSTextAlignmentLeft;
    all_mileage_lab1.text = @"0KM";
    all_mileage_lab1.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage_lab1];
    
    UILabel *all_time = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-152*PSDSCALE_X, 42*PSDSCALE_Y, 120*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time.text = @"驾驶时间";
    all_time.textAlignment = NSTextAlignmentRight;
    all_time.textColor = RGBSTRING(@"414141");
    all_time.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time];
    
    all_time_lab1 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-183*PSDSCALE_X, VIEW_H_Y(all_time)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time_lab1.textColor = RGBSTRING(@"ad1e22");
    all_time_lab1.textAlignment = NSTextAlignmentRight;
    all_time_lab1.text = @"0分钟";
    all_time_lab1.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time_lab1];
    
    
    return headView;
}

- (UIView *)HeadView2
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 190*PSDSCALE_Y)];
    
    carBrandImage2 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120*PSDSCALE_X)/2, 14*PSDSCALE_Y, 120*PSDSCALE_X, 120*PSDSCALE_Y)];
    carBrandImage2.layer.masksToBounds = YES;
    carBrandImage2.layer.cornerRadius = 60*PSDSCALE_X;
    
    NSString *carImageName = [UserDefaults objectForKey:[NSString stringWithFormat:@"%@_%@", UserName, _model.macAddress]];
    if (carImageName) {
        carBrandImage2.image = GETYCIMAGE(carImageName);
    } else {
        carBrandImage2.image = GETYCIMAGE(@"camera_car_default");
    }
    
    carBrandImage2.contentMode = UIViewContentModeScaleAspectFit;
    carBrandImage2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(select_carBrand2)];
    [carBrandImage2 addGestureRecognizer:tap];
    [headView addSubview:carBrandImage2];
    
    UILabel *my_love_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(carBrandImage2)+20*PSDSCALE_Y, SCREEN_WIDTH, 32*PSDSCALE_Y)];
    my_love_lab.text = @"我的爱车";
    my_love_lab.textAlignment = NSTextAlignmentCenter;
    my_love_lab.textColor = RGBSTRING(@"414141");
    my_love_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:my_love_lab];
    
    UILabel *all_mileage = [[UILabel alloc] initWithFrame:CGRectMake(0, 42*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage.text = @"驾驶里程";
    all_mileage.textAlignment = NSTextAlignmentCenter;
    all_mileage.textColor = RGBSTRING(@"414141");
    all_mileage.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage];
    
    all_mileage_lab2 = [[UILabel alloc] initWithFrame:CGRectMake(31*PSDSCALE_X, VIEW_H_Y(all_mileage)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage_lab2.textColor = RGBSTRING(@"ad1e22");
    all_mileage_lab2.textAlignment = NSTextAlignmentLeft;
    all_mileage_lab2.text = @"4.44KM";
    all_mileage_lab2.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage_lab2];
    
    UILabel *all_time = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-152*PSDSCALE_X, 42*PSDSCALE_Y, 120*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time.text = @"驾驶时间";
    all_time.textAlignment = NSTextAlignmentRight;
    all_time.textColor = RGBSTRING(@"414141");
    all_time.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time];
    
    all_time_lab2 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-183*PSDSCALE_X, VIEW_H_Y(all_time)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time_lab2.textColor = RGBSTRING(@"ad1e22");
    all_time_lab2.textAlignment = NSTextAlignmentRight;
    all_time_lab2.text = @"18分钟";
    all_time_lab2.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time_lab2];
    
    
    return headView;
}

- (UIView *)HeadView3
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 190*PSDSCALE_Y)];
    
    carBrandImage3 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120*PSDSCALE_X)/2, 14*PSDSCALE_Y, 120*PSDSCALE_X, 120*PSDSCALE_Y)];
    carBrandImage3.layer.masksToBounds = YES;
    carBrandImage3.layer.cornerRadius = 60*PSDSCALE_X;
    NSString *carImageName = [UserDefaults objectForKey:[NSString stringWithFormat:@"%@_%@", UserName, _model.macAddress]];
    if (carImageName) {
        carBrandImage3.image = GETYCIMAGE(carImageName);
    } else {
        carBrandImage3.image = GETYCIMAGE(@"camera_car_default");
    }
    carBrandImage3.contentMode = UIViewContentModeScaleAspectFit;
    carBrandImage3.userInteractionEnabled = YES;
    [headView addSubview:carBrandImage3];
    
    UILabel *my_love_lab = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(carBrandImage3)+20*PSDSCALE_Y, SCREEN_WIDTH, 32*PSDSCALE_Y)];
    my_love_lab.text = @"我的爱车";
    my_love_lab.textAlignment = NSTextAlignmentCenter;
    my_love_lab.textColor = RGBSTRING(@"414141");
    my_love_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:my_love_lab];
    
    UILabel *all_mileage = [[UILabel alloc] initWithFrame:CGRectMake(0, 42*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage.text = @"驾驶里程";
    all_mileage.textAlignment = NSTextAlignmentCenter;
    all_mileage.textColor = RGBSTRING(@"414141");
    all_mileage.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage];
    
    all_mileage_lab3 = [[UILabel alloc] initWithFrame:CGRectMake(31*PSDSCALE_X, VIEW_H_Y(all_mileage)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_mileage_lab3.textColor = RGBSTRING(@"ad1e22");
    all_mileage_lab3.textAlignment = NSTextAlignmentLeft;
    all_mileage_lab3.text = @"4.44KM";
    all_mileage_lab3.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_mileage_lab3];
    
    UILabel *all_time = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-152*PSDSCALE_X, 42*PSDSCALE_Y, 120*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time.text = @"驾驶时间";
    all_time.textAlignment = NSTextAlignmentRight;
    all_time.textColor = RGBSTRING(@"414141");
    all_time.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time];
    
    all_time_lab3 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-183*PSDSCALE_X, VIEW_H_Y(all_time)+14*PSDSCALE_Y, 154*PSDSCALE_X, 32*PSDSCALE_Y)];
    all_time_lab3.textColor = RGBSTRING(@"ad1e22");
    all_time_lab3.textAlignment = NSTextAlignmentRight;
    all_time_lab3.text = @"18分钟";
    all_time_lab3.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [headView addSubview:all_time_lab3];
    
    
    return headView;
}




- (void)select_carBrand2
{
    CameraCarBrandViewController *cameraCarBrandVC = [[CameraCarBrandViewController alloc] init];
    cameraCarBrandVC.block =^(CarBrandModel *model)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            carBrandImage2.image = GETYCIMAGE(model.car_image_name);
            
            [UserDefaults setObject:model.car_image_name forKey:[NSString stringWithFormat:@"%@_%@", UserName, _model.macAddress]];
        });
        
    };
    
    
    [self.navigationController pushViewController:cameraCarBrandVC animated:YES];
}



- (void)time_Change:(UIButton *)btn
{
    
    switch (btn.tag) {
        case 1:
        {
            // 时间改变，更新时间线
            [self configTime_line_timeLabWithTimestamp:time_line_timeLab.text tag:1];
//             time_line_timeLab.text = [self computeDateWithTimestamp:time_line_timeLab.text tag:1];
            
        }
            break;
        case 2:
        {
            // 时间改变，更新时间线
            [self configTime_line_timeLabWithTimestamp:time_line_timeLab.text tag:2];
//            time_line_timeLab.text = [self computeDateWithTimestamp:time_line_timeLab.text tag:2];
            
            
        }
            break;
            
        default:
            break;
    }
    
}


//计算加天数后的新日期
- (NSString *)computeDateWithTimestamp:(NSString *)timestamp tag:(int)tag
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:timestamp];
    NSDate *newDate;
    if (tag == 1)
    {
        newDate = [date dateByAddingTimeInterval:-60 * 60 * 24];

    }
    else
    {
        newDate  = [date dateByAddingTimeInterval:60 * 60 * 24];

    }
    return [dateFormatter stringFromDate:newDate];
    
   
}

#pragma mark ----------------- 解析获取经纬度(好像无用) --------------------
//解析获取经纬度
- (CLLocationCoordinate2D)getLocationWithGPRMC:(NSString *)cprmc
{
    NSArray *temp_arr = [cprmc componentsSeparatedByString:@","];
    NSString *latitude_str1 = temp_arr[5];
    NSString *longitude_str1 = temp_arr[3];
    
    NSString *latitude_str2 = [latitude_str1 substringToIndex:2];
    NSString *longitude_str2 = [longitude_str1 substringToIndex:3];
    
    latitude_str1 = [latitude_str1 substringFromIndex:2];
    longitude_str1 = [longitude_str1 substringFromIndex:3];
    
    float latitude = [latitude_str2 intValue] + [latitude_str1 floatValue]/60;
    float longitude = [longitude_str2 intValue] + [longitude_str1 floatValue]/60;
    
    //1.创建经纬度结构体
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    
    return center;
}



#pragma mark ------------- 下载文件视图 ---------------------------------

- (void)addDownloadFileView:(UIView *)superView {
    
   imagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_H(superView))];
    [superView addSubview:imagesScrollView];
    
    [self labelWithFrame:CGRectMake(30 * PSDSCALE_X, 0, 340 * PSDSCALE_X, 94 * PSDSCALE_Y) inView:imagesScrollView textColor:RGBACOLOR(51, 51, 51, 1) fontSize:25 * FONTCALE_Y text:@"实时下载开关" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    UILabel *offLabel = [self labelWithFrame:CGRectMake(SCREEN_WIDTH - 300 * PSDSCALE_X, 0, 114 * PSDSCALE_X, 94 * PSDSCALE_Y) inView:imagesScrollView textColor:RGBACOLOR(51, 51, 51, 1) fontSize:25 * FONTCALE_Y text:@"关" alignment:NSTextAlignmentRight bold:NO fit:NO];
    
    UILabel *onLabel = [self labelWithFrame:CGRectMake(SCREEN_WIDTH - 54 * PSDSCALE_X, 0, 54 * PSDSCALE_X, 94 * PSDSCALE_Y) inView:imagesScrollView textColor:RGBACOLOR(51, 51, 51, 1) fontSize:25 * FONTCALE_Y text:@"开" alignment:NSTextAlignmentLeft bold:NO fit:NO];
    
    downloadSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 170 * PSDSCALE_X, 15 * PSDSCALE_Y, 100 * PSDSCALE_X, 52 * PSDSCALE_Y)];
    downloadSwitch.onTintColor = RGBSTRING(@"b11c22");
    downloadSwitch.frame = CGRectMake(VIEW_W_X(offLabel)+((VIEW_X(onLabel)-VIEW_W_X(offLabel))/2-VIEW_W(downloadSwitch)/2), 15 * PSDSCALE_Y, downloadSwitch.frame.size.width, downloadSwitch.frame.size.height);
    [downloadSwitch addTarget:self action:@selector(download_click:) forControlEvents:UIControlEventValueChanged];
    [imagesScrollView addSubview:downloadSwitch];
    
    //这里的开关状态在第一次装app要跟个人中心开关状态相同
    if ([[SettingConfig shareInstance].isDownload length])
    {
        downloadSwitch.on = [UserDefaults boolForKey:_model.macAddress];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@_autoDownloadPicture", UserName];
        NSString *bbb = [UserDefaults objectForKey:str];
        
        if ([UserDefaults objectForKey:[NSString stringWithFormat:@"%@_autoDownloadPicture", UserName]])
        {
            downloadSwitch.on = [bbb intValue];
        }
        else
        {
            downloadSwitch.on = YES;
        }
        
    }
    
    
    CGFloat margin = 5;
    CGFloat space = 3;
    CGFloat photoWidth = (SCREEN_WIDTH - 2 * (margin + space)) / 3;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = space;
    flowLayout.minimumInteritemSpacing = space;
    flowLayout.itemSize = CGSizeMake(photoWidth, photoWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(12 * PSDSCALE_Y, margin, 12 * PSDSCALE_Y, margin);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 94*PSDSCALE_Y, SCREEN_WIDTH, VIEW_H(superView)) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = self.view.backgroundColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tag = MiddleCollectViewTag;
    
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [self.collectionView addGestureRecognizer:longPressGr];
    
    [_collectionView registerClass:[CameraDetailCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [imagesScrollView addSubview:_collectionView];
      
    imagesScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, VIEW_H(superView) + 2 + 94 * PSDSCALE_Y);
    imagesScrollView.contentOffset = CGPointMake(0, 94 * PSDSCALE_Y - 2);
    
}

//长按collectionViewcell 调用
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if(indexPath == nil) return ;
        //add your code here
        _indexPath = indexPath;
        UIActionSheet *sheetView = [[UIActionSheet alloc] initWithTitle:@"此文件还将从您所有设备上的文件夹中删除." delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
        [sheetView showInView:self.view];
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            MMLog(@"删除");
            NSString *body = [[NSString alloc] init];
            __weak typeof(self) weakSelf = self;
            
            if (self.xml_pre_Array.count)
            {
                /**
                 xml_pre_Array与self.collectionDataSource的区别
                 xml_pre_Array用于存放后缀是_pre.jpg _10.jpg的数组
                 self.collectionDataSource用于存放后缀是.jpg _10.jpg的数组
                 
                 如果xml_pre_Array.count 与 self.collectionDataSource.count相同 就使用self.collectionDataSource数组 就不用再去处理图片的名称
                 如果不相同 使用xml_pre_Array 但是要处理图片后缀名称
                 */
                if (self.xml_pre_Array.count == self.collectionDataSource.count)
                {
                    NSDictionary *dic = self.collectionDataSource[_indexPath.row];
                    body = [NSString stringWithFormat:@"PHOTO/%@",VALUEFORKEY(dic, @"fileName")];
                    MMLog(@"collectionDataSource:%@",body);
                }
                else
                {
                    NSDictionary *dic = self.xml_pre_Array[_indexPath.row];
                    body = [NSString stringWithFormat:@"PHOTO/%@",VALUEFORKEY(dic, @"fileName")];
                    MMLog(@"xml_pre_Array:%@",body);
                }
            }
            else
            {
                NSDictionary *dic = self.collectionDataSource[_indexPath.row];
                body = [NSString stringWithFormat:@"PHOTO/%@",VALUEFORKEY(dic, @"fileName")];
                MMLog(@"collectionDataSource:%@",body);
            }
            MMLog(@"%@",body);
            
            body = [NSString stringWithFormat:@"PHOTO/%@",[[body componentsSeparatedByString:@"/"]lastObject]];
            NSString *temp_str = [body componentsSeparatedByString:@"/"].lastObject;
            
            if (![temp_str containsString:@"_pre"])
            {
                if ([temp_str containsString:@"_"])
                {
                    //视频缩略图
                    temp_str = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                    
                }
                else
                {
                    //图片大图
                    temp_str = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                    
                }
            }
        
            if ([[NSFileManager defaultManager] fileExistsAtPath:temp_str])//已经下载的文件
            {
                
                if (_model.is_on_line)//在线
                {
                    BOOL isdeleteVideo = [self deleteDirInCache:temp_str];
                    if (isdeleteVideo)
                    {
//                        [self addActityText:@"删除成功" deleyTime:1];
                        MMLog(@"删除成功");
                        //判断是否下载过
                        NSString *fileName = [temp_str componentsSeparatedByString:@"/"].lastObject;
                        if ([FMDBTools selectDownloadWithFile_name:fileName])
                        {
                            //修改数据的删除状态
                            if ([FMDBTools updateDowloaddelWithFile_name:fileName])
                            {
                                NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
                                if (self.xml_pre_Array.count)
                                {
                                    
                                    for (NSDictionary *dic in xml_temp_arr)
                                    {
                                        NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                        if ([temp_fileName containsString:fileName])
                                        {
                                            [self.xml_pre_Array removeObject:dic];
                                            break;
                                        }
                                    }
                                }
                                
                                if (self.collectionDataSource.count)
                                {
                                    xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                                    for (NSDictionary *dic in xml_temp_arr)
                                    {
                                        NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                        if ([temp_fileName containsString:fileName])
                                        {
                                            [self.collectionDataSource removeObject:dic];
                                            break;
                                        }
                                    }
                                }
                                [self.collectionView reloadData];
                            }
                        }
                        
                        AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                        MsgModel *requestMsg = [[MsgModel alloc] init];
                        requestMsg.cmdId = @"0A";
                        requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
                        requestMsg.msgBody = body;
                        [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
                            
                            if ([msg.msgBody isEqualToString:@"OK"])
                            {
                                [weakSelf addActityText:@"删除成功" deleyTime:1];
                                
                                if ([body containsString:@"_pre"])
                                {
                                    [weakSelf.xml_pre_Array removeObjectAtIndex:_indexPath.row];
                                    [weakSelf deleteWithbody:body tag:1];
                                }
                                else
                                {
                                    
                                    NSString *temp_str = [body componentsSeparatedByString:@"/"].lastObject;
                                    [FMDBTools updateDowloaddelWithFile_name:temp_str];
                                    NSString *filePath;
                                    if ([temp_str containsString:@"_"])
                                    {
                                        filePath = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                                        
                                    }
                                    else
                                    {
                                        filePath = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                                    }
                                    [weakSelf deleteDirInCache:filePath];
//                                    [weakSelf.collectionDataSource removeObjectAtIndex:_indexPath.row];
                                    [weakSelf deleteWithbody:body tag:0];
                                }
                            }
                            else
                            {
                                [weakSelf addActityText:@"删除失败" deleyTime:1];
                            }
                            
                        }];
                        
                    }
                    else
                    {
                        MMLog(@"删除失败");
                    }
                }
                else//不在线
                {
                    
                    BOOL isdeleteVideo = [self deleteDirInCache:temp_str];
                    if (isdeleteVideo)
                    {
                        [self addActityText:@"删除成功" deleyTime:1];
                        MMLog(@"删除成功");
                        //判断是否下载过
                        if ([FMDBTools selectDownloadWithFile_name:[temp_str componentsSeparatedByString:@"/"].lastObject])
                        {
                            //修改数据的删除状态
                            if ([FMDBTools updateDowloaddelWithFile_name:[temp_str componentsSeparatedByString:@"/"].lastObject])
                            {
                                NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
                                if (self.xml_pre_Array.count)
                                {
                                    
                                    for (NSDictionary *dic in xml_temp_arr)
                                    {
                                        NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                        if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                                        {
                                            [self.xml_pre_Array removeObject:dic];
                                            break;
                                        }
                                    }
                                }
                                
                                if (self.collectionDataSource.count)
                                {
                                    xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                                    for (NSDictionary *dic in xml_temp_arr)
                                    {
                                        NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                        if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                                        {
                                            [self.collectionDataSource removeObject:dic];
                                            break;
                                        }
                                    }
                                }
                                [self.collectionView reloadData];
                            }
                        }
                        
                    }
                    else
                    {
                        MMLog(@"删除失败");
                    }
                }
                
            }
            else//文件还没有下载的情况
            {
                AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                MsgModel *requestMsg = [[MsgModel alloc] init];
                requestMsg.cmdId = @"0A";
                requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
                requestMsg.msgBody = body;
                [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
                    
                    if ([msg.msgBody isEqualToString:@"OK"])
                    {
                        [weakSelf addActityText:@"删除成功" deleyTime:1];
                        
                        if ([body containsString:@"_pre"])
                        {
                            [weakSelf.xml_pre_Array removeObjectAtIndex:_indexPath.row];
                            [weakSelf deleteWithbody:body tag:1];
                        }
                        else
                        {
                            
                            NSString *temp_str = [body componentsSeparatedByString:@"/"].lastObject;
                            [FMDBTools updateDowloaddelWithFile_name:temp_str];
                            NSString *filePath;
                            if ([temp_str containsString:@"_"])
                            {
                                filePath = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                                
                            }
                            else
                            {
                                filePath = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                            }
                            [weakSelf deleteDirInCache:filePath];
                            [weakSelf.collectionDataSource removeObjectAtIndex:_indexPath.row];
                            [weakSelf deleteWithbody:body tag:0];
                        }
                    }
                    else
                    {
                        [weakSelf addActityText:@"删除失败" deleyTime:1];
                    }
                    
                }];

            }

        }
            break;
            
        default:
            break;
    }
}



- (void)deleteWithbody:(NSString *)body tag:(int)tag
{
    
    NSString *temp_body = [[NSString alloc] init];
    if (tag)//self.collectionDataSource
    {
        if (![body containsString:@"_pre"])
        {
            body = [body componentsSeparatedByString:@"/"].lastObject;
            for (NSDictionary *dic in self.collectionDataSource)
            {
                NSString *fileName = VALUEFORKEY(dic, @"fileName");
                if ([body isEqualToString:fileName])
                {
                    [self.collectionDataSource removeObject:dic];
                    [FMDBTools updateDowloaddelWithFile_name:fileName];
                    break;
                }
            }
            body = [body componentsSeparatedByString:@"."][0];
            temp_body = [NSString stringWithFormat:@"tmp/%@.mp4",body];
            
            NSString *filePath = [Video_Path(_model.macAddress) stringByAppendingPathComponent:[temp_body componentsSeparatedByString:@"/"].lastObject];
            [self deleteDirInCache:filePath];
            
        }
        else//删除图片缩略图
        {
            body = [body componentsSeparatedByString:@"_pre"][0];
            body = [NSString stringWithFormat:@"%@.jpg",body];
            for (NSDictionary *dic in self.collectionDataSource)
            {
                NSString *fileName = VALUEFORKEY(dic, @"fileName");
                if ([body isEqualToString:[NSString stringWithFormat:@"PHOTO/%@",fileName]])
                {
                    temp_body = [NSString stringWithFormat:@"PHOTO/%@",fileName];
                    [self.collectionDataSource removeObject:dic];
                    NSString *filePath = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:[temp_body componentsSeparatedByString:@"/"].lastObject];
                    [self deleteDirInCache:filePath];
                    [FMDBTools updateDowloaddelWithFile_name:fileName];
                    break;
                }
                
                
            }
            
//            temp_body = [temp_body stringByReplacingOccurrencesOfString:@".jpg" withString:@"_pre.jpg"];
        }
    }
    else//删除咔咔设备和手机 上视频和图片的缩略图 self.xml_pre_Array
    {
        if ([body containsString:@"_"])
        {
            body = [body componentsSeparatedByString:@"/"].lastObject;
            
            for (NSDictionary *dic in self.xml_pre_Array)
            {
                NSString *fileName = VALUEFORKEY(dic, @"fileName");
                if ([body isEqualToString:fileName])
                {
                    [self.xml_pre_Array removeObject:dic];
                    [FMDBTools updateDowloaddelWithFile_name:fileName];
                    break;
                }
            }
            
            body = [body componentsSeparatedByString:@"."][0];
            temp_body = [NSString stringWithFormat:@"tmp/%@.mp4",body];
            NSString *filePath = [Video_Path(_model.macAddress) stringByAppendingPathComponent:[temp_body componentsSeparatedByString:@"/"].lastObject];
            [self deleteDirInCache:filePath];
            
        }
        else
        {
            body = [body componentsSeparatedByString:@"."][0];
            body = [NSString stringWithFormat:@"%@_pre.jpg",body];
            for (NSDictionary *dic in self.xml_pre_Array)
            {
                NSString *fileName = VALUEFORKEY(dic, @"fileName");
                if ([body isEqualToString:[NSString stringWithFormat:@"PHOTO/%@",fileName]])
                {
                    
                    temp_body = [NSString stringWithFormat:@"PHOTO/%@",fileName];
                    [self.xml_pre_Array removeObject:dic];
//                    [FMDBTools updateDowloaddelWithFile_name:fileName];
                    break;
                }
                else
                {
                    temp_body = nil;
                }
                
                
            }
            
        }
    }
    if (temp_body.length == 0)
    {
        return;
    }
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"0A";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
    requestMsg.msgBody = temp_body;
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
        
        
    }];
    
    [self.collectionView reloadData];
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


#pragma mark --------------------- 点击下载开关 --------------------

//下载开关
- (void)download_click:(UISwitch *)sender
{
    [SettingConfig shareInstance].isDownload = @"isDownload";
    [UserDefaults setBool:sender.on forKey:_model.macAddress];
    [UserDefaults synchronize];
    
    if (sender.on)
    {
        
        if (self.collectionDataSource.count)
        {
            //判断文件是否已存在 不存在才下载
            [self.download_arr removeAllObjects];
            __weak typeof(self) weakSelf = self;
            [self.collectionDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    NSString *file_name = VALUEFORKEY((NSDictionary *)obj, @"fileName");
                    NSString *file_Path = [[NSString alloc] init];
                    //查看文件名是否为已下载,如果没有下载就放到下载数组里等待下载
                    if (![[(NSDictionary *)obj allKeys] containsObject:@"local"]) {
                        
                        if ([file_name containsString:@"_pre"]||![file_name containsString:@"_"])
                        {
                            file_Path = [Photo_Path(weakSelf.model.macAddress) stringByAppendingPathComponent:file_name];
                        }
                        else
                        {
                            
                            file_Path = [Video_Photo_Path(weakSelf.model.macAddress) stringByAppendingPathComponent:file_name];
                        }
                        
                        
                        //不存在就放入下载数组下载
                        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path]) {
                            
                            [weakSelf.download_arr addObject:file_name];
                        }
                    }
                    
                    
                }
            }];
            //数组去除重复数据
            self.download_arr = [[self setWithArray:self.download_arr] mutableCopy];
            if (self.download_arr.count !=0)
            {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                    [self downloadWithURLTag:0];
//                });
            }

            
        }
        else
        {
            [self getPhotoAndVideoWithisPhoto:NO isVideo:NO];
        }
    }
}


#pragma mark --------------------- 地图视图 ------------------------------

/**
 添加地图

 @param superView 父视图
 */
- (void)addMapViewWithSuperView:(UIView *)superView
{
        CGFloat margin = 5;
        CGFloat space = 3;
        CGFloat photoWidth = (SCREEN_WIDTH - 2 * (margin + space)) / 3;
        
        //    UIView *cycleVideoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - VIEW_H_Y(_menuLine) - NAVIGATIONBARHEIGHT)];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = space;
        flowLayout.minimumInteritemSpacing = space;
        flowLayout.itemSize = CGSizeMake(photoWidth, photoWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(12 * PSDSCALE_Y, margin, 12 * PSDSCALE_Y, margin);
        
        _cyclevideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_H(superView)) collectionViewLayout:flowLayout];
        _cyclevideoCollectionView.backgroundColor = self.view.backgroundColor;
        _cyclevideoCollectionView.dataSource = self;
        _cyclevideoCollectionView.delegate = self;
        _cyclevideoCollectionView.tag = rightCollectViewTag;
        _cyclevideoCollectionView.bounces = NO;
        
        [_cyclevideoCollectionView registerClass:[CameraDetailCycleVideoCollectionViewCell class] forCellWithReuseIdentifier:@"CameraDetailCycleVideoCollectionViewCell"];
        //    [imagesScrollView addSubview:_collectionView];
        
        [superView addSubview:_cyclevideoCollectionView];
    
    
    
    //设置地图
//    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - VIEW_H_Y(_menuLine) - NAVIGATIONBARHEIGHT)];
//    _mapView.showsUserLocation = YES;
//    _mapView.rotateEnabled = YES;
//    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
//    [superView addSubview: _mapView];
    
//    if ([UserDefaults objectForKey:[NSString stringWithFormat:@"%@_displayDashboard", UserName]]) {
//        // 是否显示仪表盘
//        BOOL isShowDashboard = [UserDefaults boolForKey:[NSString stringWithFormat:@"%@_displayDashboard", UserName]];
//        if (isShowDashboard) {
//            [self addDashboard];
//        }
//    } else {
//        [self addDashboard];
//    }
//
//    if (!self.model.is_on_line) {
//        // 摄像头不在线加载定位服务，因为如果摄像头在线加载的话socket会断掉
//        _locationService = [[BMKLocationService alloc] init];
//        _locationService.delegate = self;
//        
//        [self startLocation];
//    }
    
}

// 添加仪表盘
- (void)addDashboard {
    // 坐标转盘
//    circleLeft = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_map_leftCircle.png")];
//    circleLeft.frame = CGRectMake(10, VIEW_H(_mapView) - 10 - circleLeft.size.height, circleLeft.size.width, circleLeft.size.height);
//    [_mapView addSubview:circleLeft];
//    
//    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 41, 16)];
//    speedLabel.text = @"0";
//    speedLabel.font = [UIFont systemFontOfSize:40 * FONTCALE_Y];
//    speedLabel.center = CGPointMake(VIEW_W(circleLeft) / 2, VIEW_H(circleLeft) / 2);
//    speedLabel.textAlignment = NSTextAlignmentCenter;
//    [circleLeft addSubview:speedLabel];
//    
//    // 指针
//    UIImage *needleImage = GETNCIMAGE(@"camera_map_circleShot.png");
//    leftNeedle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 49)];
//    leftNeedle.image = needleImage;
//    leftNeedle.contentMode = UIViewContentModeScaleAspectFit;
//    leftNeedle.layer.anchorPoint = CGPointMake(0.47, 1);
//    leftNeedle.center = CGPointMake(circleLeft.frame.size.width / 2, circleLeft.frame.size.height / 2);
//    [circleLeft addSubview:leftNeedle];
//    
//    [self makeTransformWithSpeed:0 isLeftNeedle:YES];
    
    //    UIImageView *circleRight = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_map_rightCircle.png")];
    //    circleRight.frame = CGRectMake(SCREEN_WIDTH - 10 - circleRight.size.width, VIEW_H(_mapView) - 10 - circleRight.size.height, circleRight.size.width, circleRight.size.height);
    //    [_mapView addSubview:circleRight];
    //
    //    rightNeedle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 49)];
    //    rightNeedle.image = needleImage;
    //    rightNeedle.contentMode = UIViewContentModeScaleAspectFit;
    //    rightNeedle.layer.anchorPoint = CGPointMake(0.47, 1);
    //    rightNeedle.center = CGPointMake(circleRight.frame.size.width / 2, circleRight.frame.size.height / 2);
    //    [circleRight addSubview:rightNeedle];
    //
    //    [self makeTransformWithSpeed:0 isLeftNeedle:NO];
}

#pragma mark - 定位
//- (void)startLocation{
//    
//    _locationService.distanceFilter = 1;
//    //初始化BMKLocationService
//    [_locationService startUserLocationService];
//}
//
//- (void)makeTransformWithSpeed:(double)speed isLeftNeedle:(BOOL)isLeftNeedle{
//    
//    if (isLeftNeedle) {
//        // 左边
//        speedLabel.text = [NSString stringWithFormat:@"%.0f", speed];
//        
//        if (speed > 120) {
//            leftNeedle.layer.transform = CATransform3DMakeRotation(2*M_PI/16*(speed/20.0-6), 0, 0, 1);
//        } else {
//            leftNeedle.layer.transform = CATransform3DMakeRotation(-2*M_PI/16*(6-speed/20.0), 0, 0, 1);
//        }
//    } else {
//        // 右边
//        if (speed > 40) {
//            rightNeedle.layer.transform = CATransform3DMakeRotation(2*M_PI/10*(speed/10.0-4), 0, 0, 1);
//        } else {
//            rightNeedle.layer.transform = CATransform3DMakeRotation(-2*M_PI/10*(4-speed/10.0), 0, 0, 1);
//        }
//    }
//    
//}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
//- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
//    
//    if (circleLeft) {
//        CLLocationSpeed speed = userLocation.location.speed;
//        if (speed < 0) {
//            [self makeTransformWithSpeed:0 isLeftNeedle:YES];
//        } else {
//            [self makeTransformWithSpeed:speed * 3600 / 1000 isLeftNeedle:YES];
//        }
//    }
//    
//    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
//    param.locationViewOffsetX = 0;
//    param.locationViewOffsetY = 0;
//    param.isRotateAngleValid = YES;
//    param.isAccuracyCircleShow = YES;
////    param.locationViewImgName = @"map_userLocation_icon";
//    [_mapView updateLocationViewWithParam:param];
//    [_mapView updateLocationData:userLocation];
//}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    
}

#pragma mark -------------- 点击直播视图的按钮菜单 ----------------------------
- (void)videoMenu_button_clicked_action:(UIButton *)sender {
    
    if (isShowSettingButton) {
        
        // 设置
        switch (sender.tag - 1) {
            case 0:// 设置
            {
                if (!_model.is_on_line)
                {
                    [self addActityText:@"未登录摄像头" deleyTime:1];
                    return;
                }
                else
                {
                    
                    CameraSettingViewController *cameraSettingVC = [[CameraSettingViewController alloc] init];
                    cameraSettingVC.superVC = self;
                    __weak typeof(self) weakSelf = self;
                    cameraSettingVC.block =^(NSString *text){
                        
                        UIButton *temp_btn = (UIButton *)[weakSelf.videoNormalMenuBg.subviews objectAtIndex:1];
                        if ([text intValue] == 0)
                        {
                            temp_btn.selected = YES;
                            
                        }
                        else
                        {
                            temp_btn.selected = NO;
                        }
                        
                    };
                    [weakSelf.navigationController pushViewController:cameraSettingVC animated:YES];
                }
            }
                break;
            case 1:// 录音
            {
                if (!_model.is_on_line)
                {
                    [self addActityText:@"未登录摄像头" deleyTime:1];
                    return;
                }
                else
                {
                    sender.selected = !sender.isSelected;
                    
                    
                    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                    MsgModel *msg = [[MsgModel alloc] init];
                    msg.cmdId = @"0E";
                    msg.token = [SettingConfig shareInstance].deviceLoginToken;
                    
                    if (sender.selected)
                    {
                        msg.msgBody = @"cdrSystemCfg.volumeRecordingSensitivity=\"0\"";
                        
                    }
                    else
                    {
                        msg.msgBody = @"cdrSystemCfg.volumeRecordingSensitivity=\"2\"";
                    }
                    
                    
                    
                    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                        
                        MMLog(@"aaa");
                        
                    }];
                }
                
            }
                break;
            case 2:// 拍照
            {
                if (!_model.is_on_line)
                {
                    [self addActityText:@"未登录摄像头" deleyTime:1];
                    return;
                }
                else
                {
                    
                    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                    MsgModel *msg = [[MsgModel alloc] init];
                    msg.cmdId = @"07";
                    msg.token = [SettingConfig shareInstance].deviceLoginToken;
                    __weak typeof(self) weakSelf = self;
                    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                        
                        if ([msg.msgBody hasSuffix:@".jpg"])
                        {
                            [weakSelf addActityText:@"拍照成功" deleyTime:1];
//                            if (![SettingConfig shareInstance].isPhotoWithVideo)
//                            {
                            
                                [weakSelf getPhotoAndVideoWithisPhoto:YES isVideo:NO];
//                            }
                            
                        }
                        
                        // 刷新时间线
                        [weakSelf requestTodayTime_lineData];
                        
                    }];
                }
                
            }
                break;
            case 3://游记
            {
                if (!_model.is_on_line)
                {
                    [self addActityText:@"未登录摄像头" deleyTime:1];
                    return;
                }
                // 游记
                sender.selected = !sender.selected;
                // 另一个游记按钮
                UIButton *otherTravelBtn = [_videoSelMenuBg viewWithTag:2];
                otherTravelBtn.selected = sender.selected;
                
                NSMutableArray *uncompleteTravelsArray = [CacheTool queryTravelsUncompleteWithCameraMac:self.model.macAddress userName:UserName];
                if (uncompleteTravelsArray.count) {
                    // 有未补全的游记 只是提示，当不做记录，防止游记重复
                    if (sender.selected) {
                        [self addActityText:@" 游记开始" deleyTime:1];
                        [UserDefaults setObject:@(1) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                    } else {
                        [self addActityText:@" 游记结束" deleyTime:1];
                        [UserDefaults setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                    }
                    
                    return;
                }
                
                // 没有未补全的游记，往数据库添加记录
                if (sender.selected) {
                    // 开始游记
                    [self requestTime_lineDataWithFlag:1];
                    [self addActityText:@" 游记开始" deleyTime:1];
                    [UserDefaults setObject:@(1) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                } else {
                    // 结束游记
                    [self requestTime_lineDataWithFlag:2];
                    [self addActityText:@" 游记结束" deleyTime:1];
                    [UserDefaults setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                }
                
                
            }
                break;
            case 4:// 全屏
            {
                
                if (!self.videoPlayer) {
                    [self addActityText:@"未登录摄像头" deleyTime:1];
                    return;
                }
                // 将屏幕旋转
                [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
            }
                break;
                
            default:
                break;
        }

    } else {
        if (!_model.is_on_line)
        {
            [self addActityText:@"未登录摄像头" deleyTime:1];
            return;
        }
        
        if (sender.tag == 2) {
            // 游记中
            sender.selected = !sender.selected;
            // 另一个游记按钮
            UIButton *otherTravelBtn = [_videoNormalMenuBg viewWithTag:4];
            otherTravelBtn.selected = sender.selected;
            
            NSMutableArray *uncompleteTravelsArray = [CacheTool queryTravelsUncompleteWithCameraMac:self.model.macAddress userName:UserName];
            if (uncompleteTravelsArray.count) {
                // // 有未补全的游记 只是提示，当不做记录，防止游记重复
                if (sender.selected) {
                    [self addActityText:@" 游记开始" deleyTime:1];
                    [UserDefaults setObject:@(1) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                } else {
                    [self addActityText:@" 游记结束" deleyTime:1];
                    [UserDefaults setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
                }
                
                return;
            }
            
            // 没有未补全的游记，往数据库添加记录
            if (sender.selected) {
                // 开始游记
                [self requestTime_lineDataWithFlag:1];
                [self addActityText:@" 游记开始" deleyTime:1];
                [UserDefaults setObject:@(1) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
            } else {
                // 结束游记
                [self addActityText:@" 游记结束" deleyTime:1];
                [self requestTime_lineDataWithFlag:2];
                [UserDefaults setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@_traveling", UserName, self.model.macAddress]];
            }
            
        }
        else
        {
            // 拍照
            AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
            MsgModel *msg = [[MsgModel alloc] init];
            msg.cmdId = @"07";
            msg.token = [SettingConfig shareInstance].deviceLoginToken;
            __weak typeof(self) weakSelf = self;
            [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                
                if ([msg.msgBody hasSuffix:@".jpg"])
                {
                    [self addActityText:@"拍照成功" deleyTime:1];
                    
//                    if (![SettingConfig shareInstance].isPhotoWithVideo)
//                    {
                        [weakSelf getPhotoAndVideoWithisPhoto:YES isVideo:NO];
//                    }
                    
                    
                    
                }
                
                // 刷新时间线
                [weakSelf requestTodayTime_lineData];
                
            }];
        }
    }
}

- (void)tapVideoView_action:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:_videoBgImageView];
    
    if (CGRectContainsPoint(_videoNormalMenuBg.frame, point) || CGRectContainsPoint(_videoSelMenuBg.frame, point)) {
        return;
    }
    
    isShowSettingButton = !isShowSettingButton;
    
    if (isShowSettingButton) {
        // 显示有设置这一排按钮
        _videoSelMenuBg.hidden = YES;
        _videoNormalMenuBg.hidden = NO;
    } else {
        // 显示游记中这一排按钮
        _videoSelMenuBg.hidden = NO;
        _videoNormalMenuBg.hidden = YES;
    }
}

#pragma mark ---------------- 点击(时间线,下载文件等)按钮事件 ---------------

- (void)menuBtn_clicked_action:(UIButton *)sender {
    
    _selectedMenuBtn.enabled = YES;
    sender.enabled = NO;
    _selectedMenuBtn = sender;
    
    CGFloat lineLeft = 0.0;
    switch (sender.tag - 1) {
        case 0:
        {
            // 时间线
            lineLeft = 0.0;
        }
            break;
        case 2:
        {
            // 循环视频
            lineLeft = SCREEN_WIDTH / 3 * 2;
            //获取数据
            if (self.model.is_on_line)//是否在线
            {
                if (!self.cycleVideoArray.count) {
                    
                    [self getCycleVideoData];
                }
            }
            
        }
            break;
        case 1:
        {
            // 下载文件
            lineLeft = SCREEN_WIDTH / 3;
            if (!self.collectionDataSource.count)
            {
                //是否在线
                if (self.model.is_on_line)
                {
                    [self getPhotoAndVideoWithisPhoto:NO isVideo:NO];
                }
                else
                {
                    NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                    if (pathArr.count)
                    {
                        for (int i = 0; i < pathArr.count; i ++)
                        {
                            NSString *filePath = [pathArr objectAtIndex:i];
                            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                            [dic setValue:filePath forKey:@"fileName"];
                            [dic setValue:@"local" forKey:@"local"];
                            if (![filePath containsString:@"Retouching"])
                            {
                                [self.collectionDataSource addObject:dic];
                              
                            }
                        }
                        
                        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                        if (pathArr.count)
                        {
                            for (int i = 0; i < pathArr.count; i ++)
                            {
                                NSString *filePath = [pathArr objectAtIndex:i];
                                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                                [dic setValue:filePath forKey:@"fileName"];
                                [dic setValue:@"local" forKey:@"local"];
                                [self.collectionDataSource addObject:dic];
                            }
                        }
                        
                        [self.collectionView reloadData];
                    }
                    else
                    {
                        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                        if (pathArr.count)
                        {
                            for (int i = 0; i < pathArr.count; i ++)
                            {
                                NSString *filePath = [pathArr objectAtIndex:i];
                                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                                [dic setValue:filePath forKey:@"fileName"];
                                [dic setValue:@"local" forKey:@"local"];
                                [self.collectionDataSource addObject:dic];
                            }
                            [self.collectionView reloadData];
                        }
                        
                    }
                    
                }
            }
            
        }
            break;
        default:
            break;
    }
    
    // 移动线条
    [UIView animateWithDuration:0.3 animations:^{
        
        [_menuLine mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(lineLeft);
            
        }];
        
        [_menuLine.superview layoutIfNeeded];
        
    }];
    
    CGPoint contentOffset;
    contentOffset.x = (sender.tag - 1) * SCREEN_WIDTH;
    [_bgScrollView setContentOffset:contentOffset animated:YES];
    
}

#pragma mark - Time_lineDelegate

- (void)showBIgImageWithCell:(CameraDetailViewControllerTableViewCell3 *)cell
{
    [MyTools showImage:cell.detailImage];
}


#pragma  mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CameraTime_lineModel *model = dataSource[indexPath.row];
    MMLog(@"%@",model.type);
    if (tableView == self.tableView1)
    {
        if ([model.type isEqualToString:@"P"])
        {
            CameraDetailViewControllerTableViewCell *cell = [CameraDetailViewControllerTableViewCell cellWithTableView:tableView];
            return cell;
        }
        else if ([model.type isEqualToString:@"Start CDR"])
        {
            CameraDetailViewControllerTableViewCell2 *cell = [CameraDetailViewControllerTableViewCell2 cellWithTableView:tableView];
            
            return cell;
        }
        else if ([model.type isEqualToString:@"Photo"])
        {
            CameraDetailViewControllerTableViewCell3 *cell = [CameraDetailViewControllerTableViewCell3 cellWithTableView:tableView];
            
            return cell;
        }
        else if ([model.type isEqualToString:@"GPhoto"])
        {
            CameraDetailViewControllerTableViewCell3 *cell = [CameraDetailViewControllerTableViewCell3 cellWithTableView:tableView];
            
            return cell;
        }
        else
        {
            CameraDetailViewControllerTableViewCell4 *cell = [CameraDetailViewControllerTableViewCell4 cellWithTableView:tableView];
            
            return cell;
        }
        
    }
    else if (tableView == self.tableView2)
    {
        if ([model.type isEqualToString:@"P"])
        {
            // 停车，显示p
            CameraDetailViewControllerTableViewCell *cell = [CameraDetailViewControllerTableViewCell cellWithTableView:tableView];
            [cell refreshData:model];
            return cell;
        }
        else if ([model.type isEqualToString:@"Start CDR"])
        {
            // 开始
            CameraDetailViewControllerTableViewCell2 *cell = [CameraDetailViewControllerTableViewCell2 cellWithTableView:tableView];
            [cell refreshData:model dataSource:dataSource indexPath:indexPath];
            return cell;
        }
        else if ([model.type isEqualToString:@"Photo"]||[model.type isEqualToString:@"GPhoto"])
        {
            // 时间，拍照等
            CameraDetailViewControllerTableViewCell3 *cell = [CameraDetailViewControllerTableViewCell3 cellWithTableView:tableView];
            cell.delegate = self;
            [cell refreshData:model];
            
            return cell;
        }
        else
        {
            // 其他
            CameraDetailViewControllerTableViewCell4 *cell = [CameraDetailViewControllerTableViewCell4 cellWithTableView:tableView];
            [cell refreshData:model dataSource:dataSource indexPath:indexPath];
            return cell;
        }
    }
    else
    {
        if ([model.type isEqualToString:@"P"])
        {
            CameraDetailViewControllerTableViewCell *cell = [CameraDetailViewControllerTableViewCell cellWithTableView:tableView];
            return cell;
        }
        else if ([model.type isEqualToString:@"Start CDR"])
        {
            CameraDetailViewControllerTableViewCell2 *cell = [CameraDetailViewControllerTableViewCell2 cellWithTableView:tableView];
            
            return cell;
        }
        else if ([model.type isEqualToString:@"Photo"]||[model.type isEqualToString:@"GPhoto"])
        {
            CameraDetailViewControllerTableViewCell3 *cell = [CameraDetailViewControllerTableViewCell3 cellWithTableView:tableView];
            
            return cell;
        }
        else
        {
            CameraDetailViewControllerTableViewCell4 *cell = [CameraDetailViewControllerTableViewCell4 cellWithTableView:tableView];
            
            return cell;
        }
    }
    
}

#pragma mark -UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CameraTime_lineModel *model = dataSource[indexPath.row];
    if ([model.type isEqualToString:@"P"])
    {
        return 82*PSDSCALE_Y;
    }
    else if ([model.type isEqualToString:@"Start CDR"])
    {
        return 130*PSDSCALE_Y;
    }
    else if ([model.type isEqualToString:@"Photo"]||[model.type isEqualToString:@"GPhoto"])
    {
        return 218*PSDSCALE_Y;
    }
    else
    {
        return 115*PSDSCALE_Y;
    }
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (self.xml_pre_Array.count) {
//        [self.xml_pre_Array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSDictionary *dic = (NSDictionary *)obj;
//            NSString *fileName = VALUEFORKEY(dic, @"fileName");
//            if ([fileName hasSuffix:@".MP4"]) {
//                [self.xml_pre_Array removeObjectAtIndex:idx];
//            }
//            ZYLog(@"fileName = %@",fileName);
//        }];
//    }
//    if (self.collectionDataSource.count) {
//        [self.collectionDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSDictionary *dic = (NSDictionary *)obj;
//            NSString *fileName = VALUEFORKEY(dic, @"fileName");
//            if ([fileName hasSuffix:@".MP4"]) {
//                [self.collectionDataSource removeObjectAtIndex:idx];
//                
//            }
//             ZYLog(@"fileName = %@",fileName);
//        }];
//
//    }
    
    if (collectionView.tag == MiddleCollectViewTag) {//下载文件
        
        if (self.model.is_on_line)
        {
        
            if (self.xml_pre_Array.count == self.collectionDataSource.count)
            {
                return self.collectionDataSource.count;
            }
            else
            {
                return self.xml_pre_Array.count;
            }
        }
        else
        {
            return self.collectionDataSource.count;
        }
    }else//循环视频
    {
        return self.cycleVideoArray.count;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (collectionView.tag == MiddleCollectViewTag) {//下载文件
        static NSString *kidentifier = @"Cell";
        
        CameraDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kidentifier forIndexPath:indexPath];
        if (self.xml_pre_Array.count)
        {
            if (self.xml_pre_Array.count == self.collectionDataSource.count)
            {
                [cell refreshDataWith:self.collectionDataSource[indexPath.row] macAddress:_model.macAddress BSSID:_BSSID];
            }
            else
            {
                [cell refreshDataWith:self.xml_pre_Array[indexPath.row] macAddress:_model.macAddress BSSID:_BSSID];
            }
        }
        else
        {
            [cell refreshDataWith:self.collectionDataSource[indexPath.row] macAddress:_model.macAddress BSSID:_BSSID];
        }
        return cell;
        
    }else//循环视频
    {
        static NSString *kidentifier1 = @"CameraDetailCycleVideoCollectionViewCell";
        CameraDetailCycleVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kidentifier1 forIndexPath:indexPath];
        if (self.cycleVideoArray.count) {
            [cell refreshCycleVideoDataWith:self.cycleVideoArray[indexPath.row] macAddress:_model.macAddress];
            
        }
        return cell;
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (collectionView.tag == rightCollectViewTag) {//循环视频
        /**
         1.下载完成与未下载的要区分
         2.点击 下载完成 与 正在下载 , 未下载 的要区分
         3.按顺序下载,一个接一个的下载
         
         */
        CameraDetailCycleVideoCollectionViewCell *cell =(CameraDetailCycleVideoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSDictionary *dic = self.cycleVideoArray[indexPath.row];
        NSString *fileName = VALUEFORKEY(dic, @"fileName");
        NSString *file_Path = [[NSString alloc] init];
        file_Path = [CycleVideo_Path(_model.macAddress) stringByAppendingPathComponent:fileName];
        //判断是否下载过
        if ([[NSFileManager defaultManager] fileExistsAtPath:file_Path])
        {
            
            NSArray *pathArr =[MyTools getAllDataWithPath:CycleVideo_Path(_model.macAddress) mac_adr:_model.macAddress];
            
            
//            NSArray *imagePathArr =[MyTools getAllDataWithPath:Video_Photo_Path(nil) mac_adr:nil];
            NSString *image_fileName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
            image_fileName = [image_fileName stringByAppendingString:@".jpg"];
            image_fileName = [CyclePhoto_Path(_model.macAddress) stringByAppendingPathComponent:image_fileName];
        

            for (NSString *str in pathArr)
            {
                
                if ([str containsString:fileName])
                {
                    fileName = str;
                    break;
                }
            }
            
            ZYLog(@"已经下载过了-------%@",fileName);
            
            NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
            MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
            playVC.videoURL = sourceMovieURL;
            
            
            
            playVC.imageURL = image_fileName;
//            NSString *image_fileName = VALUEFORKEY(dic, @"fileName");
//            if ([image_fileName containsString:@"/"]) {
//                
//                playVC.imageURL = image_fileName;
//            }
//            else
//            {
//                playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];
//            }
//            __weak typeof(self) weakSelf = self;
//            playVC.block =^{
//                
//                [weakSelf getCacheData];
//            };
            [self.navigationController pushViewController:playVC animated:YES];
            
            
            
            
            
        }else
        {
            if ([self.currentDownloadingFileName isEqualToString:fileName]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ZYLog(@"正在下载中----------------------------------------");
                });
            }else//点击未下载的视频
            {
                //手机存储小于500MB时
                if (![self Reserved])
                {
                    [self addActityText:@"手机存储小于500MB,请清理手机存储空间" deleyTime:1.0];
                    
                    return;
                }
                
                
                for (NSString *waitFileName in self.downloadCycleVideoArray
                     ) {
                    if ([waitFileName isEqualToString:fileName]) {//过滤数组相同的文件名
                        ZYLog(@"重复点击等待下载的视频--------%zd",self.downloadCycleVideoArray.count);
                        
                        return ;
                    }
                }
                [self.downloadCycleVideoArray addObject:fileName];//存放要下载文件名
                
                self.currentDownloadingFileName = self.downloadCycleVideoArray[self.downTag];//先下载第一个
                if ([self.currentDownloadingFileName isEqualToString:fileName]) {//先下载完当前的视频再接着下载数组下一个视频文件

                    //下载视频
                    [self downloadCycleVideo:collectionView cell:cell indexPath:indexPath];
                    

                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        ZYLog(@"下个视频等待下载---------------------------");
                        NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        mutDic[@"rate"] = @"等待下载";
//                        mutDic[@"row"] = [NSString stringWithFormat:@"%zd",indexPath.row];
                        [self.cycleVideoArray replaceObjectAtIndex:indexPath.row withObject:mutDic];
                        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    });
                }
            }
        }
    }
    else{//下载文件
    
        _indexPath = indexPath;
        if (_model.is_on_line)//在线
        {
            if (!downloadSwitch.on)//没开自动下载
            {
                if (self.xml_pre_Array.count)
                {
                    
                    if (self.xml_pre_Array.count == self.collectionDataSource.count)
                    {
                        NSDictionary *dic = self.collectionDataSource[indexPath.row];
                        NSString *fileName = VALUEFORKEY(dic, @"fileName");
                        [self clickDownloadFileWithFileName:fileName];
                        
                    }
                    else
                    {
                        NSDictionary *dic = self.xml_pre_Array[indexPath.row];
                        NSString *fileName = VALUEFORKEY(dic, @"fileName");
                        [self clickDownloadFileWithFileName:fileName];
                    }
                }
                else
                {
                    NSDictionary *dic = self.collectionDataSource[indexPath.row];
                    NSString *fileName = VALUEFORKEY(dic, @"fileName");
                    [self clickDownloadFileWithFileName:fileName];
                }
            }
            else//开启自动下载
            {
                
                NSDictionary *dic = [[NSDictionary alloc] init];
                
                if (self.xml_pre_Array.count)
                {
                    if (self.xml_pre_Array.count == self.collectionDataSource.count)
                    {
                        dic = self.collectionDataSource[indexPath.row];
                        
                        
                    }
                    else
                    {
                        dic = self.xml_pre_Array[indexPath.row];
                    }
                }
                else
                {
                    dic = self.collectionDataSource[indexPath.row];
                    
                }
                
                NSString *fileName = VALUEFORKEY(dic, @"fileName");
                NSString *temp_fileName ;
                //获取图片名
                if ([fileName containsString:@"/"])
                {
                    temp_fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                }
                else
                {
                    temp_fileName = fileName;
                }
                //下载图片缩略图或大图
                if ([temp_fileName containsString:@"_pre"]||![temp_fileName containsString:@"_"])
                {
                    
                    //判断是否下载过
                    if (![FMDBTools selectDownloadWithFile_name:temp_fileName])
                    {
                        //点击下载图片
                        [self clickDownloadFileWithFileName:temp_fileName];
                        
                    }
                    else
                    {
                        [self pushPhotoBrowserWith:fileName];
                    }
                }
                else
                {
                    
                    //判断是否下载过
                    if (![FMDBTools selectDownloadWithFile_name:temp_fileName])
                    {
                        [self clickDownloadFileWithFileName:temp_fileName];
                    }
                    else//已下载
                    {
                        fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                        fileName = [fileName componentsSeparatedByString:@"_"][0];
                        NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(_model.macAddress) mac_adr:_model.macAddress];
                        
                        for (NSString *str in pathArr)
                        {
                            
                            if ([str containsString:fileName])
                            {
                                fileName = str;
                                break;
                            }
                        }
                        
                        if (![fileName hasSuffix:@".mp4"])
                        {
                            [self addActityText:@"视频正在下载..." deleyTime:1.0];
                            return;
                        }
                        NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
                        MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
                        playVC.videoURL = sourceMovieURL;
                        NSString *image_fileName = VALUEFORKEY(dic, @"fileName");
                        if ([image_fileName containsString:@"/"]) {
                            
                            playVC.imageURL = image_fileName;
                        }
                        else
                        {
                            playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];
                        }
                        __weak typeof(self) weakSelf = self;
                        playVC.block =^{
                            
                            [weakSelf getCacheData];
                        };
                        [self.navigationController pushViewController:playVC animated:YES];
                    }
                    
                }
                
                
            }
            
        }
        else//不在线
        {
            
            
            NSDictionary *dic = self.collectionDataSource[indexPath.row];
            NSString *fileName = VALUEFORKEY(dic, @"fileName");
            
            NSString *temp_fileName ;
            if ([fileName containsString:@"/"]) {
                temp_fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
            }
            else
            {
                temp_fileName = fileName;
            }
            if ([temp_fileName containsString:@"_pre"]||![temp_fileName containsString:@"_"])
            {
                [self pushPhotoBrowserWith:fileName];
            }
            else
            {
                fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                fileName = [fileName componentsSeparatedByString:@"_"][0];
                NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(_model.macAddress) mac_adr:_model.macAddress];
                
                for (NSString *str in pathArr)
                {
                    
                    if ([str containsString:fileName])
                    {
                        fileName = str;
                        break;
                    }
                }
                NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
                MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
                playVC.videoURL = sourceMovieURL;
                
                NSString *image_fileName = VALUEFORKEY(dic, @"fileName");
                if ([image_fileName containsString:@"/"]) {
                    
                    playVC.imageURL = image_fileName;
                }
                else
                {
                    playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];
                }
                __weak typeof(self) weakSelf = self;
                playVC.block =^{
                    
                    [weakSelf getCacheData];
                };
                [self.navigationController pushViewController:playVC animated:YES];
            }
            
            
        }
    }
    
    
    
}


- (void)pushPhotoBrowserWith:(NSString *)name
{
    NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(_model.macAddress) mac_adr:_model.macAddress];
    NSMutableArray *image_arr = [NSMutableArray array];
    NSMutableArray *albums_arr = [NSMutableArray array];
    LHPhotoBrowser *bc = [[LHPhotoBrowser alloc] init];
    NSString *fileName = name;
    if ([fileName containsString:@"_pre"])//如果是图片缩略图
    {
        fileName = [fileName componentsSeparatedByString:@"_pre"][0];//获取图片名
        for (int i = 0; i < pathArr.count; i ++)
        {
            NSString *path = pathArr[i];
            if ([path containsString:fileName])
            {
                bc.tapImgIndex = i;
            }
        }
    }
    else
    {
        fileName = [fileName componentsSeparatedByString:@"."][0];
        for (int i = 0; i < pathArr.count; i ++)
        {
            NSString *path = pathArr[i];
            if ([path containsString:fileName])
            {
                bc.tapImgIndex = i;
            }
        }
    }
    
    for (int i = 0; i < pathArr.count; i ++)
    {
        if (![[pathArr objectAtIndex:i] containsString:@"Retouching"])
        {
            AlbumsModel *model = [[AlbumsModel alloc] init];
            model.imageName = [pathArr objectAtIndex:i];
            model.isSelect = NO;
            model.isShow = NO;
            [albums_arr addObject:model];
        }
        
    }
    for (int i=0; i<[albums_arr count]; i++)
    {
        AlbumsModel *model = albums_arr[i];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 700*PSDSCALE_Y, SCREEN_WIDTH, 300*PSDSCALE_Y)];
        imageView.image = image;
        [image_arr addObject:imageView];
    }
    bc.imgsArray = image_arr;
    bc.hideStatusBar = NO;
    bc.superVc = self;
    [bc showWithPush:self]; //push方式
}

//获取本地资源
- (void)getCacheData
{
    [self.collectionDataSource removeAllObjects];
    NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
    if (pathArr.count)
    {
        for (int i = 0; i < pathArr.count; i ++)
        {
            NSString *filePath = [pathArr objectAtIndex:i];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:filePath forKey:@"fileName"];
            [dic setValue:@"local" forKey:@"local"];
            if (![filePath containsString:@"Retouching"])
            {
                [self.collectionDataSource addObject:dic];
            }
        }
        
        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
        if (pathArr.count)
        {
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSString *filePath = [pathArr objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:filePath forKey:@"fileName"];
                [dic setValue:@"local" forKey:@"local"];
                [self.collectionDataSource addObject:dic];
            }
        }
        
        [self.collectionView reloadData];
    }
    else
    {
        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
        if (pathArr.count)
        {
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSString *filePath = [pathArr objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:filePath forKey:@"fileName"];
                [dic setValue:@"local" forKey:@"local"];
                [self.collectionDataSource addObject:dic];
            }
            [self.collectionView reloadData];
        }
        
    }
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _time_line_scrollView)
    {
        CGPoint contentOffset = scrollView.contentOffset;
        if (time_right_btn.enabled == NO) {
            if (contentOffset.x > SCREEN_WIDTH) {
                // 往右边滑动
                contentOffset.x = SCREEN_WIDTH;
                scrollView.contentOffset = contentOffset;
            }
        }

    }
}


// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        
    }
    else
    {
        if (scrollView == _time_line_scrollView)
        {
            if (scrollView.contentOffset.x > SCREEN_WIDTH + SCREEN_WIDTH/2)
            {
                [self configTime_line_timeLabWithTimestamp:time_line_timeLab.text tag:2];
//                time_line_timeLab.text = [self computeDateWithTimestamp:time_line_timeLab.text tag:2];
            }
            else if (scrollView.contentOffset.x < SCREEN_WIDTH/2)
            {
                time_right_btn.enabled = YES;
                [self configTime_line_timeLabWithTimestamp:time_line_timeLab.text tag:1];
            }
        }
        
    }
    [_time_line_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
    
}

#pragma mark -------------- 刷新时间线时间 ------------------------------------

/**
 刷新时间线时间

 @param timestamp 时间
 @param tag 1，点击前一天， 2，点击后一天
 */
- (void)configTime_line_timeLabWithTimestamp:(NSString *)timestamp tag:(int)tag {
    
    time_line_timeLab.text = [self computeDateWithTimestamp:timestamp tag:tag];
    
    currentDateString = [MyTools getDateStringWithDateFormatter:@"yyyy-MM-dd" date:[NSDate date]];
    if ([time_line_timeLab.text isEqualToString:currentDateString]) {
        // 后一日按钮不可点击
        time_right_btn.enabled = NO;
    } else {
        time_right_btn.enabled = YES;
    }
    
    // 根据时间去数据库找时间线时间，刷新UI
    [self loadTime_line_dateFromDBWithTimeString:time_line_timeLab.text];
    
}

#pragma mark -------------- 根据时间去数据库找时间线时间，刷新UI --------------
/**
 根据时间去数据库找时间线时间，刷新UI

 @param timeString 时间
 */
- (void)loadTime_line_dateFromDBWithTimeString:(NSString *)timeString {
    // 把“-”去除
    NSString *timeStr = [timeString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSArray *timeLineArray = [CacheTool queryCameraTime_lineListWithDate:timeStr camereMac:self.model.macAddress userId:UserName];
    
    [dataSource removeAllObjects];
    all_mileage_lab2.text = [NSString stringWithFormat:@"%dKm",0];
    all_time_lab2.text = @"0分钟";
    if (timeLineArray.count == 0) {
        [self.tableView1 reloadData];
        [self.tableView2 reloadData];
        [self.tableView3 reloadData];
        return;
    }
    
    float distance = 0.0;
    float time = 0.0;
    for (CameraTime_lineModel *model in timeLineArray) {
        // 把"App login"和App login off去除
        if ([model.type isEqualToString:@"App login"])
        {
            continue;
        }
        if ([model.type isEqualToString:@"App login off"]) {
            continue;
        }
        
//        if ([model.type isEqualToString:@"Video"]) {
//            continue;
//        }
        
        if ([model.type isEqualToString:@"Stop CDR"]) {
            // 总里程和总时间叠加
            distance += [model.tirpMileage floatValue];
            time += [model.tirpTime floatValue];
        }
        
        [dataSource addObject:model];
        
    }
    NSMutableArray *temp_arr = [timeLineArray mutableCopy];
    time_line_num = 0;
    for (int i = 0; i<temp_arr.count; i ++)
    {
        if ((i+1) < temp_arr.count)
        {
            CameraTime_lineModel *model1 = temp_arr[i];
            CameraTime_lineModel *model2 = temp_arr[i+1];
            if ([model1.type isEqualToString:@"Stop CDR"] && [model2.type isEqualToString:@"Start CDR"])
            {
                // 遇到Stop CDR 下一个为Start CDR时，中间插入一个停车P
                CameraTime_lineModel *model3 = [[CameraTime_lineModel alloc] init];
                model3.type = @"P";
                model3.gps = model1.gps;
                model3.time = model1.time;
                model3.startTime = model1.time;
                model3.endTime = model2.time;
                
                
                if (dataSource.count == temp_arr.count)
                {
                    [dataSource insertObject:model3 atIndex:i+1];
                    
                }
                else
                {
                    if (i+time_line_num+1 < dataSource.count) {
                        [dataSource insertObject:model3 atIndex:i+time_line_num+1];
                    }
                    
                }
                
                time_line_num ++;//1 2 3 4 5 6 7 8 9
                
                
            }
        }
        
    }
    
    CameraTime_lineModel *start_model = [dataSource firstObject];
    if ([start_model.type isEqualToString:@"Start CDR"]) {
        // 在前面加上p
        
        CameraTime_lineModel *lastStop_model = [CacheTool queryCameraTime_lineLastStopBeforeDate:start_model.time camereMac:self.model.macAddress userId:UserName];
        
        CameraTime_lineModel *p_model = [[CameraTime_lineModel alloc] init];
        p_model.type = @"P";
        p_model.time = lastStop_model.time;
        p_model.startTime = lastStop_model.time;
        p_model.gps = start_model.gps;
        p_model.endTime = start_model.time;
        [dataSource insertObject:p_model atIndex:0];
    }
//    CameraTime_lineModel *end_model = dataSource.lastObject;
    all_mileage_lab2.text = [NSString stringWithFormat:@"%.0fKm",distance];
    
    int minute = time/60;
    
    if (minute >=60)
    {
        int hour = minute/60;
        minute = minute%60;
        all_time_lab2.text = [NSString stringWithFormat:@"%d时%d分钟",hour,minute];
    }
    else
    {
        all_time_lab2.text = [NSString stringWithFormat:@"%.0f分钟", time / 60];
    }
    
    
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];
    [self.tableView3 reloadData];

}

#pragma mark ---------------------- 获取设置信息 --------------------------------

//获取设置信息
- (void)getDeviceConfig {
    
    [self addActityLoading:nil subTitle:nil];
    // 获取设置信息
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"0D";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
    
    __weak typeof(self) weakSelf = self;
    // 先查询设备参数列表，设备参数列表里面有实时视频地址
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
        
        
        // 获取摄像机封面
        [weakSelf getCoverImage];
        // 请求 xml文件
        NSString *url = [NSString stringWithFormat:@"http://%@/tmp/%@", self.model.ipAddress, msg.msgBody];
        [RequestManager getRequestWithUrlString:url params:nil succeed:^(id responseObject) {
            
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            MMLog(@"dic = %@", dic);
            
            // 直播地址
            NSString *videoLiveUrlStr = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"rtspLive"));
            [SettingConfig shareInstance].isPhotoWithVideo = [FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"photoWithVideo")) intValue];
            
            NSString *volumeRecordingSensitivity = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"volumeRecordingSensitivity"));
            
            UIButton *temp_btn = (UIButton *)[weakSelf.videoNormalMenuBg.subviews objectAtIndex:1];
            if ([volumeRecordingSensitivity intValue] == 0)
            {
                temp_btn.selected = YES;
            }
            else
            {
                temp_btn.selected = NO;
            }
            MMLog(@"dic = %@", dic);
            weakSelf.videoLiveUrlStr = videoLiveUrlStr;
            if (videoLiveUrlStr.length == 0) {
                // 直播地址返回为空时，默认地址
                weakSelf.videoLiveUrlStr = @"rtsp://192.168.100.2/live.sdp";
            }
            
            // 回放地址
            NSString *videoLiveRecStr = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"rtspRecord"));
            weakSelf.videoLiveRecUrlStr = videoLiveRecStr;
            if (videoLiveRecStr.length == 0) {
                // 回放地址返回为空时，默认地址
                weakSelf.videoLiveRecUrlStr = @"rtsp://192.168.100.2/rec.sdp";
            }
            
            [weakSelf initVideoView];
            
            [self removeActityLoading];
            
            NSString *version = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"cdrSystemInfomation"), @"cdrSoftwareVersion"));
            version = [version substringFromIndex:3];
            
            if (![UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]])
            {
                [SettingConfig shareInstance].mac_address = self.model.macAddress;
                [UserDefaults setObject:version forKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]];
                [UserDefaults synchronize];
            }
            else
            {
                NSArray *upload_zipArr = [MyTools getAllDataWithPath:Upload_Path mac_adr:@"upload"];
                NSString *new_version = [UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]];
                if (upload_zipArr.count)
                {
                    if ([version doubleValue] <[new_version doubleValue])
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"摄像头已有新版本，是否升级" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                        [alertView show];
                    }
                    else
                    {
                        [SettingConfig shareInstance].mac_address = self.model.macAddress;
                        [UserDefaults setObject:version forKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]];
                        [UserDefaults synchronize];
                    }
                }
                else
                {
                    [SettingConfig shareInstance].mac_address = self.model.macAddress;
                    [UserDefaults setObject:version forKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]];
                    [UserDefaults synchronize];
                }
            }
            
            
            
            
            // 摄像机名
            NSString *cameraName = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(dic, @"cdrSystemCfg"), @"name"));
            [SettingConfig shareInstance].currentCameraModel.name = cameraName;
            [CacheTool updateCameraListWithCameraListModel:[SettingConfig shareInstance].currentCameraModel];
            [NotificationCenter postNotificationName:@"CameraListNeedToReloadDataNoti" object:nil];
            
        } andFailed:^(NSError *error) {
            
        }];
    }];
    
}

#pragma mark  - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            //上传升级包
            [self uploadUpgrade_package];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ---------------- 上传升级包 ------------------------------

//上传升级包
- (void)uploadUpgrade_package
{
    NSArray *path_arr = [MyTools getAllDataWithPath:Upload_Path mac_adr:_model.macAddress];
    NSString *version = [UserDefaults objectForKey:[NSString stringWithFormat:@"version_%@",self.model.macAddress]];
    NSString *path;
    for (NSString *str in path_arr)
    {
        if ([str containsString:version])
        {
            path = str;
            break;
        }
        
    }
    
    if (path.length == 0)
    {
        path = path_arr.firstObject;
    }
    NSData *zip_data = [NSData dataWithContentsOfFile:path];
    NSString *url = [NSString stringWithFormat:@"http://%@/action/upFirmware", [SettingConfig shareInstance].ip_url];
    __weak __typeof(self) weakSelf = self;
    [self list_click];
    [RequestManager uploadWithURL:url params:nil fileData:zip_data name:@"file" fileName:@"update.zip" mimeType:@"application/zip" progress:^(NSProgress *progress)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progress_lab.text = [NSString stringWithFormat:@"正在上传 %.2f%%",progress.fractionCompleted*100];
            [UIView animateWithDuration:2 animations:^{
                CGRect frame = weakSelf.freeProgressView.frame;
                frame.size.width = (500*progress.fractionCompleted)*PSDSCALE_X;
                weakSelf.freeProgressView.frame = frame;
            } completion:^(BOOL finished) {
                
            }];
        });
    } success:^(id responseObject) {
        MMLog(@"上传成功");
        [weakSelf dismissList];
        
        AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
        MsgModel *requestMsg = [[MsgModel alloc] init];
        requestMsg.cmdId = @"11";
        requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
        requestMsg.msgBody =@"update.zip";
        
        
        [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
            
            if ([msg.msgBody isEqualToString:@"OK"])
            {
//                [UserDefaults setObject:nil forKey:[NSString stringWithFormat:@"CameraUserName_%@",weakSelf.model.macAddress]];
//                [UserDefaults setObject:nil forKey:[NSString stringWithFormat:@"CameraPassword_%@",weakSelf.model.macAddress]];
//                [UserDefaults synchronize];
//                weakSelf.model.name = @"EKAKA1";
//                [CacheTool updateCameraListWithCameraListModel:weakSelf.model];
                MMLog(@"升级成功了");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"upload_action" object:@"YES"];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                [weakSelf deleteDirInCache];
            }
            else
            {
                [weakSelf addActityText:@"升级失败" deleyTime:1];
            }
            
        }];
        
        
        
    } fail:^(NSError *error) {
        MMLog(@"%@",error);
        [weakSelf dismissList];
        [weakSelf addActityText:@"网络异常，本次升级失败" deleyTime:1];
    }];
}

#pragma mark ------------- 删除升级包 -------------------------
//删除文件

-(void)deleteDirInCache
{
    NSArray *path_arr = [MyTools getAllDataWithPath:Upload_Path mac_adr:@"upload"];
    
    for (NSString *path in path_arr)
    {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

#pragma mark ---------------- (升级包)添加遮盖 ----------------------
- (void)list_click
{
    [self addCoverToView:self.view];
}

#pragma mark ---------------- (升级包)移除遮盖 ----------------------

- (void)dismissList
{
    
    [_cover removeFromSuperview];
}


#pragma mark ---------------- (升级包)设置遮盖 ----------------------
//设置遮盖
- (void)addCoverToView:(UIView *)view
{
    _cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _cover.backgroundColor = [[UIColor colorWithRed:177/255.0f green:177/255.0f blue:177/255.0f alpha:YES] colorWithAlphaComponent:0.3];
    [self.view addSubview:_cover];
    
    [self initUI];
}


- (void)initUI
{
    UIView *bg_View = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-580*PSDSCALE_X)/2, (VIEW_H(_cover)-150*PSDSCALE_Y)/2, 580*PSDSCALE_X, 150*PSDSCALE_Y)];
    bg_View.backgroundColor = [UIColor whiteColor];
    bg_View.layer.masksToBounds = YES;
    bg_View.layer.cornerRadius = 5;
    [_cover addSubview:bg_View];
    
    self.progress_lab = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, 20*PSDSCALE_Y, VIEW_W(_cover)-40*PSDSCALE_X, 42*PSDSCALE_Y)];
    self.progress_lab.textAlignment = NSTextAlignmentLeft;
    self.progress_lab.textColor = [UIColor blackColor];
    self.progress_lab.font = [UIFont systemFontOfSize:32*FONTCALE_Y];
    [bg_View addSubview:self.progress_lab];
    
    
    UIView *allProgressView = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, VIEW_H_Y(self.progress_lab)+36*PSDSCALE_Y, 500*PSDSCALE_X, 23*PSDSCALE_Y)];
    allProgressView.backgroundColor = RGBSTRING(@"dcdcdc");
    allProgressView.layer.masksToBounds = YES;
    allProgressView.layer.cornerRadius = 6;
    [bg_View addSubview:allProgressView];
    
    
    _freeProgressView = [[UILabel alloc] initWithFrame:CGRectMake(40*PSDSCALE_X, VIEW_H_Y(self.progress_lab)+36*PSDSCALE_Y, 0, 23*PSDSCALE_Y)];
    _freeProgressView.backgroundColor = [UIColor blueColor];
    _freeProgressView.layer.masksToBounds = YES;
    _freeProgressView.layer.cornerRadius = 6;
    [bg_View addSubview:_freeProgressView];
    
    
}

#pragma mark ------------- 下载视频和图片 ------------------------------------
//下载视频和图片
-(void)getPhotoAndVideoWithisPhoto:(BOOL)isPhoto isVideo:(BOOL)isVideo
{
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"08";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
    __weak typeof(self) weakSelf = self;
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
        [weakSelf addActityLoading:nil subTitle:nil];
        NSLog(@"===================%@=================",msg);
        [RequestManager getRequestWithUrlString:[NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url,msg.msgBody] params:nil succeed:^(id responseObject) {
            [weakSelf removeActityLoading];
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            MMLog(@"==================%@",dic);
            NSDictionary *cdJpg = VALUEFORKEY(dic, @"cdJpg");
            [weakSelf.xml_pre_Array removeAllObjects];
            [weakSelf.collectionDataSource removeAllObjects];
            if ([VALUEFORKEY(cdJpg, @"jpg") isKindOfClass:[NSArray class]])
            {
                NSArray *jpgs = VALUEFORKEY(cdJpg, @"jpg");
                if (jpgs.count > 0)
                {
                    for (NSDictionary *dic in jpgs)
                    {
                        
                        NSString *str = FORMATSTRING(VALUEFORKEY(dic, @"fileName"));
                        
                        if (![str containsString:@"_pre"])
                        {
                            
                            //判断是否存在
                            if ([FMDBTools selectDownloadWithFile_name:str])
                            {
                                //是否被删除
                                if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                                {
//                                    [weakSelf.collectionDataSource addObject:dic];
                                }
                            }
                            else
                            {
                                [weakSelf.collectionDataSource addObject:dic];
                            }
                        }
                        
                        if ([str containsString:@"_"])//图片缩略图或者视频缩略图的情况
                        {
                            if ([str containsString:@"_pre"])//图片缩略图
                            {
                                
                                str = [str componentsSeparatedByString:@"_pre"][0];
                                str = [NSString stringWithFormat:@"%@.jpg",str];
                                //判断该大图的缩略图是否存在
                                if ([FMDBTools selectDownloadWithFile_name:str])
                                {
                                    //是否被删除
                                    if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                                    {
//                                        [xml_pre_Array addObject:dic];
                                    }
                                }
                                else//不存在就放入xml_pre_Array数组
                                {
                                    [weakSelf.xml_pre_Array addObject:dic];
                                }
                            }
                            else//视频缩略图
                            {
                                //判断是否存在
                                if ([FMDBTools selectDownloadWithFile_name:str])
                                {
                                    //是否被删除
                                    if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                                    {
//                                        [xml_pre_Array addObject:dic];
                                    }
                                }
                                else//不存在就放入xml_pre_Array数组
                                {
                                    [weakSelf.xml_pre_Array addObject:dic];
                                }
                            }
                        }
                        
                    }
                }
            }
            else//返回不是数组,单个文件的情况
            {
                NSString *str = FORMATSTRING(VALUEFORKEY(VALUEFORKEY(cdJpg, @"jpg"), @"fileName"));
                
                if (![str containsString:@"_pre"])
                {
                    
                    //判断是否存在
                    if ([FMDBTools selectDownloadWithFile_name:str])
                    {
                        //是否被删除
                        if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                        {
//                            [weakSelf.collectionDataSource addObject:VALUEFORKEY(cdJpg, @"jpg")];
                        }
                    }
                    else
                    {
                        [weakSelf.collectionDataSource addObject:VALUEFORKEY(cdJpg, @"jpg")];
                    }
                }
                
                if ([str containsString:@"_"])
                {
                    if ([str containsString:@"_pre"])
                    {
                        str = [str componentsSeparatedByString:@"_pre"][0];
                        str = [NSString stringWithFormat:@"%@.jpg",str];
                        //判断是否存在
                        if ([FMDBTools selectDownloadWithFile_name:str])
                        {
                            //是否被删除
                            if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                            {
//                                [xml_pre_Array addObject:VALUEFORKEY(cdJpg, @"jpg")];
                            }
                        }
                        else
                        {
                            [weakSelf.xml_pre_Array addObject:VALUEFORKEY(cdJpg, @"jpg")];
                        }
                    }
                    else
                    {
                        //判断是否存在
                        if ([FMDBTools selectDownloadWithFile_name:str])
                        {
                            //是否被删除
                            if (![FMDBTools selectDownloadIsDelWithFile_name:str])
                            {
//                                [xml_pre_Array addObject:VALUEFORKEY(cdJpg, @"jpg")];
                            }
                        }
                        else
                        {
                            [weakSelf.xml_pre_Array addObject:VALUEFORKEY(cdJpg, @"jpg")];
                        }
                    }
                }
            }
            
            /**
             xml_pre_Array与self.collectionDataSource的区别
             xml_pre_Array用于存放后缀是_pre.jpg _10.jpg的数组
             self.collectionDataSource用于存放后缀是.jpg _10.jpg的数组
             
             如果xml_pre_Array.count 与 self.collectionDataSource.count相同 就使用self.collectionDataSource数组 就不用再去处理图片的名称
             如果不相同 使用xml_pre_Array 但是要处理图片后缀名称
             */
//            [weakSelf newArray:weakSelf.xml_pre_Array isPhoto:isPhoto isVideo:isVideo];
            if (weakSelf.xml_pre_Array.count == weakSelf.collectionDataSource.count)
            {
                [weakSelf newArray:weakSelf.collectionDataSource isPhoto:isPhoto isVideo:isVideo];
            }
            else
            {
                [weakSelf newArray:weakSelf.xml_pre_Array isPhoto:isPhoto isVideo:isVideo];
            }
            
        } andFailed:^(NSError *error) {
            
            [weakSelf removeActityLoading];
            
        }];
        
    }];
    
}




//遍历数组，将游戏专题数据按orderNum重新排序
- (void)newArray:(NSMutableArray *)arr isPhoto:(BOOL)isPhoto isVideo:(BOOL)isVideo
{
    __weak typeof(self) weakSelf = self;
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithInt:[VALUEFORKEY(obj2, @"index") intValue]] compare:[NSNumber numberWithInt:[VALUEFORKEY(obj1, @"index") intValue]]];
        return result;
    }];
    if (self.xml_pre_Array.count == weakSelf.collectionDataSource.count)
    {
        [self.collectionDataSource removeAllObjects];
        
        [self.collectionDataSource addObjectsFromArray:sortedArray];
        NSMutableArray *pathArr;
        pathArr =[MyTools getAllDataWithPath:Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
        if (pathArr.count)
        {
            //添加本地数据
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSString *filePath = [pathArr objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:filePath forKey:@"fileName"];
                [dic setValue:@"local" forKey:@"local"];
                
                if (![filePath containsString:@"Retouching"])
                {
                    [self.collectionDataSource addObject:dic];
                    [self.xml_pre_Array addObject:dic];
                }
                
                
            }
            
            pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
            
            if (pathArr.count)
            {
                for (int i = 0; i < pathArr.count; i ++)
                {
                    NSString *filePath = [pathArr objectAtIndex:i];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:filePath forKey:@"fileName"];
                    [dic setValue:@"local" forKey:@"local"];
                    [self.collectionDataSource addObject:dic];
                    [self.xml_pre_Array addObject:dic];
                }
            }
        }
        
        
        
        if (self.collectionDataSource)
        {
            
            NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                
                //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
                //NSComparisonResult result = [obj1 compareFile:obj2];
                
                NSString *fileName1 = [weakSelf changeFileNameWithfileName:VALUEFORKEY(obj1, @"fileName")];
                NSString *fileName2 = [weakSelf changeFileNameWithfileName:VALUEFORKEY(obj2, @"fileName")];
               
                NSComparisonResult result = [[NSNumber numberWithLongLong:[fileName2 longLongValue]] compare:[NSNumber numberWithLongLong:[fileName1 longLongValue]]];
                return result;
            }];
            
            [self.collectionDataSource removeAllObjects];
            [self.collectionDataSource addObjectsFromArray:sortedArray];
            NSMutableArray *temp_arr = [self.collectionDataSource mutableCopy];
            for (int i = 0; i < temp_arr.count; i ++)
            {
                NSDictionary *dic1 = [temp_arr objectAtIndex:i];
                NSDictionary *dic2;
                if (i != temp_arr.count-1)
                {
                    dic2 = [temp_arr objectAtIndex:i+1];
                }
                
                NSString *fileName1 = VALUEFORKEY(dic1, @"fileName");
                if ([fileName1 containsString:@"/"]) {
                    
                    fileName1 = [fileName1 componentsSeparatedByString:@"/"].lastObject;
                    fileName1 = [fileName1 componentsSeparatedByString:@"."].firstObject;
                    
                }
                else
                {
                    fileName1 = [fileName1 componentsSeparatedByString:@"."].firstObject;
                }
                
                NSString *fileName2 = VALUEFORKEY(dic2, @"fileName");
                if ([fileName2 containsString:@"/"]) {
                    
                    fileName2 = [fileName2 componentsSeparatedByString:@"/"].lastObject;
                    fileName2 = [fileName2 componentsSeparatedByString:@"."].firstObject;
                    
                }
                else
                {
                    fileName2 = [fileName2 componentsSeparatedByString:@"."].firstObject;
                }
                
                if ([fileName2 containsString:@"_"])
                {
                    if ([fileName2 containsString:fileName1])
                    {
                        [self.collectionDataSource exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                    }
                }
                
            }
            [self.collectionView reloadData];
            
        }
    }
    else
    {
        [self.xml_pre_Array removeAllObjects];
        
        [self.xml_pre_Array addObjectsFromArray:sortedArray];
        NSArray *pathArr;
        pathArr =[MyTools getAllDataWithPath:Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
        if (pathArr.count)
        {
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSString *filePath = [pathArr objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:filePath forKey:@"fileName"];
                [dic setValue:@"local" forKey:@"local"];
                
                if (![filePath containsString:@"Retouching"])
                {
                    [self.collectionDataSource addObject:dic];
                    [self.xml_pre_Array addObject:dic];
                }
            }
            
           
        }
        
        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
        if (pathArr.count)
        {
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSString *filePath = [pathArr objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:filePath forKey:@"fileName"];
                [dic setValue:@"local" forKey:@"local"];
                [self.xml_pre_Array addObject:dic];
                [self.collectionDataSource addObject:dic];
            }
        }
        
        if (self.xml_pre_Array.count)
        {
            NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                
                //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
                //NSComparisonResult result = [obj1 compareFile:obj2];
                
                NSString *fileName1 = [weakSelf changeFileNameWithfileName:VALUEFORKEY(obj1, @"fileName")];
                NSString *fileName2 = [weakSelf changeFileNameWithfileName:VALUEFORKEY(obj2, @"fileName")];
                
                NSComparisonResult result = [[NSNumber numberWithLongLong:[fileName2 longLongValue]] compare:[NSNumber numberWithLongLong:[fileName1 longLongValue]]];
                return result;
            }];
            
            [self.xml_pre_Array removeAllObjects];
            [self.xml_pre_Array addObjectsFromArray:sortedArray];
            NSMutableArray *temp_arr = [self.xml_pre_Array mutableCopy];
            for (int i = 0; i < temp_arr.count; i ++)
            {
                NSDictionary *dic1 = [temp_arr objectAtIndex:i];
                NSDictionary *dic2;
                if (i != temp_arr.count-1)
                {
                    dic2 = [temp_arr objectAtIndex:i+1];
                }
                
                NSString *fileName1 = VALUEFORKEY(dic1, @"fileName");
                
                if ([fileName1 containsString:@"_pre"])
                {
                    fileName1 = [fileName1 componentsSeparatedByString:@"_pre"].firstObject;
                }
                else
                {
                    if ([fileName1 containsString:@"/"]) {
                        
                        fileName1 = [fileName1 componentsSeparatedByString:@"/"].lastObject;
                        fileName1 = [fileName1 componentsSeparatedByString:@"."].firstObject;
                        
                    }
                    else
                    {
                        fileName1 = [fileName1 componentsSeparatedByString:@"."].firstObject;
                    }
                }
                
                
                
                NSString *fileName2 = VALUEFORKEY(dic2, @"fileName");
                
                if ([fileName1 containsString:@"_pre"])
                {
                    fileName2 = [fileName2 componentsSeparatedByString:@"_pre"].firstObject;
                }
                else
                {
                    if ([fileName2 containsString:@"/"]) {
                        
                        fileName2 = [fileName2 componentsSeparatedByString:@"/"].lastObject;
                        fileName2 = [fileName2 componentsSeparatedByString:@"."].firstObject;
                        
                    }
                    else
                    {
                        fileName2 = [fileName2 componentsSeparatedByString:@"."].firstObject;
                    }
                }
                
                
                if ([fileName2 containsString:@"_"])
                {
                    if (![fileName2 containsString:@"_pre"])
                    {
                        
                        if ([fileName2 containsString:fileName1])
                        {
                            [self.xml_pre_Array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                        }
                        
                    }
                    
                }
                
            }
            [self.collectionView reloadData];
        }
    }
    
    //判断文件是否已存在 不存在才下载
    [self.collectionDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *file_name = VALUEFORKEY((NSDictionary *)obj, @"fileName");
            NSString *file_Path = [[NSString alloc] init];
            
            if (![[(NSDictionary *)obj allKeys] containsObject:@"local"]) {
                
                if ([file_name containsString:@"_pre"]||![file_name containsString:@"_"])
                {
                    file_Path = [Photo_Path(weakSelf.model.macAddress) stringByAppendingPathComponent:file_name];
                }
                else
                {
                    
                    file_Path = [Video_Photo_Path(weakSelf.model.macAddress) stringByAppendingPathComponent:file_name];
                    
                }
                //不存在就下载
                if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path]) {
                    
                    [weakSelf.download_arr addObject:file_name];
                }
                
            }
        }
    }];
    
    self.download_arr = [[self setWithArray:self.download_arr] mutableCopy];
    
    if (self.download_arr.count !=0)
    {
        //是否拍照了
        if (isPhoto)
        {
            //如果download_arr中只有一个值 表示摄像头之前没有任何下载资源 现在拍了照
            if (self.download_arr.count ==1)
            {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                    [self downloadWithURLTag:0];
//                });
            }
            else
            {
                //下载完成了 但是又拍照了
                if (isDownloadOver)
                {
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                        [self downloadWithURLTag:0];
//                    });
                }
            }
        }
        else
        {
            //有关联视频返回
            if (isVideo)
            {
                //所有资源下载完了 但是关联视频返回了
                if (isDownloadOver)
                {
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                        [self downloadWithURLTag:0];
//                    });
                }
            }
            else
            {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                    [self downloadWithURLTag:0];
//                });
            }
            
            
        }
        
    }
    
}

#pragma mark -------------------- 截取文件名称 ---------------------------
//截取文件名称
-(NSString *)changeFileNameWithfileName:(NSString *)fileName
{
    if ([fileName containsString:@"_pre"])
    {
        fileName = [fileName componentsSeparatedByString:@"_pre"].firstObject;
    }
    else
    {
        if ([fileName containsString:@"/"])
        {
            fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
            if ([fileName containsString:@"_"])
            {
                fileName = [fileName componentsSeparatedByString:@"_"].firstObject;
            }
            else
            {
                fileName = [fileName componentsSeparatedByString:@"."].firstObject;
            }
        }
        else
        {
            fileName = [fileName componentsSeparatedByString:@"."].firstObject;
        }
    }
    return fileName;
}

#pragma mark ------------------- 数组去重 --------------------------------
//数组去重
- (NSArray *)setWithArray:(NSMutableArray *)arr
{
    NSSet *set = [NSSet setWithArray:arr];
    return [set allObjects];
}


#pragma mark ------------------- 判断是否连接的是摄像头的WiFi --------------

//判断是否连接的是摄像头的WiFi
-(BOOL)isCameraMacAddress
{
    NSString *BSSID;
    
    if ([[self getSSIDInfo] isKindOfClass:[NSDictionary class]])
    {
        //获取当前网络的mac_address
        NSDictionary *dic =  [self getSSIDInfo];
        BSSID = VALUEFORKEY(dic, @"BSSID");
        BSSID = [BSSID uppercaseString];
        NSArray *BSSIDS = [BSSID componentsSeparatedByString:@":"];
        NSMutableArray *temp_arr = [NSMutableArray array];
        
        for (NSString *str in BSSIDS)
        {
            //判断mac_address中每个字符串长度是否为2
            if (str.length < 2)
            {
                NSString *temp_str = [NSString stringWithFormat:@"0%@",str];
                [temp_arr addObject:temp_str];
            }
            else
            {
                [temp_arr addObject:str];
            }
            
        }
        BSSID = [temp_arr componentsJoinedByString:@""];
    }
    _BSSID = BSSID;
    if ([BSSID isEqualToString:self.model.macAddress])
    {
        return YES;
    }
    return NO;
}

/**
 获取wifi mac地址
 
 @return wifi地址信息
 */
- (id)getSSIDInfo  //引用
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info;
    
    /**
     {
     BSSID = "e0:b9:4d:6c:9d:d";
     SSID = "KAKA_C9D0D";
     SSIDDATA = <4b414b41 5f433944 3044>;
     }
     */
}

#pragma mark ************** 自动下载图片和视频 **************

- (void)downloadWithURLTag:(int)tag
{
    
    if (![self isCameraMacAddress])
    {
        return;
    }
    
    if (![self Reserved])
    {
        [self addActityText:@"手机存储小于500MB,请清理手机存储空间" deleyTime:1.0];
        return;
    }
    
    if (!downloadSwitch.on)
    {
        return;
    }
    
    
    
    __block int finish_download_tag = tag;
    __weak typeof(self) weakSelf = self;
    if ((finish_download_tag == self.download_arr.count)||(finish_download_tag > self.download_arr.count))
    {
        MMLog(@"资源下载完成");
        isDownloadOver = YES;
        if (finish_download_tag > self.download_arr.count)
        {
            NSLog(@"我去 数组竟然是空的");
        }
        else
        {
            [self.download_arr removeAllObjects];
            [self addActityText:@"资源下载完成" deleyTime:1];
        }
        
        [self.collectionView reloadData];
        
    }
    else
    {
        
        //判断是否下载过,下载过的就跳过,下载下一个
        if ([FMDBTools selectDownloadWithFile_name:FORMATSTRING(self.download_arr[tag])])
        {
            [self downloadWithURLTag:tag+1];
            return;
        }
        NSString *str = FORMATSTRING(self.download_arr[tag]);
        
        if (![str hasSuffix:@".jpg"])//如果不是以.jpg结尾就过滤,跳过下载下一个
        {
            [self downloadWithURLTag:finish_download_tag+1];
        }
        else
        {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:self.model.macAddress];
            
            
            if ([str containsString:@"_"])//如果是视频缩略图
            {
                documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Video/Photo"];
            }
            else
            {
                documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Photo"];
            }
            
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
            NSString *url_str =FORMATSTRING(self.download_arr[tag]);
            
            url_str = [NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url, url_str];
            //下载相关图片
            [RequestManager downloadWithURL:url_str savePathURL:documentsDirectoryURL progress:^(NSProgress *progress)
             {
                 
             }
            succeed:^(id responseObject)
             {
                 if (weakSelf.download_arr.count == 0)
                 {
                     
                     NSString *fileName = [str componentsSeparatedByString:@"."][0];
                     NSArray *pathArr;
                     if ([fileName containsString:@"_"])
                     {
                         pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                     }
                     else
                     {
                         pathArr = [MyTools getAllDataWithPath:Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                     }
                     
                     for (NSString *str in pathArr)
                     {
                         
                         if ([str containsString:fileName])
                         {
                             fileName = str;
                             break;
                         }
                     }
                     BOOL isdeleteVideo = [weakSelf deleteDirInCache:fileName];
                     if (isdeleteVideo)
                     {
                         MMLog(@"删除成功");
                     }
                     else
                     {
                         MMLog(@"删除失败");
                     }
                     
                     return;
                 }
                 
                 //判断是否下载过
                 if (![FMDBTools selectDownloadWithFile_name:FORMATSTRING(weakSelf.download_arr[tag])])
                 {
                     if ([FMDBTools saveDownloadFileWithFileName:FORMATSTRING(weakSelf.download_arr[tag]) is_del:@"0"]) {
                         MMLog(@"保存成功！");
                     }
                 }
                 finish_download_tag ++;
                 
                 NSArray *temp = [FORMATSTRING(weakSelf.download_arr[tag]) componentsSeparatedByString:@"."];
                 __block NSString *temp_str = temp[0];
                 //如果是视频缩略图,则要继续下载视频
                
                 if ([temp_str containsString:@"_"])
                 {
                     
                     AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                     MsgModel *msg = [[MsgModel alloc] init];
                     msg.cmdId = @"06";
                     msg.token = [SettingConfig shareInstance].deviceLoginToken;
                     
                     msg.msgBody =temp_str;
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         
                         [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                             
                             if ([msg.msgBody hasSuffix:@".mp4"])//去下载视频
                             {
                                 if (!downloadSwitch.on)//如果关闭自动下载开关就删除视频缩略图
                                 {
                                     NSArray *pathArr;
                                     pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                                     for (NSString *str in pathArr)
                                     {
                                         
                                         if ([str containsString:temp_str])
                                         {
                                             temp_str = str;
                                             break;
                                         }
                                     }
                                     BOOL isdeleteVideo = [self deleteDirInCache:temp_str];
                                     if (isdeleteVideo)
                                     {
                                         MMLog(@"删除成功");
                                         
                                         if (self.download_arr.count) {
                                             
                                             if ([FMDBTools selectDownloadWithFile_name:FORMATSTRING(self.download_arr[tag])])
                                             {
                                                 if ([FMDBTools updateDowloaddelWithFile_name:FORMATSTRING(self.download_arr[tag])])
                                                 {
                                                     MMLog(@"修改成功！");
                                                     
                                                     NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
                                                     for (NSDictionary *dic in xml_temp_arr)
                                                     {
                                                         NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                                         if ([temp_fileName isEqualToString:FORMATSTRING(self.download_arr[tag])])
                                                         {
                                                             [self.xml_pre_Array removeObject:dic];
                                                             break;
                                                         }
                                                     }
                                                     
                                                     xml_temp_arr = [self.collectionDataSource mutableCopy];
                                                     for (NSDictionary *dic in xml_temp_arr)
                                                     {
                                                         NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                                         if ([temp_fileName isEqualToString:FORMATSTRING(self.download_arr[tag])])
                                                         {
                                                             [self.collectionDataSource removeObject:dic];
                                                             break;
                                                         }
                                                     }
                                                     [self.collectionView reloadData];
                                                 }
                                             }
                                         }
                                         
                                         
                                     }
                                     else
                                     {
                                         MMLog(@"删除失败");
                                     }
                                     [weakSelf downloadWithURLTag:tag];
                                 }
                                 else
                                 {
                                     
                                     [weakSelf downloadVideoWithName:msg.msgBody tag:finish_download_tag];
                                 }
                                 
                             }
                             else//返回错误信息,删除改视频缩略图
                             {
                                 NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
                                 
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
                                     if (weakSelf.download_arr.count)
                                     {
                                         if ([FMDBTools selectDownloadWithFile_name:FORMATSTRING(weakSelf.download_arr[tag])])
                                         {
                                             if ([FMDBTools updateDowloaddelWithFile_name:FORMATSTRING(weakSelf.download_arr[tag])])
                                             {
                                                 MMLog(@"修改成功！");
                                                 
                                                 NSMutableArray *xml_temp_arr = [weakSelf.xml_pre_Array mutableCopy];
                                                 for (NSDictionary *dic in xml_temp_arr)
                                                 {
                                                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                                     if ([temp_fileName isEqualToString:FORMATSTRING(weakSelf.download_arr[tag])])
                                                     {
                                                         [weakSelf.xml_pre_Array removeObject:dic];
                                                         break;
                                                     }
                                                 }
                                                 
                                                 xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                                                 for (NSDictionary *dic in xml_temp_arr)
                                                 {
                                                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                                     if ([temp_fileName isEqualToString:FORMATSTRING(weakSelf.download_arr[tag])])
                                                     {
                                                         [weakSelf.collectionDataSource removeObject:dic];
                                                         break;
                                                     }
                                                 }
                                                 [weakSelf.collectionView reloadData];
                                             }
                                         }
                                     }
                                     
                                 }
                                 else
                                 {
                                     MMLog(@"删除失败");
                                 }
                                 
                                 [weakSelf downloadWithURLTag:finish_download_tag];
                             };
                             //                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             //                         
                             //                         
                             //                         }];
                             //                     });
                             
                             
                         }];
                     });
                }
                 else//如果是图片就下载下一个
                 {
                     
                     [weakSelf downloadWithURLTag:finish_download_tag];
                 }
                 
                 
//                 [self.collectionView reloadData];
                 
                 
             }
            andFailed:^(NSError *error)
             {
                 NSString *temp_str = FORMATSTRING(weakSelf.download_arr[tag]);
                 NSArray *pathArr;
                 if ([temp_str containsString:@"_"])
                 {
                     pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
                 }
                 else
                 {
                     pathArr =[MyTools getAllDataWithPath:Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
                 }
                 
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
                     if (weakSelf.download_arr.count)
                     {
                         if ([FMDBTools selectDownloadWithFile_name:FORMATSTRING(weakSelf.download_arr[tag])])
                         {
                             if ([FMDBTools updateDowloaddelWithFile_name:FORMATSTRING(weakSelf.download_arr[tag])])
                             {
                                 MMLog(@"修改成功！");
                             }
                         }
                     }
                 }
                     MMLog(@"删除成功");
                    
                 NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
                 if (self.xml_pre_Array.count)
                 {
                     
                     for (NSDictionary *dic in xml_temp_arr)
                     {
                         NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                         if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                         {
                             [self.xml_pre_Array removeObject:dic];
                             break;
                         }
                     }
                 }
                 
                 if (self.collectionDataSource.count)
                 {
                     xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                     for (NSDictionary *dic in xml_temp_arr)
                     {
                         NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                         if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                         {
                             [self.collectionDataSource removeObject:dic];
                             break;
                         }
                     }
                 }
                 [weakSelf.collectionView reloadData];
                 [weakSelf downloadWithURLTag:finish_download_tag];
                 MMLog(@"%@",error);
             }];
        }
        
    }
    
}

//点击下载视频
-(void)clickDownloadVideoWithFileName:(NSString *)fileName
{
    if (![self isCameraMacAddress])
    {
        return;
    }
    //手机存储小于500MB时
    if (![self Reserved])
    {
        [self addActityText:@"手机存储小于500MB,请清理手机存储空间" deleyTime:1.0];
        return;
    }
    NSString *file_Path = [[NSString alloc] init];
    file_Path = [Video_Path(self.model.macAddress) stringByAppendingPathComponent:fileName];
    //不存在就下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:self.model.macAddress];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Video/Video"];
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
        
        __weak typeof(self) weakSelf = self;
        [RequestManager downloadWithURL:[NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url,fileName] savePathURL:documentsDirectoryURL progress:^(NSProgress *progress) {
            ZYLog(@"*********************视频在下载,progress = %zd",progress.completedUnitCount);
        }
        succeed:^(id responseObject)
         {
             //点击下载
                 [weakSelf removeActityLoading];
                 NSDictionary *dic = [[NSDictionary alloc] init];
                 
                 if (weakSelf.xml_pre_Array.count)
                 {
                     if (weakSelf.xml_pre_Array.count == weakSelf.collectionDataSource.count)
                     {
                         dic = weakSelf.collectionDataSource[_indexPath.row];
                     }
                     else
                     {
                         dic = weakSelf.xml_pre_Array[_indexPath.row];
                     }
                 }
                 else
                 {
                     dic = weakSelf.collectionDataSource[_indexPath.row];
                     
                 }
                 
                 NSString *fileName = VALUEFORKEY(dic, @"fileName");
                 
                 fileName = [fileName componentsSeparatedByString:@"_"][0];
                 fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                 NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(_model.macAddress) mac_adr:_model.macAddress];
                 
                 for (NSString *str in pathArr)
                 {
                     
                     if ([str containsString:fileName])
                     {
                         fileName = str;
                         break;
                     }
                 }
                 if (![fileName hasSuffix:@".mp4"])
                 {
                     [self addActityText:@"视频未下载完成,请稍后重试" deleyTime:1];
                     return;
                 }
                 NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
                 MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
                 playVC.videoURL = sourceMovieURL;
                 playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];
                 
                 [weakSelf.navigationController pushViewController:playVC animated:YES];
                 [weakSelf.collectionView reloadData];
         }
        andFailed:^(NSError *error)
         {
             NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
             NSString *temp_str = [fileName componentsSeparatedByString:@"."].firstObject;
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
             
             MMLog(@"%@",error);
             [weakSelf removeActityLoading];
             
             NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
             if (self.xml_pre_Array.count)
             {
                 
                 for (NSDictionary *dic in xml_temp_arr)
                 {
                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                     if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                     {
                         [self.xml_pre_Array removeObject:dic];
                         break;
                     }
                 }
             }
             
             if (self.collectionDataSource.count)
             {
                 xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                 for (NSDictionary *dic in xml_temp_arr)
                 {
                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                     if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                     {
                         [self.collectionDataSource removeObject:dic];
                         break;
                     }
                 }
             }
             [weakSelf.collectionView reloadData];
             
         }];
        
        
    }
    else
    {
        
    }
    
}





#pragma mark ----------------------自动下载视频 ----------------------------
//下载视频
- (void)downloadVideoWithName:(NSString *)name tag:(int)tag
{
    
    if (![self isCameraMacAddress])
    {
        return;
    }
    
    //手机存储小于500MB时
    if (![self Reserved])
    {
        [self addActityText:@"手机存储小于500MB,请清理手机存储空间" deleyTime:1.0];
        return;
    }
    
    if (tag != 10000)
    {
        if (!downloadSwitch.on)
        {
            return;
        }
    }
    NSString *file_Path = [[NSString alloc] init];
    file_Path = [Video_Path(self.model.macAddress) stringByAppendingPathComponent:name];
    //不存在就下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:self.model.macAddress];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Video/Video"];
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
        
        __weak typeof(self) weakSelf = self;
       [RequestManager downloadWithURL:[NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url,name] savePathURL:documentsDirectoryURL progress:^(NSProgress *progress) {
           ZYLog(@"自动下载视频 ******%zd",progress.completedUnitCount);
        }
        succeed:^(id responseObject)
        {
            
            if (tag)
            {
                //点击下载
                if (tag == 10000)
                {
                    [weakSelf removeActityLoading];
                    NSDictionary *dic = [[NSDictionary alloc] init];
                    
                    if (weakSelf.xml_pre_Array.count)
                    {
                        if (weakSelf.xml_pre_Array.count == weakSelf.collectionDataSource.count)
                        {
                            dic = weakSelf.collectionDataSource[_indexPath.row];
                            
                            
                        }
                        else
                        {
                            dic = weakSelf.xml_pre_Array[_indexPath.row];
                        }
                    }
                    else
                    {
                        dic = weakSelf.collectionDataSource[_indexPath.row];
                        
                    }
                    
                    NSString *fileName = VALUEFORKEY(dic, @"fileName");
                    
                    fileName = [fileName componentsSeparatedByString:@"_"][0];
                    fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                    NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(_model.macAddress) mac_adr:_model.macAddress];
                    
                    for (NSString *str in pathArr)
                    {
                        
                        if ([str containsString:fileName])
                        {
                            fileName = str;
                            break;
                        }
                    }
                    if (![fileName hasSuffix:@".mp4"])
                    {
                        [self addActityText:@"视频未下载完成,请稍后重试" deleyTime:1];
                        return;
                    }
                    NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
                    MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
                    playVC.videoURL = sourceMovieURL;
                    playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];
                    
                    [weakSelf.navigationController pushViewController:playVC animated:YES];
                    [weakSelf.collectionView reloadData];
                    
                }
                else
                {
                    if (!downloadSwitch.on)
                    {
                        NSString *temp_str = [name componentsSeparatedByString:@"."].firstObject;
                        NSArray *pathArr;
                        pathArr = [MyTools getAllDataWithPath:Video_Photo_Path(self.model.macAddress) mac_adr:self.model.macAddress];
                        for (NSString *str in pathArr)
                        {
                            
                            if ([str containsString:temp_str])
                            {
                                temp_str = str;
                                break;
                            }
                        }
                        BOOL isdeleteVideo = [self deleteDirInCache:temp_str];
                        if (isdeleteVideo)
                        {
                            MMLog(@"删除成功");
                            
                            if (self.download_arr.count)
                            {
                                if ([FMDBTools selectDownloadWithFile_name:FORMATSTRING(self.download_arr[tag])])
                                {
                                    if ([FMDBTools updateDowloaddelWithFile_name:FORMATSTRING(self.download_arr[tag])])
                                    {
                                        MMLog(@"修改成功！");
                                        
                                        NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
                                        for (NSDictionary *dic in xml_temp_arr)
                                        {
                                            NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                            if ([temp_fileName isEqualToString:FORMATSTRING(self.download_arr[tag])])
                                            {
                                                [self.xml_pre_Array removeObject:dic];
                                                break;
                                            }
                                        }
                                        
                                        xml_temp_arr = [self.collectionDataSource mutableCopy];
                                        for (NSDictionary *dic in xml_temp_arr)
                                        {
                                            NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                                            if ([temp_fileName isEqualToString:FORMATSTRING(self.download_arr[tag])])
                                            {
                                                [self.collectionDataSource removeObject:dic];
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        else
                        {
                            MMLog(@"删除失败");
                        }
                    }
                    [weakSelf downloadWithURLTag:tag];
                    [weakSelf.collectionView reloadData];
                }
            }
          

        }
        andFailed:^(NSError *error)
        {
            NSArray *pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
            NSString *temp_str = [name componentsSeparatedByString:@"."].firstObject;
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
                if ([FMDBTools selectDownloadWithFile_name:name])
                {
                    if ([FMDBTools updateDowloaddelWithFile_name:name])
                    {
                        MMLog(@"修改成功！");
                    }
                }
            }

            MMLog(@"%@",error);
            [weakSelf removeActityLoading];
            if (tag)
            {
                [weakSelf downloadWithURLTag:tag];
            }
            
            NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
            if (self.xml_pre_Array.count)
            {
                
                for (NSDictionary *dic in xml_temp_arr)
                {
                    NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                    if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                    {
                        [self.xml_pre_Array removeObject:dic];
                        break;
                    }
                }
            }
            
            if (self.collectionDataSource.count)
            {
                xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                for (NSDictionary *dic in xml_temp_arr)
                {
                    NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                    if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                    {
                        [self.collectionDataSource removeObject:dic];
                        break;
                    }
                }
            }
            [weakSelf.collectionView reloadData];
            
        }];
        
    }
    else
    {
        [self removeActityLoading];
        if (tag)
        {
            [self downloadWithURLTag:tag];
        }
    }
}


#pragma mark ------------------ 点击下载文件 ------------------------------

//点击下载文件
- (void)clickDownloadFileWithFileName:(NSString *)fileName
{
    if (![self isCameraMacAddress])
    {
        return;
    }
    //手机存储小于500MB时
    if (![self Reserved])
    {
        [self addActityText:@"手机存储小于500MB,请清理手机存储空间" deleyTime:1.0];
        return;
    }
    [self addActityLoading:@"正在加载内容" subTitle:nil];
    NSString *file_Path = [[NSString alloc] init];
    
    if ([fileName containsString:@"/"])
    {
        file_Path  = fileName;
    }
    else
    {
        if ([fileName containsString:@"_pre"]||![fileName containsString:@"_"])
        {
            file_Path = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:fileName];//图片路径
        }
        else
        {
            //视频缩略图路径
            file_Path = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:fileName];
        }
    }
    
    
    
    //不存在就下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
        if ([fileName containsString:@"_pre"]||![fileName containsString:@"_"])
        {
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/Photo",_model.macAddress]];
        }
        else
        {
            
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/Video/Photo",_model.macAddress]];
        }
        
        NSString *file_Path = [documentsDirectoryURL absoluteString];
        // 判断文件夹是否存在，如果不存在，则创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        if ([fileName containsString:@"_pre"])//如果是图片缩略图
        {
            fileName = [NSString stringWithFormat:@"%@.jpg",[fileName componentsSeparatedByString:@"_pre"][0]];
        }
        
        //下载图片
        __weak typeof(self) weakSelf = self;
        NSString *url_str = [NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url, fileName];
        [RequestManager downloadWithURL:url_str savePathURL:documentsDirectoryURL progress:^(NSProgress *progress)
         {
             
         }
        succeed:^(id responseObject)
         {
             //判断是否下载过
             if (![FMDBTools selectDownloadWithFile_name:fileName])
             {
                 if ([FMDBTools saveDownloadFileWithFileName:fileName is_del:@"0"]) {
                     MMLog(@"保存成功！");
                 }
             }
             if ([fileName containsString:@"_"])//如果是视频缩略图,下载完图片还要继续下载视频
             {
                 AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                 MsgModel *msg = [[MsgModel alloc] init];
                 msg.cmdId = @"06";
                 msg.token = [SettingConfig shareInstance].deviceLoginToken;
                 
                 msg.msgBody =[fileName componentsSeparatedByString:@"."][0];
                 ZYLog(@"msg.msgBody = %@",msg.msgBody);
                 
                 //延迟2秒请求,防止没有返回数据
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     
                     [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                         
                         if ([msg.msgBody hasSuffix:@".mp4"])
                         {
                             
                             [weakSelf clickDownloadVideoWithFileName:msg.msgBody];
                         }
                         else
                         {
                             NSString *body = [NSString stringWithFormat:@"PHOTO/%@",fileName];
                             AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
                             MsgModel *requestMsg = [[MsgModel alloc] init];
                             requestMsg.cmdId = @"0A";
                             requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
                             requestMsg.msgBody = body;
                             [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
                                 
                                 if ([msg.msgBody isEqualToString:@"OK"])
                                 {
                                     [weakSelf addActityText:@"视频正在创建,在下个视频获取!!" deleyTime:1];
                                     
                                     if ([body containsString:@"_pre"])
                                     {
                                         [weakSelf.xml_pre_Array removeObjectAtIndex:_indexPath.row];
                                         [weakSelf deleteWithbody:body tag:1];
                                     }
                                     else
                                     {
                                         
                                         NSString *temp_str = [body componentsSeparatedByString:@"/"].lastObject;
                                         [FMDBTools updateDowloaddelWithFile_name:temp_str];
                                         NSString *filePath;
                                         if ([temp_str containsString:@"_"])
                                         {
                                             filePath = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                                             
                                         }
                                         else
                                         {
                                             filePath = [Photo_Path(_model.macAddress) stringByAppendingPathComponent:temp_str];
                                         }
                                         [weakSelf deleteDirInCache:filePath];
                                         [weakSelf.collectionDataSource removeObjectAtIndex:_indexPath.row];
                                         [weakSelf deleteWithbody:body tag:0];
                                     }
                                 }
                                 else
                                 {
                                     [weakSelf addActityText:@"删除失败" deleyTime:1];
                                 }
                                 
                             }];
                         }
                         
                         
                     }];
                 });
             }
             else//如果是图片就跳到图片浏览控制器
             {
                
                 [weakSelf removeActityLoading];
                 NSDictionary *dic;
                 if (weakSelf.xml_pre_Array.count)
                 {
                     if (weakSelf.xml_pre_Array.count == self.collectionDataSource.count)
                     {
                         dic = self.collectionDataSource[_indexPath.row];

         
         
                     }
                     else
                     {
                         dic = weakSelf.xml_pre_Array[_indexPath.row];

                     }
                 }
                 else
                 {
                     dic = self.collectionDataSource[_indexPath.row];

                 }
                 
                 
                 [weakSelf pushPhotoBrowserWith:VALUEFORKEY(dic, @"fileName")];

             }
             [weakSelf.collectionView reloadData];
             
         }
        andFailed:^(NSError *error)
         {
             NSString *temp_str = fileName;
             NSArray *pathArr;
             if ([temp_str containsString:@"_"])
             {
                 pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
             }
             else
             {
                 pathArr =[MyTools getAllDataWithPath:Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
             }
             
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
             [self removeActityLoading];
             NSMutableArray *xml_temp_arr = [self.xml_pre_Array mutableCopy];
             if (self.xml_pre_Array.count)
             {
                 
                 for (NSDictionary *dic in xml_temp_arr)
                 {
                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                     if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                     {
                         [self.xml_pre_Array removeObject:dic];
                         break;
                     }
                 }
             }
             
             if (self.collectionDataSource.count)
             {
                 xml_temp_arr = [weakSelf.collectionDataSource mutableCopy];
                 for (NSDictionary *dic in xml_temp_arr)
                 {
                     NSString *temp_fileName = VALUEFORKEY(dic, @"fileName");
                     if ([temp_fileName containsString:[temp_str componentsSeparatedByString:@"/"].lastObject])
                     {
                         [self.collectionDataSource removeObject:dic];
                         break;
                     }
                 }
             }
             [weakSelf.collectionView reloadData];
         }];
    }
    else
    {
        [self removeActityLoading];

        NSDictionary *dic;
        if (self.xml_pre_Array.count)
        {
            if (self.xml_pre_Array.count == self.collectionDataSource.count)
            {
               dic = self.collectionDataSource[_indexPath.row];


            }
            else
            {
                dic = self.xml_pre_Array[_indexPath.row];
            }
        }
        else
        {
           dic = self.collectionDataSource[_indexPath.row];
        }
        
        NSString *fileName = VALUEFORKEY(dic, @"fileName");
        if ([fileName containsString:@"_pre"]||![fileName containsString:@"_"])
        {
            [self pushPhotoBrowserWith:fileName];
        }
        else
        {
            
            fileName = [fileName componentsSeparatedByString:@"_"][0];
            fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
            NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(_model.macAddress) mac_adr:_model.macAddress];
            
            for (NSString *str in pathArr)
            {
                
                if ([str containsString:fileName])
                {
                    fileName = str;
                    NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
                    MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
                    playVC.videoURL = sourceMovieURL;
                    
                    if ([FORMATSTRING(VALUEFORKEY(dic, @"fileName")) containsString:@"/"])
                    {
                        playVC.imageURL = FORMATSTRING(VALUEFORKEY(dic, @"fileName"));
                    }
                    else
                    {
                        playVC.imageURL = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:VALUEFORKEY(dic, @"fileName")];;
                    }
                    
                    __weak typeof(self) weakSelf = self;
                    playVC.block =^{
                        
                        [weakSelf getCacheData];
                    };
                    [self.navigationController pushViewController:playVC animated:YES];
                    break;
                }
                
            }
            if (![fileName hasSuffix:@".mp4"]) {//会出现没有下载完成的情况,需重新下载
                fileName = VALUEFORKEY(dic, @"fileName");
                BOOL isdeleteVideo = [self deleteDirInCache:fileName];
                if (isdeleteVideo) {
                    fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
                    [self clickDownloadFileWithFileName:fileName];
                }
            }
            
            
        }
    }
    
    
    
}

#pragma mark ----------------- 直播视图 --------------------------
/**
 直播视图
 */
- (void)initVideoView {
    _videoPlayer = [[CameraVideoPlayer alloc] initWithFrame:self.videoBgImageView.bounds videoURLStr:self.videoLiveUrlStr];
    _videoPlayer.videoLiveRecUrlStr = self.videoLiveRecUrlStr;
    if (_model.bgImage) {
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", _model.ipAddress, _model.bgImage]];
        [_videoPlayer sd_setImageWithURL:imageUrl placeholderImage:nil];
    }
    
    [_videoBgImageView insertSubview:_videoPlayer atIndex:0];
    _videoPlayer.showControlView = NO;

}


#pragma mark ---------------------- 点击全屏按钮通知 --------------------------
/**
 点击全屏按钮通知

 @param notice 通知
 */
-(void)fullScreenBtnClick:(NSNotification *)notice{
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        // 恢复回小屏
        [self resumeViderPlayerToVideoBgImageView];
    }
}
// 全屏
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    // 如果是全屏，允许旋转
    [(AppDelegate *)APPDelegate setAllowRotation:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIDeviceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    [_videoPlayer removeFromSuperview];
    _videoPlayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s);
    _videoPlayer.ffmpegPlayer.outputWidth = SCREEN_WIDTH;
    _videoPlayer.ffmpegPlayer.outputHeight = SCREEN_HEIGHT_4s;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_videoPlayer];
    _videoPlayer.isFullscreen = YES;
    _videoPlayer.fullScreenBtn.selected = YES;
    [_videoPlayer bringSubviewToFront:_videoPlayer.topView];
    [_videoPlayer bringSubviewToFront:_videoPlayer.bottomView];
    
    _videoPlayer.showControlView = YES;
    
}

- (void)videoBackBtnClick:(NSNotification *)obj{
    
    [self resumeViderPlayerToVideoBgImageView];
}


#pragma mark ---------------- 播放视图复位(小屏) --------------------------

// 播放视图复位
- (void)resumeViderPlayerToVideoBgImageView {
    
    [_videoPlayer removeFromSuperview];

    _videoPlayer.showControlView = NO;
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIDeviceOrientationPortrait) {
        
        // 转回原来样子
        [(AppDelegate *)APPDelegate setAllowRotation:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val =UIDeviceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }

    }
    
    [UIView animateWithDuration:0.5f animations:^{
        _videoPlayer.frame = _videoBgImageView.bounds;
        _videoPlayer.ffmpegPlayer.outputWidth = SCREEN_WIDTH;
        _videoPlayer.ffmpegPlayer.outputHeight = VIEW_H(_videoBgImageView);
        [_videoBgImageView insertSubview:_videoPlayer atIndex:0];
        
    }completion:^(BOOL finished) {
        _videoPlayer.isFullscreen = NO;
        _videoPlayer.fullScreenBtn.selected = NO;
    }];

}


// 获取从fromDate 到toDate的时间
- (NSArray *)dateArrayFromDate:(NSString *)fromDateStr toDate:(NSString *)toDateStr {
    
    if ((fromDateStr.length == 0) && (toDateStr.length == 0)) {
        return nil;
    }
    
    // 获取两者之间的时间数组
    NSMutableArray *dateArr = [NSMutableArray array];
    if (fromDateStr.length == 0) {
        // 开始时间为空
        [dateArr addObject:toDateStr];
    } else if (toDateStr.length == 0) {
        // 结束时间为空
        [dateArr addObject:fromDateStr];
    } else if ([fromDateStr longLongValue] > [toDateStr longLongValue]) {
        return nil;
    } else if ([fromDateStr isEqualToString:toDateStr]){
        // 两个时间相等
        [dateArr addObject:fromDateStr];
    } else {
        // 两个时间不等
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDate *fromDate = [dateFormatter dateFromString:fromDateStr];
        NSDate *toDate = [dateFormatter dateFromString:toDateStr];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
        
        NSInteger day = dateComponents.day;
        for (NSInteger i = 0; i <= day; i++) {
            NSDate *tempDate = [NSDate dateWithTimeInterval:24 * 3600 * i sinceDate:fromDate];
            NSString *tempDateStr = [dateFormatter stringFromDate:tempDate];
            [dateArr addObject:tempDateStr];
        }
    }
    
    return dateArr;
}

// flag:0刚刚进来的时候 1点击开始游记的时候 2点击结束游记的时候
- (void)requestTime_lineDataWithFlag:(NSInteger)flag {
    NSString *lastUpdateDateStr = [CacheTool dateLastUpdateToCameraTimeLineWithUserId:UserName camereMac:self.model.macAddress];
    // 获取上次更新时间线的时间
    if (lastUpdateDateStr.length == 0) {
        // 没有，往前推10天
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 10; i >= 0; i--) {
            NSString *dateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMdd" date:[NSDate dateWithTimeIntervalSinceNow:-i*24*60*60]];
            
            [array addObject:dateStr];
        }
        _timeLineRequest_array = array;
    } else {
        // 请求当前时间到上一次更新时间线之间的数据
         NSString *currentDateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMdd" date:[NSDate date]];
         NSArray *dateArray = [self dateArrayFromDate:lastUpdateDateStr toDate:currentDateStr];
        _timeLineRequest_array = dateArray;
    }
    
    // 请求下标，当所有请求完成的时候才去补全游记或者刷新时间线
    _timeLineRequest_index = 0;
    if (_timeLineRequest_array.count == 0) {
        return;
    }
    [self requestTime_lineDataWithDate:_timeLineRequest_array[_timeLineRequest_index] flag:flag];

}

// flag:0刚刚进来的时候 1点击开始游记的时候 2点击结束游记的时候
- (void)requestTime_lineDataWithDate:(NSString *)dateString flag:(NSInteger)flag{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/log/cdr_log%@.xml", self.model.ipAddress, dateString];
    [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {
        
        NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
        NSArray *items = VALUEFORKEY(VALUEFORKEY(dic, @"log"), @"item");
        if ([items isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in items) {
                // 解析时间线数据入库
                [self parseDataWithItemDic:(NSDictionary *)dic dateString:dateString];
            }
        } else if ([items isKindOfClass:[NSDictionary class]]) {
            // 解析时间线数据入库
            [self parseDataWithItemDic:(NSDictionary *)items dateString:dateString];
        }
        
        _timeLineRequest_index++;
        if (_timeLineRequest_index >= _timeLineRequest_array.count) {
            //当所有请求完成的时候才去补全游记或者刷新时间线
            [self configTravelWithFlag:flag];
            [self loadTime_line_dateFromDBWithTimeString:time_line_timeLab.text];
            return;
        }
        // 不是最后一个请求 继续下一个请求
        [self requestTime_lineDataWithDate:_timeLineRequest_array[_timeLineRequest_index] flag:flag];
        
    } andFailed:^(NSError *error) {
        MMLog(@"%@",error);
        _timeLineRequest_index++;
        if (_timeLineRequest_index >= _timeLineRequest_array.count) {
            // 请求下标，当所有请求完成的时候才去补全游记或者刷新时间线
            [self configTravelWithFlag:flag];
            [self loadTime_line_dateFromDBWithTimeString:time_line_timeLab.text];
            return;
        }
        // 不是最后一个请求 继续下一个请求
        [self requestTime_lineDataWithDate:_timeLineRequest_array[_timeLineRequest_index] flag:flag];
        
    }];

}

#pragma mark -------------------- 将时间线数据解析入库 ------------------------------

/**
 将时间线数据解析入库

 @param dic 记录仪返回的数据字典
 @param dateString 时间
 */
- (void)parseDataWithItemDic:(NSDictionary *)dic dateString:(NSString *)dateString{
    // 只有一条数据的时候是数组
    CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    
    // 去掉“\n”
    model.type = [model.type stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    model.userId = UserName;
    model.cameraMac = self.model.macAddress;
    model.date = dateString;
    // 将数据插入到数据库
    [CacheTool insertimeLineWithCameraTime_lineModel:model];
    
    if (model.media.length) {
        // 如果有图片或者视频，异步下载图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 图片保存路径
            NSString *path = TimeLine_Photo_Path(model.cameraMac);
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                // 没有文件夹，创建文件夹
                [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", model.media]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                // 没有下载过的图片，下载
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", self.model.ipAddress,model.media]]];
                
                //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                [data writeToFile:imagePath atomically:YES];
            }
            
        });

    }
    
}


#pragma mark --------------------- 点击游记时将游记记录或者补全 ------------------------

/**
 点击游记时将游记记录或者补全

 @param flag 0刚刚进来的时候 1点击开始游记的时候 2点击结束游记的时候
 */
- (void)configTravelWithFlag:(NSInteger)flag {
   
    // 将游记开始时间和结束时间补全
    [self completeTravelStartTimeAndEndTimeWithFlag:flag];
    
    NSString *currentDateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMddHHmmss" date:[NSDate date]];
    NSMutableArray *travelArray = [CacheTool queryCameraTime_lineListWithDate:nil camereMac:self.model.macAddress userId:UserName];
    
    if (flag == 0) {
        return;
    }
    // 从后面往前面遍历
    CameraTime_lineModel *lastModel = [travelArray lastObject];
    for (NSInteger i = travelArray.count - 1; i >= 0; i--) {
        
        CameraTime_lineModel *model = [travelArray objectAtIndex:i];
        if (flag == 1) {
            // 点击开始按钮
            if ([model.type isEqualToString:@"Start CDR"]) {
                // 遇到开始 入库，并将Start CDR时间作为游记时间的开始 结束时间等于最后一个元素的时间
                AlbumsTravelModel *travelModel = [[AlbumsTravelModel alloc] init];
                travelModel.startTime = model.time;
                travelModel.endTime = lastModel.time;
                travelModel.cameraMac = model.cameraMac;
                travelModel.userId = model.userId;
                travelModel.startPostion = model.gps;
                travelModel.flag = @"3";
                
                BOOL insertOK = [CacheTool updateTravelWithTravelModel:travelModel];
                if (insertOK) {
                    NSMutableArray *uncompleteTravelsArray = [CacheTool queryTravelsUncompleteWithCameraMac:self.model.macAddress userName:UserName];
                    AlbumsTravelModel *lastInsertTravelModel = [uncompleteTravelsArray lastObject];
                    // 将游记详情解析入库
                    [self insertTravelDetailWithTravelModel:lastInsertTravelModel];
                }
                
                break;
            } else if ([model.type isEqualToString:@"Stop CDR"]) {
                // 遇到结束 把当前时间入库，并切标记为Start CDR将在后面的item中去获取
                AlbumsTravelModel *travelModel = [[AlbumsTravelModel alloc] init];
                travelModel.startTime = lastModel.time;
                travelModel.endTime = lastModel.time;
                travelModel.cameraMac = model.cameraMac;
                travelModel.userId = model.userId;
                travelModel.flag = @"1";
                [CacheTool updateTravelWithTravelModel:travelModel];
                break;
            }

        } else if (flag == 2) {
            NSMutableArray *uncompleteTravelsArray = [CacheTool queryTravelsUncompleteWithCameraMac:self.model.macAddress userName:UserName];
            AlbumsTravelModel *travelModel = [uncompleteTravelsArray lastObject];
            if (!travelModel) {
                break;
            }
            
            // 点击结束按钮
            if ([model.type isEqualToString:@"Stop CDR"]) {
                // 遇到结束 入库，并将Stop CDR时间作为游记时间的结束
                travelModel.endTime = model.time;
                travelModel.cameraMac = model.cameraMac;
                travelModel.userId = model.userId;
                travelModel.endPostion = model.gps;
                travelModel.endMileage = model.endMileage;
                travelModel.tirpMileage = model.tirpMileage;
                travelModel.flag = @"0";
                [CacheTool updateTravelWithTravelModel:travelModel];
                break;
            } else if ([model.type isEqualToString:@"Start CDR"]) {
                // 遇到开始 把当前时间入库，并切标记为stop CDR将在后面的item中去获取
                if ([travelModel.flag isEqualToString:@"3"]) {
                    // 找到了开始
                    travelModel.endTime = lastModel.time;
                    travelModel.flag = @"3";
                } else {
                    // 没有找到开始
                    travelModel.startTime = model.time;
                    travelModel.endTime = lastModel.time;
                    travelModel.flag = @"1";
                }
//                travelModel.endTime = currentDateStr;
                travelModel.cameraMac = model.cameraMac;
                travelModel.userId = model.userId;
                [CacheTool updateTravelWithTravelModel:travelModel];
                break;
            }
            
            // 将游记请求解析入库
            [self insertTravelDetailWithTravelModel:travelModel];

        }
    }
    
}
// 将游记开始时间和结束时间补全
- (void)completeTravelStartTimeAndEndTimeWithFlag:(NSInteger)flag {
    
    NSString *currentDateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMddHHmmss" date:[NSDate date]];
    // 没有补全的游记文件
    NSMutableArray *uncompleteTravelsArray = [CacheTool queryTravelsUncompleteWithCameraMac:self.model.macAddress userName:UserName];
    
    for (AlbumsTravelModel *travelModel in uncompleteTravelsArray) {
        
        if ([travelModel.flag integerValue] == 1) {
            // 该游记开始时间要在后面获取
            BOOL foundStart = NO;
            NSArray *timeLineArray = [CacheTool queryCameraTime_lineListAfterTime:travelModel.startTime camereMac:self.model.macAddress userId:UserName];
            CameraTime_lineModel *lastModel = [timeLineArray lastObject];
            for (CameraTime_lineModel *model in timeLineArray) {
                if ([model.type isEqualToString:@"Start CDR"]) {
                    // 遇到开始 入库，并将Start CDR时间作为游记时间的开始
                    travelModel.startTime = model.time;
                    travelModel.endTime = currentDateStr;
                    travelModel.cameraMac = model.cameraMac;
                    travelModel.userId = model.userId;
                    travelModel.startPostion = model.gps;
                    travelModel.flag = @"3";
//                    [CacheTool updateTravelWithTravelModel:travelModel];
                    
                    foundStart = YES;
                    
                    break;
                }
            }
            
            if (!foundStart) {
                travelModel.startTime = lastModel.time;
                travelModel.endTime = lastModel.time;
//                [CacheTool updateTravelWithTravelModel:travelModel];
            } else {
                // 找到了开始，往后找stop
                BOOL foundStop = NO;
                NSArray *timeLineArray2 = [CacheTool queryCameraTime_lineListAfterTime:travelModel.startTime camereMac:self.model.macAddress userId:UserName];
                for (CameraTime_lineModel *model2 in timeLineArray2) {
                    if ([model2.type isEqualToString:@"Stop CDR"]) {
                        // 找到了stop
                        travelModel.cameraMac = model2.cameraMac;
                        travelModel.userId = model2.userId;
                        travelModel.endTime = model2.time;
                        travelModel.flag = @"0";
                        travelModel.endPostion = model2.gps;
                        travelModel.endMileage = model2.endMileage;
                        travelModel.tirpMileage = model2.tirpMileage;
                        foundStop = YES;
                        break;
                    }
                }
                if (!foundStop) {
                    // 没找到stop
                    travelModel.endTime = lastModel.time;
                }
            }
            
            [CacheTool updateTravelWithTravelModel:travelModel];
            
        } else if ([travelModel.flag integerValue] == 3) {
            // 找到了开始 该游记结束时间要在后面获取
            BOOL foundStop = NO;
            NSArray *timeLineArray = [CacheTool queryCameraTime_lineListAfterTime:travelModel.endTime camereMac:self.model.macAddress userId:UserName];
            CameraTime_lineModel *lastModel = [timeLineArray lastObject];
            for (CameraTime_lineModel *model in timeLineArray) {
                if ([model.type isEqualToString:@"Stop CDR"]) {
                    
                    if ([model.time longLongValue] < [travelModel.startTime longLongValue]) {
                        continue;
                    }
                    
                    // 遇到结束 入库，并将Stop CDR时间作为游记时间的结束
                    travelModel.endTime = model.time;
                    travelModel.cameraMac = model.cameraMac;
                    travelModel.userId = model.userId;
                    travelModel.endPostion = model.gps;
                    travelModel.endMileage = model.endMileage;
                    travelModel.tirpMileage = model.tirpMileage;
                    travelModel.flag = @"0";
                    [CacheTool updateTravelWithTravelModel:travelModel];
                    
                    foundStop = YES;
                    break;
                }
            }
            
            if (!foundStop) {
                travelModel.endTime = lastModel.time;
                [CacheTool updateTravelWithTravelModel:travelModel];
            }

        }
        
        // 将游记请求解析入库
        [self insertTravelDetailWithTravelModel:travelModel];
    }
}

#pragma mark ----------------- 将游记详情存入数据库，即相应的时间线数据 --------------

// 将游记详情存入数据库，即相应的时间线数据
- (void)insertTravelDetailWithTravelModel:(AlbumsTravelModel *)model {
    
    // 从数据库读取从开始时间到结束时间的时间线数据
    NSArray *timeLineArray = [CacheTool queryCameraTime_lineListFromTime:model.startTime toTime:model.endTime camereMac:self.model.macAddress userId:UserName];
    if (timeLineArray.count == 0 && [model.flag isEqualToString:@"0"]) {
        // 空游记，过滤掉
        [CacheTool deleteEmptyTravelWithTravelId:model.travelId];
        return;
    }
    
    for (CameraTime_lineModel *timeLineModel in timeLineArray) {
        
        // 去掉@"Start CDR" @"Stop CDR" :@"App login" @"App login off"
        if ([timeLineModel.type isEqualToString:@"Start CDR"]) {
            continue;
        }
        if ([timeLineModel.type isEqualToString:@"Stop CDR"]) {
            continue;
        }
        
        if ([timeLineModel.type isEqualToString:@"App login"])
        {
            continue;
        }
        if ([timeLineModel.type isEqualToString:@"App login off"]) {
            continue;
        }
        
        if ([CacheTool isExistTravelDetailWithTime:timeLineModel.time travelId:model.travelId]) {
            // 已经有了的就不要插入了
            continue;
        }
        
        // 游记详情
        AlbumsTravelDetailModel *detailModel = [[AlbumsTravelDetailModel alloc] init];
        detailModel.travelId = model.travelId;
        detailModel.type = timeLineModel.type;
        detailModel.gps = timeLineModel.gps;
        detailModel.time = timeLineModel.time;
        detailModel.date = timeLineModel.date;
        detailModel.fileName = timeLineModel.media;
        
        if ((timeLineModel == [timeLineArray lastObject])) {
            model.endPostion = detailModel.gps;
            // 更新游记入库
            [CacheTool updateTravelWithTravelModel:model];
        }
        
        if (timeLineModel.media.length) {
            // 如果有图片或者视频，异步下载图片
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 游记路径
                NSString *Travelpath = [Travel_Path(_model.macAddress) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:Travelpath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:Travelpath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                // 游记图片路径
                NSString *travelImagePath = [Travelpath stringByAppendingString:[NSString stringWithFormat:@"/%@", timeLineModel.media]];
                // 时间线路径
                NSString *timeLinepath = TimeLine_Photo_Path(timeLineModel.cameraMac);
                // 时间线图片路径
                NSString *timeLineImagePath = [timeLinepath stringByAppendingString:[NSString stringWithFormat:@"/%@", timeLineModel.media]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:timeLineImagePath]) {
                    // 如果时间线里有图片，直接copy
                    
                    [[NSFileManager defaultManager] copyItemAtPath:timeLineImagePath toPath:travelImagePath error:nil];
                } else {
                    // 时间线里没有图片，下载
                    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", self.model.ipAddress,timeLineModel.media]]];
                    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                    [data writeToFile:travelImagePath atomically:YES];
                }
                
            });
        }
        // 更新入库
        [CacheTool updateTravelDetailWithDetailModel:detailModel];
    }
}

/**
 请求今天时间线数据，拍照完成的时候刷新今天数据
 */
- (void)requestTodayTime_lineData {

    NSString *dateStr = [MyTools getDateStringWithDateFormatter:@"yyyyMMdd" date:[NSDate date]];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/log/cdr_log%@.xml", self.model.ipAddress, dateStr];
    [RequestManager getRequestWithUrlString:urlString params:nil succeed:^(id responseObject) {

        NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
        NSArray *items = VALUEFORKEY(VALUEFORKEY(dic, @"log"), @"item");
        if (![items isKindOfClass:[NSArray class]]) {
            return;
        }

        for (NSDictionary *dic in items) {
            // j解析时间线入库
            [self parseDataWithItemDic:dic dateString:dateStr];
        }
        
        // 根据时间去数据库找时间线时间，刷新UI
        [self loadTime_line_dateFromDBWithTimeString:dateStr];
        // 增加游记图片 将游记开始时间和结束时间补全
        [self completeTravelStartTimeAndEndTimeWithFlag:0];

    } andFailed:^(NSError *error) {
        MMLog(@"%@",error);
    }];

}


#pragma mark ------------------- 根据时间去数据库找时间线时间，刷新UI(好像没用到) --------------

// 有网络，更新数据
- (void)updates {
    // 根据时间去数据库找时间线时间，刷新U
    [self loadTime_line_dateFromDBWithTimeString:time_line_timeLab.text];
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

#pragma mark ---------------- 获取循环视频数据 --------------------------

- (void)getCycleVideoData{

    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    MsgModel *requestMsg = [[MsgModel alloc] init];
    requestMsg.cmdId = @"04";
    requestMsg.token = [SettingConfig shareInstance].deviceLoginToken;
//    __weak typeof(self) weakSelf = self;
    [socketManager sendData:requestMsg receiveData:^(MsgModel *msg) {
//        ZYLog(@"===================%@=================",msg);
        ZYLog(@"04   msg = %@",msg.msgBody);
        [RequestManager getRequestWithUrlString:[NSString stringWithFormat:@"http://%@/tmp/%@", [SettingConfig shareInstance].ip_url,msg.msgBody] params:nil succeed:^(id responseObject) {
            NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
            ZYLog(@"==================%@",dic);
            NSDictionary *cdrMp4Dic = VALUEFORKEY(dic, @"cdrMp4");
            
            if ([[cdrMp4Dic allKeys] containsObject:@"mp4"]) {
                id mp4Array = VALUEFORKEY(cdrMp4Dic, @"mp4");
                
                if ([mp4Array isKindOfClass:[NSDictionary class]]) {//循环视频只有一个的时候返回的是一个字典
                    
                    if ([[mp4Array allKeys] containsObject:@"fileName"]) {//有时候只有index并没有fileName,这时候无视频
                        
                        [self.cycleVideoArray addObject:mp4Array];
                    }
                    
                }else{//循环视频多个的时候返回的是数组
                    
                    for (NSDictionary *dic in mp4Array) {
                        if ([[dic allKeys] containsObject:@"fileName"]) {//有时候只有index并没有fileName,这时候无视频
                            
                            [self.cycleVideoArray addObject:dic];
                        }
                    }
                    //整合排列顺序
                    NSArray *sortArray = [self sortArray:self.cycleVideoArray];
                    [self.cycleVideoArray removeAllObjects];
                    [self.cycleVideoArray addObjectsFromArray:sortArray];
                }
                
                
                [self.cyclevideoCollectionView reloadData];
            }
            
            
        } andFailed:^(NSError *error) {
            ZYLog(@"error = %@",error);
        }];
    }];
}
//整合排列顺序,把最新的排到最前面
- (NSArray *)sortArray:(NSArray *)array
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithInt:[VALUEFORKEY(obj2, @"index") intValue]] compare:[NSNumber numberWithInt:[VALUEFORKEY(obj1, @"index") intValue]]];
        return result;
    }];
    return sortedArray;
}

#pragma mark ---------------- 下载循环视频 --------------------------
//- (void)downloadCycleVideo:(NSString *)fileName
//{
//    //手机存储小于500MB时
//    if (![self Reserved])
//    {
//        [self addActityText:@"手机内存不足" deleyTime:1];
//        return;
//    }
//    
////    [self addActityLoading:@"正在加载内容" subTitle:nil];
//    NSString *file_Path = [[NSString alloc] init];
//    file_Path = [Video_Photo_Path(_model.macAddress) stringByAppendingPathComponent:fileName];
//    
//    //不存在就下载
//    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
//    {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
//        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/Video/cycle",_model.macAddress]];
//    
//        
//        NSString *file_Path = [documentsDirectoryURL absoluteString];
//        // 判断文件夹是否存在，如果不存在，则创建
//        if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
//        {
//            [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        else
//        {
//            NSLog(@"文件夹已存在");
//        }
//        
//        __weak typeof(self) weakSelf = self;
//        NSString *url_str = [NSString stringWithFormat:@"http://%@/video/%@", [SettingConfig shareInstance].ip_url, fileName];
//        [RequestManager downloadWithURL:url_str savePathURL:documentsDirectoryURL progress:^(NSProgress *progress) {
//            ZYLog(@"完成百分 = %lf%%",(progress.completedUnitCount + 0.0) / progress.totalUnitCount);
//        } succeed:^(id responseObject) {
//            ZYLog(@"responseObject = %@",responseObject);
//            //判断是否下载过
//            if (![FMDBTools selectDownloadWithFile_name:fileName])
//            {
//                if ([FMDBTools saveDownloadFileWithFileName:fileName is_del:@"0"]) {
//                    MMLog(@"保存成功！");
//                }
//            }
//        } andFailed:^(NSError *error) {
//            ZYLog(@"error = %@",error);
//            NSString *temp_str = fileName;
//            NSArray *pathArr;
//            
//            pathArr =[MyTools getAllDataWithPath:Video_Photo_Path(weakSelf.model.macAddress) mac_adr:weakSelf.model.macAddress];
//            
//            for (NSString *str in pathArr)
//            {
//                
//                if ([str containsString:temp_str])
//                {
//                    temp_str = str;
//                    break;
//                }
//            }
//            BOOL isdeleteVideo = [weakSelf deleteDirInCache:temp_str];
//            
//            if (isdeleteVideo)
//            {
//                MMLog(@"删除成功");
//                if ([FMDBTools selectDownloadWithFile_name:fileName])
//                {
//                    if ([FMDBTools updateDowloaddelWithFile_name:fileName])
//                    {
//                        MMLog(@"修改成功！");
//                    }
//                }
//            }
//        }];
//        
//        
//    }
//}

#pragma mark ---------------- 下载循环视频 --------------------------
- (void)downloadCycleVideo:(UICollectionView *)collectionView cell: (CameraDetailCycleVideoCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    
    
    NSDictionary *dic = self.cycleVideoArray[indexPath.row];
    NSString *fileName = VALUEFORKEY(dic, @"fileName");
    
    self.currentDownloadingFileName = fileName;
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    [cell downloadCycleVideoWithFileName:self.currentDownloadingFileName macAddress:_model.macAddress progress:^(CGFloat rate){
        
        //实时进度
        mutDic[@"rate"] = [NSString stringWithFormat:@"%.2lf%%",rate];
        //更换数据源
        [self.cycleVideoArray replaceObjectAtIndex:indexPath.row withObject:mutDic];
        //实时刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
           
        });
        
    } completion:^{//下载完成时调用
        self.downTag ++;
        if (self.downTag == self.downloadCycleVideoArray.count) {
            return ;
        }
        ZYLog(@"下载完成---------------------------%d",self.downTag);
        //取得下一个文件名
        self.currentDownloadingFileName = self.downloadCycleVideoArray[self.downTag];
        //取得文件对应的位置
        [self.cycleVideoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *name = VALUEFORKEY(dic, @"fileName");
            if ([self.currentDownloadingFileName isEqualToString:name]) {
                [self downloadCycleVideo:collectionView cell:cell indexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                
                *stop = YES;
            }
        }];
        
    }];
}

#pragma mark ---------------- 懒加载 --------------------------
//循环数据数组
-(NSMutableArray *)cycleVideoArray
{
    if (!_cycleVideoArray) {
        
        _cycleVideoArray = [NSMutableArray array];
        
    }
    return _cycleVideoArray;
}
//存放要下载循环视频的数组
-(NSMutableArray *)downloadCycleVideoArray
{
    if (!_downloadCycleVideoArray) {
        
        _downloadCycleVideoArray = [NSMutableArray array];
        
    }
    return _downloadCycleVideoArray;
}

@end
