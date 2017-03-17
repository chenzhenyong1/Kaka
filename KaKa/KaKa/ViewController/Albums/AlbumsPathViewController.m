//
//  AlbumsPathViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsPathViewController.h"
#import "AlbumsPathViewControllerTableViewCell.h"
#import "AlbumsPathDetailViewController.h"
#import "ZipArchive.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "AlbumsPathModel.h"
#import "MyTools.h"
#import "FMDBTools.h"
#import "PRGAnnotation.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "CameraListModel.h"
#import "GetIPAddress.h"
#import "EyeShareTrackController.h" //轨迹分享
#import <SystemConfiguration/CaptiveNetwork.h>
typedef void(^GetAddressBlock)(NSString *address);//获取返地理编码数据

@interface AlbumsPathViewController ()<UITableViewDataSource,UITableViewDelegate,BMKMapViewDelegate,AlbumsPathViewControllerTableViewCellDelegate,BMKGeoCodeSearchDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotationObjects; //标注数组
@property (nonatomic, copy) GetAddressBlock addressBlock;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) NSString *mac_address;
@end

@implementation AlbumsPathViewController
{
     NSMutableArray *download_arr;//下载文件数组
    NSMutableArray *file_arr;//文件数组
    
    
    NSMutableArray *location_arr;//坐标数组
    BMKPolyline *polyline;//画线
    NSInteger num;
    AlbumsPathModel *albumsPathModel;//数据模型
}

- (void)dealloc
{
    MMLog(@"释放");
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geoCodeSearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geoCodeSearch.delegate = nil;
}

#pragma mark - 懒加载

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    return _tableView;
}

-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    download_arr = [NSMutableArray array];
    file_arr = [NSMutableArray array];
    location_arr = [NSMutableArray array];
    _annotationObjects = [[NSMutableArray alloc] init];
    //初始化逆地理编码
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch = search;
    [self addTitleWithName:@"轨迹列表" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    
    [self addBackButtonWith:^(UIButton *sender) {
        
        
    }];

    [self addMapView];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    
    //数据下载完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Download_Completed:) name:@"DownloadCompleted" object:nil];
    
    //照片生成完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(data_finish) name:@"data_finish" object:nil];
    
    CameraListModel *model = [SettingConfig shareInstance].currentCameraModel;
    _mac_address = model.macAddress;
    
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
    
    /**
     判断当前的mac_address是否与当前连接的摄像头的mac_address相同
     相同就从摄像头下载轨迹数据
     不相同就从本地取出轨迹数据 生成轨迹
     */
    if ([BSSID isEqualToString:_mac_address])
    {
        if (model.macAddress.length)
        {
            //获取本地轨迹图片
            NSArray *path_photos = [MyTools getAllDataWithPath:Path_Photo(nil) mac_adr:nil];
            
            if (path_photos.count)
            {
                //获取数据库中的轨迹数据
                NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
                if (sql_arr.count)
                {
                    [self.dataSource removeAllObjects];
                    NSMutableArray *temp_arr = [NSMutableArray array];
                    for (AlbumsPathModel *model in sql_arr)
                    {
                        //判断数据库中是否存在这条轨迹
                        if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                            [temp_arr addObject:model];
                        }
                    }
                    self.dataSource = [temp_arr mutableCopy];
                    
                    self.dataSource = [self newArray:self.dataSource];//按时间排序
                    [self.tableView reloadData];
                }
            }
            
            //发送命令
            AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
            MsgModel *msg = [[MsgModel alloc] init];
            msg.cmdId = @"12";
            msg.token = [SettingConfig shareInstance].deviceLoginToken;
            __weak typeof(self) wself = self;
            [socketManager sendData:msg receiveData:^(MsgModel *msg) {
                
                [wself getPathDataWithBody:msg.msgBody];
                
            }];
            
        }
        else
        {
            //获取数据库中的轨迹数据
            NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
            if (sql_arr.count)
            {
                [self.dataSource removeAllObjects];
                NSMutableArray *temp_arr = [NSMutableArray array];
                for (AlbumsPathModel *model in sql_arr)
                {
                    //判断数据库中是否存在这条轨迹
                    if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                        [temp_arr addObject:model];
                    }
                }
                self.dataSource = [temp_arr mutableCopy];
                self.dataSource = [self newArray:self.dataSource];//按时间排序
                [self.tableView reloadData];
            }
            
        }
    }
    else
    {
        NSArray *path_arr = [MyTools getAllDataWithPath:Path_Path(nil) mac_adr:nil];
        if (path_arr.count)
        {
            
            NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
            if (sql_arr.count)
            {
                [self.dataSource removeAllObjects];
                NSMutableArray *temp_arr = [NSMutableArray array];
                for (AlbumsPathModel *model in sql_arr)
                {
                    if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                        [temp_arr addObject:model];
                    }
                }
                self.dataSource = [temp_arr mutableCopy];
                self.dataSource = [self newArray:self.dataSource];
            }
            AlbumsPathModel *model = self.dataSource.firstObject;
            _mac_address = model.mac_adr;
            [self addActityLoading:@"正在生成轨迹,请稍后" subTitle:nil];
            [self getImageWithTag:0];
        }
        else
        {
            NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
            if (sql_arr.count)
            {
                 [self.dataSource removeAllObjects];
                NSMutableArray *temp_arr = [NSMutableArray array];
                for (AlbumsPathModel *model in sql_arr)
                {
                    if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                        [temp_arr addObject:model];
                    }
                }
                self.dataSource = [temp_arr mutableCopy];
                self.dataSource = [self newArray:self.dataSource];
                [self.tableView reloadData];
            }
        }
    }
    
}


