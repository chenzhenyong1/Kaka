//
//  EyeSelectedAdressController.m
//  KaKa
//
//  Created by 陈振勇 on 16/10/19.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeSelectedAdressController.h"

@interface EyeSelectedAdressController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

/** 地图视图  */
@property (nonatomic,strong) BMKMapView *mapView;
/** 定位服务  */
@property (nonatomic,strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) BMKPointAnnotation *annotation;
@end

@implementation EyeSelectedAdressController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    // 初始化地图
    [self initMap];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = self;
    _geoCodeSearch.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
}
/**
 *  设置导航栏
 */
- (void)setupNav
{
    self.title = @"地点选择";
    self.view.backgroundColor = ZYGlobalBgColor;
    
    [self setupNavBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];
}

- (void)rightClick
{
    self.addressBlock(self.annotation.subtitle);
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 初始化地图
- (void) initMap
{
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
//    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.zoomLevel = 9;

    [self.view addSubview:_mapView];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    _locService.distanceFilter = 10.0;
    
    
    //初始化逆地理编码
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch = search;
}

#pragma mark -- BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    ZYLog(@"didUpdateBMKUserLocation");
    
    //展示定位
//    self.mapView.showsUserLocation = YES;
    
    //更新位置数据
    [self.mapView updateLocationData:userLocation];
    
    //获取用户的坐标
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    
    self.mapView.zoomLevel = 18;
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = userLocation.location.coordinate.latitude;
    coor.longitude = userLocation.location.coordinate.longitude;
    annotation.coordinate = coor;
    annotation.title = @"选择的地点";
//    annotation.subtitle = userLocation.location.description;
    self.annotation = annotation;
    [_mapView addAnnotation:annotation];
    
    
    //关闭定位服务
    [self.locService stopUserLocationService];
}


#pragma mark -- BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        [self GeoCodeSearchCoordinate:annotation.coordinate];
        
        return newAnnotationView;
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
    self.annotation.subtitle = result.address;
}


#pragma mark -- touch View
-(void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    [self GeoCodeSearchCoordinate:coordinate];
    self.annotation.coordinate = coordinate;
}



@end