//遍历数组，将数据按时间重新排序
- (NSMutableArray *)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(AlbumsPathModel *obj1, AlbumsPathModel *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj2.fileName] longLongValue]] compare:[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj1.fileName] longLongValue]]];
        return result;
    }];
    [arr removeAllObjects];
    [arr addObjectsFromArray:sortedArray];
    
    return arr;
    
}

//获取时间
- (NSString *)getTimeWithFilePath:(NSString *)filePath
{
    NSString *file_path;
    file_path = [filePath componentsSeparatedByString:@"."].firstObject;
    file_path = [file_path componentsSeparatedByString:@"_"][1];
    return file_path;
    
}

//获取当前网络的mac_address
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


//添加地图
- (void)addMapView
{
    //设置地图
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s)];
    [self.view addSubview: _mapView];
    _mapView.delegate = self;
}


//资源下载完成通知
- (void)Download_Completed:(NSNotification *)not
{
    MMLog(@"我了个XX 竟然成功了啊啊啊啊啊!");
    [self removeActityLoading];
    [self addActityText:@"资源获取成功" deleyTime:1];
    
}


//照片生成成功
-(void)data_finish
{
    [self getDataWithFMDB];
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}


//保存数据库
- (void)getDataWithFMDB
{
    MMLog(@"数据保存完成啦");
    [self removeActityLoading];
    
    NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
    if (sql_arr.count)
    {
        [self.dataSource removeAllObjects];
        NSMutableArray *temp_arr = [NSMutableArray array];
        for (AlbumsPathModel *model in sql_arr)
        {
            if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                [temp_arr addObject:model];
            }
        }
        self.dataSource = [temp_arr mutableCopy];
        self.dataSource = [self newArray:self.dataSource];
        [self.tableView reloadData];
    }
}

//生成图片
- (void)getImageWithTag:(int)tag
{
    int finish_tag = tag;
    [location_arr removeAllObjects];
    
    CLLocationCoordinate2D coords[50000];
    NSArray *pathArr =[MyTools getAllDataWithPath:Path_Path(_mac_address) mac_adr:_mac_address];
    
    //finish_tag跟pathArr.count相同 表示图片生成完成
    if (finish_tag == pathArr.count)
    {
        MMLog(@"照片完成啦");
        
        //图片生成完成 删除数据源
        for (NSString *path_str in pathArr) {
            
            [[NSFileManager defaultManager] removeItemAtPath:path_str error:nil];
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"data_finish" object:nil];
    }
    else
    {
        //根据每一条轨迹数据 截取每一个经纬度
        NSData *data = [NSData dataWithContentsOfFile:pathArr[tag]];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *temp_arr = [json componentsSeparatedByString:@"\n"];
        
        
        for (NSString *tempStr in temp_arr)
        {
            NSArray *arr = [tempStr componentsSeparatedByString:@","];
            
            //判断数据的完整性
            if (arr.count == 13)
            {
                [location_arr addObject:tempStr];
            }
        }
        
        
        for (int i = 0; i <location_arr.count ; i ++)
        {
            coords[i] = [self getLocationWithGPRMC:location_arr[i]];
        }
        NSString *fileName = pathArr[tag];
        
        fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
        [_mapView removeOverlay:polyline];
        [_mapView removeAnnotations:_annotationObjects];
        [_annotationObjects removeAllObjects];
        polyline = nil;
        
        //生成轨迹
        [self addOverlayViewWithTag:finish_tag fileName:fileName coords:coords];
    }

    
}


//添加内置覆盖物
- (void)addOverlayViewWithTag:(int)tag fileName:(NSString *)fileName coords:(CLLocationCoordinate2D *)coords
{
    //添加折线(分段颜色绘制)覆盖物
    if (polyline == nil) {
        
        //构建BMKPolyline,使用分段颜色索引，其对应的BMKPolylineView必须设置colors属性
        polyline = [BMKPolyline polylineWithCoordinates:coords count:location_arr.count textureIndex:@[@0]];
    }
    [_mapView addOverlay:polyline];
    
    //计算最优视野
    double maxLon ,minLon ,maxLat , minLat;
    //经度
    maxLon = coords[0].longitude;
    minLon = coords[0].longitude;
    //纬度
    maxLat = coords[0].latitude;
    minLat = coords[0].latitude;
    
    for (int i = 0; i < location_arr.count; i++) {
        //最大纬度
        if (coords[i].latitude > maxLat) {
            maxLat = coords[i].latitude;
        }
        //最小纬度
        if (coords[i].latitude < minLat) {
            minLat = coords[i].latitude;
        }
        //最大经度
        if (coords[i].longitude > maxLon) {
            maxLon = coords[i].longitude;
        }
        //最小经度
        if (coords[i].longitude < minLon) {
            minLon = coords[i].longitude;
        }
        
        //获取轨迹经纬度第一个生成地址，并存入数据库
        if (i == 0)
        {
            num = 0;
            PRGAnnotation *annotation = [[PRGAnnotation alloc] init];
            
            annotation.coordinate = coords[i];
            
            [_mapView addAnnotation:annotation];
            [_annotationObjects addObject:annotation];
            AlbumsPathModel *model;
            fileName = [fileName componentsSeparatedByString:@"."][0];
            for (AlbumsPathModel *temp_model in self.dataSource)
            {
                if ([temp_model.fileName containsString:fileName])
                {
                    model = temp_model;
                    break;
                }
            }
            
            
            model.start_lat = [NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
            model.start_long = [NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
            [self GeoCodeSearchCoordinate:annotation.coordinate];
            __weak typeof(self) wself = self;
            self.addressBlock = ^(NSString *text)
            {
                model.start_address = text;
                [wself.tableView reloadData];
                NSString *file_name = [model.fileName componentsSeparatedByString:@"."][0];
                file_name = [file_name stringByAppendingString:@".png"];
                BOOL isSussess = [FMDBTools savePathDataWithStart_lat:model.start_lat start_long:model.start_long end_lat:model.end_lat end_long:model.end_long start_address:text file_name:model.fileName];
                if (isSussess)
                {
                    MMLog(@"保存成功！");
                }
                
            };
            
            
        }
        
        //获取经纬度数组最后一个 并存入数组
        if (i == location_arr.count-1)
        {
            num = 1;
            PRGAnnotation *annotation = [[PRGAnnotation alloc] init];
            
            annotation.coordinate = coords[i];
            
            [_mapView addAnnotation:annotation];
            [_annotationObjects addObject:annotation];
            
            AlbumsPathModel *model;
            fileName = [fileName componentsSeparatedByString:@"."][0];
            for (AlbumsPathModel *temp_model in self.dataSource)
            {
                if ([temp_model.fileName containsString:fileName])
                {
                    model = temp_model;
                    break;
                }
            }
            model.end_lat = [NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
            model.end_long = [NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
        }
        
        
        
    }
    
    /**
     使生成的轨迹显示在屏幕的最佳位置
     */
    BMKPointAnnotation * one = [[BMKPointAnnotation alloc]init];
    one.coordinate = CLLocationCoordinate2DMake(maxLat + (maxLat - minLat)/2, maxLon + (maxLon - minLon)/2);
    BMKPointAnnotation * two = [[BMKPointAnnotation alloc]init];
    two.coordinate = CLLocationCoordinate2DMake(minLat - (maxLat - minLat)/2, minLon - (maxLon - minLon)/2);
    [_mapView showAnnotations:@[one,two] animated:YES];
    
    
    //下载图片并保持
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:_mac_address];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Path/Photo/BigPhoto"];
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
    tag ++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *img = [self.mapView takeSnapshot:CGRectMake(0, (SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-720*PSDSCALE_Y)/2+50*PSDSCALE_Y, SCREEN_WIDTH, 720*PSDSCALE_Y)];
        //
        NSData *data = UIImagePNGRepresentation(img);
        NSString *filePath = [Path_Photo(_mac_address) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[fileName componentsSeparatedByString:@"."][0]]];
        //不存在就下载
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            MMLog(@"%@",filePath);
            MMLog(@"不存在");
            [data writeToFile:filePath atomically:NO];
            
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:_mac_address];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Path/Photo/SmallPhoto"];
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
            
            UIImage *img = [self.mapView takeSnapshot:CGRectMake(0, (SCREEN_HEIGHT_4s-NAVIGATIONBARHEIGHT-422*PSDSCALE_Y)/2, SCREEN_WIDTH, 422*PSDSCALE_Y)];
            NSData *data = UIImagePNGRepresentation(img);
            NSString *filePath = [Path_Small_Photo(_mac_address) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[fileName componentsSeparatedByString:@"."][0]]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                MMLog(@"%@",filePath);
                MMLog(@"不存在");
                [data writeToFile:filePath atomically:NO];
            }
            
        }
        else
        {
            
        }
        
        [self getImageWithTag:tag];
        
    });

}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"xidanMark"];
    
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"xidanMark"];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = NO;
    }
    
    for (UIView *subview in annotationView.subviews) {
        [subview removeFromSuperview];
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    if (num == 0)
    {
        // 设置位置
        annotationView.centerOffset = CGPointMake(-(annotationView.frame.size.width*0.5), 0);
        annotationView.image = GETNCIMAGE(@"albums_travel_start_icon");
    }
    else if (num == 1)
    {
        // 设置位置
        annotationView.centerOffset = CGPointMake(-(annotationView.frame.size.width*0.2),0);
        annotationView.image = GETNCIMAGE(@"albums_travel_end_icon");
    }
    
    annotationView.userInteractionEnabled = YES;
    return annotationView;
}




#pragma mark -
#pragma mark implement BMKMapViewDelegate

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{

    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        if (overlay == polyline) {
            polylineView.lineWidth = 5;
            /// 使用分段颜色绘制时，必须设置（内容必须为UIColor）
            polylineView.colors = [NSArray arrayWithObjects: RGBSTRING(@"2dbae4"), nil];
        } else {
            
        }
        return polylineView;
    }
    
    
    return nil;
}

- (void)GeoCodeSearchCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    //初始化逆地理编码类
    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    //需要逆地理编码的坐标位置
    reverseGeoCodeOption.reverseGeoPoint = coordinate;

    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    
}

#pragma mark - BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    self.addressBlock(result.address);
}





//解析获取经纬度
- (CLLocationCoordinate2D)getLocationWithGPRMC:(NSString *)cprmc
{
    
//    cprmc = @"$GPRMC,,,,,,,,,,,,A*2C";
    NSArray *temp_arr = [cprmc componentsSeparatedByString:@","];
    NSString *latitude_str1 = temp_arr[3];
    NSString *longitude_str1 = temp_arr[5];
    
    NSString *latitude_str2 = [latitude_str1 substringToIndex:2];
    NSString *longitude_str2 = [longitude_str1 substringToIndex:3];
    
    latitude_str1 = [latitude_str1 substringFromIndex:2];
    longitude_str1 = [longitude_str1 substringFromIndex:3];
    
    float latitude = [latitude_str2 intValue] + [latitude_str1 floatValue]/60;
    float longitude = [longitude_str2 intValue] + [longitude_str1 floatValue]/60;
    
    //1.创建经纬度结构体
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    
    center = BMKCoorDictionaryDecode(BMKConvertBaiduCoorFrom(center,BMK_COORDTYPE_GPS));//转换后的百度坐标
    
    return center;
}





//获取轨迹数据
-(void)getPathDataWithBody:(NSString *)body
{
    
    [self addActityLoading:@"正在从摄像头中获取轨迹资源,请稍后" subTitle:nil];
    [RequestManager getRequestWithUrlString:[NSString stringWithFormat:@"http://%@/tmp/%@",[SettingConfig shareInstance].ip_url,body] params:nil succeed:^(id responseObject) {
        NSDictionary *dic = [WHC_XMLParser dictionaryForXMLString:[responseObject mj_JSONString]];
        NSDictionary *cdrGps = VALUEFORKEY(dic, @"cdrGps");
        
        if (![[cdrGps allKeys] containsObject:@"zip"])
        {
            [self removeActityLoading];
            [self addActityText:@"暂无轨迹资源!" deleyTime:1];
            return;
        }
        
        
        [self.dataSource removeAllObjects];
        if ([VALUEFORKEY(cdrGps, @"zip") isKindOfClass:[NSArray class]])
        {
            if ([VALUEFORKEY(cdrGps, @"zip") count] > 0)
            {
                for (NSDictionary *temp_dic in VALUEFORKEY(cdrGps, @"zip"))
                {
                    
                    AlbumsPathModel *model = [[AlbumsPathModel alloc] init];
                    model.fileName = VALUEFORKEY(temp_dic, @"fileName");
                    model.endMileage = VALUEFORKEY(temp_dic, @"endMileage");
                    model.index = VALUEFORKEY(temp_dic, @"index");
                    model.startMileage = VALUEFORKEY(temp_dic, @"startMileage");
                    model.tirpMileage = VALUEFORKEY(temp_dic, @"tirpMileage");
                    model.tirpTime = VALUEFORKEY(temp_dic, @"tirpTime");
                    model.mac_adr = _mac_address;
                    
                    
                    NSString *file_name = [model.fileName componentsSeparatedByString:@"."][0];
                    file_name = [file_name stringByAppendingString:@".png"];
                    if (![FMDBTools selectPathWithFile_name:file_name userName:UserName])
                    {
                        BOOL isSussess =  [FMDBTools savePathDataWithFile_name:file_name collect:@"0" del:@"0" user_name:UserName mac_adr:self.mac_address endMileage:model.endMileage startMileage:model.startMileage tirpMileage:model.tirpMileage tirpTime:model.tirpTime];
                        
                        if (isSussess)
                        {
                            MMLog(@"保存成功！");
                        }
                        [self.dataSource addObject:model];
                        [file_arr addObject:temp_dic];
                    }
                    
                }
            }
            
        }
        else
        {
            NSDictionary *dic = VALUEFORKEY(cdrGps, @"zip");
            AlbumsPathModel *model = [[AlbumsPathModel alloc] init];
            model.fileName = VALUEFORKEY(dic, @"fileName");
            model.endMileage = VALUEFORKEY(dic, @"endMileage");
            model.index = VALUEFORKEY(dic, @"index");
            model.startMileage = VALUEFORKEY(dic, @"startMileage");
            model.tirpMileage = VALUEFORKEY(dic, @"tirpMileage");
            model.tirpTime = VALUEFORKEY(dic, @"tirpTime");
            model.mac_adr = _mac_address;
            
            
            NSString *file_name = [model.fileName componentsSeparatedByString:@"."][0];
            file_name = [file_name stringByAppendingString:@".png"];
            if (![FMDBTools selectPathWithFile_name:file_name userName:UserName])
            {
                BOOL isSussess =  [FMDBTools savePathDataWithFile_name:file_name collect:@"0" del:@"0" user_name:UserName mac_adr:self.mac_address endMileage:model.endMileage startMileage:model.startMileage tirpMileage:model.tirpMileage tirpTime:model.tirpTime];
                
                if (isSussess)
                {
                    MMLog(@"保存成功！");
                }
                [self.dataSource addObject:model];
                [file_arr addObject:dic];
            }
            
        }
        MMLog(@"%@",dic);
        if (file_arr.count)
        {
            //数据遍历
            [self Traversal_file];
        }
        else
        {
            [self removeActityLoading];
            [self.mapView removeFromSuperview];
            self.mapView = nil;
            NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
            if (sql_arr.count)
            {
                [self.dataSource removeAllObjects];
                NSMutableArray *temp_arr = [NSMutableArray array];
                for (AlbumsPathModel *model in sql_arr)
                {
                    if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                        [temp_arr addObject:model];
                    }
                }
                self.dataSource = [temp_arr mutableCopy];
                self.dataSource = [self newArray:self.dataSource];
                [self.tableView reloadData];
            }
        }
        
    } andFailed:^(NSError *error) {
        [self removeActityLoading];
        
    }];
}

//遍历文件夹中是否存在文件
-(void)Traversal_file
{
    [file_arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSString *file_name = VALUEFORKEY((NSDictionary *)obj, @"fileName");
            NSString *file_Path = [[NSString alloc] init];
            file_name = [file_name componentsSeparatedByString:@".zip"][0];
            file_Path = [Path_Path(_mac_address) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gp",file_name]];
            //不存在就下载
            if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
            {
                [download_arr addObject:obj];
            }
        }
    }];
    
    if (download_arr.count > 0)
    {
        [self downloadWithURLTag:0];
    }
}


- (void)downloadWithURLTag:(int)tag
{
    
    __block int finish_download_tag = tag;
    __weak typeof(self) weakSelf = self;
    if (finish_download_tag == download_arr.count)
    {
        MMLog(@"资源下载完成");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadCompleted" object:nil];
    }
    else
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:_mac_address];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Path/Path"];
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
        NSString *url_str = VALUEFORKEY(download_arr[tag], @"fileName");
        url_str = [NSString stringWithFormat:@"http://%@/GPSTrail/%@",[SettingConfig shareInstance].ip_url,url_str];
        [RequestManager downloadWithURL:url_str savePathURL:documentsDirectoryURL progress:^(NSProgress *progress)
         {
             
         }
        succeed:^(id responseObject)
         {
             NSString *file_Path = [[NSString alloc] init];

             file_Path = [Path_Path(_mac_address) stringByAppendingPathComponent:VALUEFORKEY(download_arr[tag], @"fileName")];
             ZipArchive *zip = [[ZipArchive alloc] init];
             if ([zip UnzipOpenFile:file_Path]) {
                 BOOL success;
                 if (zip.numFiles > 1)
                 {
                     NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                     documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
                     documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:_mac_address];
                     documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Path/Path"];
                     NSString *file_name = VALUEFORKEY(download_arr[tag], @"fileName");
                     file_name = [file_name componentsSeparatedByString:@".zip"][0];
                     documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",file_name]];
                     NSString *filePath = [documentsDirectoryURL absoluteString];
                     // 判断文件夹是否存在，如果不存在，则创建
                     if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                     {
                         [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
                     }
                     else
                     {
                         NSLog(@"文件夹已存在");
                     }
                     NSString *temp_file_path = [Path_Path(_mac_address) stringByAppendingPathComponent:file_name];
                     success = [zip UnzipFileTo:temp_file_path overWrite:YES];
                     NSData *data = [self Mosaic_dataWithfilePath:temp_file_path];
                     
                     NSString *temp_path = [Path_Path(_mac_address) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gp",file_name]];
                     
                     //不存在就下载
                     if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                     {
                         [data writeToFile:temp_path atomically:NO];
                     }
                     [[NSFileManager defaultManager] removeItemAtPath:temp_file_path error:nil];
                 }
                 else
                 {
                     success = [zip UnzipFileTo:Path_Path(_mac_address) overWrite:YES];
                 }
                 
                 if (success)
                 {
                     NSLog(@"解压成功---%ld",zip.numFiles);
                     [zip UnzipCloseFile];
                     [[NSFileManager defaultManager] removeItemAtPath:file_Path error:nil];
                 }
             }
             
             finish_download_tag ++;
             [weakSelf downloadWithURLTag:finish_download_tag];
             
         }
        andFailed:^(NSError *error)
         {
             finish_download_tag ++;
             [weakSelf downloadWithURLTag:finish_download_tag];
             MMLog(@"%@",error);
         }];
    }
    
    
    
}


//拼接数据
- (NSData *)Mosaic_dataWithfilePath:(NSString *)filePath
{
    NSArray *pathArr =[MyTools getAllDataWithPath:filePath  mac_adr:_mac_address];
    NSData *mosaic_data = [[NSData alloc] init];
    NSMutableArray *all_loc_arr = [[NSMutableArray alloc] init];
    NSString *all_loc_str = [[NSString alloc] init];
    if ([pathArr isKindOfClass:[NSArray class]])
    {
        if (pathArr.count)
        {
            
            for (int i = 0; i < pathArr.count; i ++)
            {
                NSData *data = [NSData dataWithContentsOfFile:pathArr[i]];
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSMutableArray *temp_arr = [[json componentsSeparatedByString:@"\n"] mutableCopy];
                if (i != 0)
                {
                    [temp_arr removeObjectAtIndex:0];
                }
                
                for (NSString *loc in temp_arr)
                {
                    [all_loc_arr addObject:loc];
                }
            }

        }
    }
    
    for (NSString *loc_str in all_loc_arr)
    {
        all_loc_str = [all_loc_str stringByAppendingString:[NSString stringWithFormat:@"\n%@",loc_str]];
    }
    if ([all_loc_str hasPrefix:@"\n"])
    {
        all_loc_str = [all_loc_str substringFromIndex:1];
    }
    
    mosaic_data =[all_loc_str dataUsingEncoding:NSUTF8StringEncoding];
    return mosaic_data;
}






#pragma mark - ======================UITableViewDataSource=========================
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumsPathViewControllerTableViewCell *cell = [AlbumsPathViewControllerTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    [cell refreshData:self.dataSource[indexPath.row]];
    return cell;
}

#pragma mark - =====================UITableViewDelegate===========================
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 691*PSDSCALE_Y;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlbumsPathDetailViewController *albumsPathDetailVC = [[AlbumsPathDetailViewController alloc] init];
    albumsPathDetailVC.num = indexPath.row;
    albumsPathDetailVC.superVC = self;
    albumsPathDetailVC.model = self.dataSource[indexPath.row];
    albumsPathDetailVC.block = ^{
        
        NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
        if (sql_arr.count)
        {
            [self.dataSource removeAllObjects];
            NSMutableArray *temp_arr = [NSMutableArray array];
            for (AlbumsPathModel *model in sql_arr)
            {
                if (![FMDBTools selectPathIsDelWithFile_name:model.fileName userName:UserName]) {
                    [temp_arr addObject:model];
                }
            }
            self.dataSource = [temp_arr mutableCopy];
            self.dataSource = [self newArray:self.dataSource];
            [self.tableView reloadData];
        }
        
    };
    [self.navigationController pushViewController:albumsPathDetailVC animated:YES];
}

#pragma mark - =========================AlbumsPathViewControllerTableViewCellDelegate==================
- (void)deleteDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell
{
    albumsPathModel = cell.model;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您确定删除此记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
}


#pragma mark - =========================UIAlertViewDelegate=====================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            BOOL isSussess = [FMDBTools updatePathdelWithFile_name:albumsPathModel.fileName userName:UserName];
            
            if (isSussess) {
                
                NSString *temp_path = [Path_Photo(albumsPathModel.mac_adr) stringByAppendingPathComponent:albumsPathModel.fileName];
                //判断本地是否存在
                if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path])
                {
                    //删除文件
                    BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:temp_path error:nil];
                    
                    if (isSuccess)
                    {
                        temp_path = [Path_Small_Photo(albumsPathModel.mac_adr) stringByAppendingPathComponent:albumsPathModel.fileName];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path])
                        {
                            if ([[NSFileManager defaultManager] removeItemAtPath:temp_path error:nil])
                            {
                                NSMutableArray *sql_arr = [FMDBTools getPathsFromDataBaseWithUser_name:UserName];
                                if (sql_arr.count)
                                {
                                    [self.dataSource removeAllObjects];
                                    NSMutableArray *temp_arr = [NSMutableArray array];
                                    for (AlbumsPathModel *model in sql_arr)
                                    {
                                        if (![model.del intValue])
                                        {
                                            [temp_arr addObject:model];
                                        }
                                    }
                                    self.dataSource = [temp_arr mutableCopy];
                                    self.dataSource = [self newArray:self.dataSource];
                                    [self.tableView reloadData];
                                }
                            }
                        }
                    }
                    
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)collectDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell {
    // 收藏
    if ([FMDBTools selectContactMember:[NSString stringWithFormat:@"%@", cell.model.fileName] userName:UserName])
    {
        [self addActityText:@"不能重复收藏" deleyTime:1];
        return;
    }
    
    if ([FMDBTools saveContactsWithImageUrl:[NSString stringWithFormat:@"%@", cell.model.fileName] type:kCollectTypePath])
    {
        [self addActityText:@"收藏成功" deleyTime:1];
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
    }
    else
    {
        [self addActityText:@"收藏失败" deleyTime:1];
    }

}

//分享
- (void)shareDataWithCell:(AlbumsPathViewControllerTableViewCell *)cell
{
    
//      ZYLog(@"row = %@",cell.model);
    EyeShareTrackController *ctl = [EyeShareTrackController new];
    
    ctl.model = cell.model;
    
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
