//
//  EyeAroundViewController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/19.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAroundViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import "EyeSubjectsModel.h"
#import "ThumbList.h"
#import <GDRSImageCache.h>
#import "BMKClusterManager.h"  //点聚合管理类
#import "EyeClusterAnnotation.h"//点聚合大头针
#import "EyeClusterAnnotationView.h"//点聚合AnnotationView
#import "EyeClusterItem.h"
#import "EyeTopicListController.h"
#import "EyeAroundTopicDetailController.h"
#import "TMCache.h"

/** 每页话题数量  */
#define pageSize 200


@interface EyeAroundViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,SDWebImageManagerDelegate>
/** 地图视图  */
@property (nonatomic,strong) BMKMapView *mapView;
/** 定位服务  */
@property (nonatomic,strong) BMKLocationService *locService;
/** 查询的记录数  */
@property (nonatomic, assign) NSUInteger recordCount;
/** 页的序号  */
@property (nonatomic, assign) NSInteger pageIndex;
/** 页的总数  */
@property (nonatomic, assign) NSUInteger pageNum;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *aroundDataArr;

/** 点聚合管理类 */
@property (nonatomic, strong) BMKClusterManager *clusterManager;
/** 聚合级别  */
@property (nonatomic, assign) NSInteger clusterZoom;
/** 点聚合缓存标注 */
@property (nonatomic, strong) NSMutableArray *clusterCaches;
/** 图片下载管理类 */
@property (nonatomic, strong) SDWebImageManager *imageManager;

/** 要传递的话题列表数组 */
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation EyeAroundViewController


#pragma mark -- lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 初始化地图
    [self initMap];
    
//    [self loadDataFromCache];
    
    //获取附近数据
    [self loadNewLatestData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

#pragma mark -- 下载数据
- (void)loadNewLatestData
{
    
//    [self.clusterCaches removeAllObjects];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"recordCountOnly"] = @"true";
    
    [HttpTool get:Subjects_URL params:params success:^(id responseObj) {
        
        NSString *recordCount = responseObj[@"result"][@"recordCount"];
        
        self.recordCount = [recordCount integerValue];
        
        if (self.recordCount % pageSize != 0) {
            
            self.pageNum = self.recordCount / pageSize == 0 ? 1 : self.recordCount / pageSize + 1;
        }else{
            self.pageNum = self.recordCount / pageSize;
        }
        //获取附近数据
        [self loadAroundData];
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
    }];
    
}
/**
 *  获取附近数据
 */
- (void)loadAroundData
{
    self.pageIndex = 1;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"loginToken"] = LoginToken;
    params[@"pageSize"] = [NSString stringWithFormat:@"%d",pageSize];
    params[@"pageIndex"] = [NSString stringWithFormat:@"%ld",self.pageIndex];
    params[@"nearBy"] = [NSString stringWithFormat:@"%lf,%lf",self.mapView.centerCoordinate.longitude,self.mapView.centerCoordinate.latitude];
    
    ZYLog(@"params = %@",params);
    
    [HttpTool get:Subjects_URL params:params success:^(id responseObj) {
        
        
//        ZYLog(@"loadAroundData  responseObj = %@",responseObj);
        NSArray *aroundDataArr = [EyeSubjectsModel mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"recordList"]];
        //清楚所有的旧数据
        [self.aroundDataArr removeAllObjects];
        //再添加新数据
        [self.aroundDataArr addObjectsFromArray:aroundDataArr];
        
        ZYLog(@"aroundDataArr = %ld",self.aroundDataArr.count);
        //清楚清除items
        [self.clusterManager clearClusterItems];
        for (EyeSubjectsModel *model in self.aroundDataArr) {
            
            [self addAnnotation:model];
            
        }
        [self updateClusters];
        
    } failure:^(NSError *error) {
        
        ZYLog(@"error = %@",error);
        
    }];
}

#pragma mark -- 添加地图标注
- (void)addAnnotation:(EyeSubjectsModel *)model
{
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [model.lon doubleValue];
    coordinate.latitude = [model.lat doubleValue];
    
    //向点聚合管理类中添加标注
    EyeClusterItem *clusterItem = [[EyeClusterItem alloc] init];
    clusterItem.coor = coordinate;
    clusterItem.model = model;
    [self.clusterManager addClusterItem:clusterItem];
    
//    [self updateClusters];
}

/**
 *  更新聚合状态
 */
- (void)updateClusters
{
    _clusterZoom = (NSInteger)self.mapView.zoomLevel;
    
    @synchronized(self.clusterCaches) {
        __block NSMutableArray *clusters = [self.clusterCaches objectAtIndex:(_clusterZoom - 3)];
        
        if (clusters.count > 0) {
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ///获取聚合后的标注
                __block NSArray *array = [self.clusterManager getClusters:_clusterZoom];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (int i=0;i<[array count];i++) {
                        BMKCluster *item=array[i];
                        EyeClusterAnnotation *annotation = [[EyeClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.size = item.size;
                        //聚合后的标注模型数组
                        [annotation.itemArr addObjectsFromArray:item.clusterItems];
                        
                        EyeClusterItem *clusterItem = (EyeClusterItem *)item.clusterItems[item.clusterItems.count - 1];
                        ThumbList *thumbList = clusterItem.model.thumbList[0];
                        annotation.imgUrl = thumbList.thumbUrl;
                        
                        [clusters addObject:annotation];
                    }
                    
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView addAnnotations:clusters];
                    
                });
            });
        }
    }
    
}

#pragma mark -- BMKMapViewDelegate

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    EyeClusterAnnotation *pointAnnotation = (EyeClusterAnnotation *)annotation;

    ZYLog(@"annotation.imgUrl = %@",pointAnnotation.imgUrl);

    
    //普通annotation
    NSString *AnnotationViewID = @"ClusterMark";
    EyeClusterAnnotation *cluster = (EyeClusterAnnotation*)annotation;
    
    EyeClusterAnnotationView *annotationView = [[EyeClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    annotationView.canShowCallout = NO;//在点击大头针的时候会弹出那个黑框框
    annotationView.draggable = NO;//禁止标注在地图上拖动
    annotationView.annotation = cluster;
    
    //大头针的尺寸大小
    CGSize newAnnotationViewSize = CGSizeMake(58, 38);
    annotationView.image = [UIImage imageNamed:@"find_around_topicBackground"];
    
    //调整网络下载图片的大小
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        GDRSImageCache *cache = [[GDRSImageCache alloc] initWithCachedImageFilter:^UIImage *(UIImage *sourceImage) {
            
            return [sourceImage gdrs_resizedImageToAspectFitSize:newAnnotationViewSize cornerRadius:0];
            
        }];
        
        annotationView.image = [cache fetchImageWithURL:[NSURL URLWithString:pointAnnotation.imgUrl] completionHandler:^(UIImage *image, NSError *error) {
            annotationView.image = image;
            annotationView.size = cluster.size;
        }];
        
        
    });
    
    annotationView.frame.size = newAnnotationViewSize;
    return annotationView;
}

/**
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [self updateClusters];
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapview 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
        [self updateClusters];
    }
}
/**
 *  点击标注
 *
 *  @param mapView mapView description
 *  @param view    聚合后的标注
 */
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    
    if ([view isKindOfClass:[EyeClusterAnnotationView class]]) {
        
        EyeClusterAnnotation *clusterAnnotation = (EyeClusterAnnotation*)view.annotation;
        //先删除原来的数据
        [self.dataArr removeAllObjects];
        
        for (EyeClusterItem *item in clusterAnnotation.itemArr) {
            
            [self.dataArr addObject:item.model];
            
        }
        
        ZYLog(@"modelArr.count = %ld",clusterAnnotation.itemArr.count);
        ZYLog(@"clusterAnnotation.size = %ld",clusterAnnotation.size);
        
        if (self.dataArr.count > 1) {//跳转到附近话题列表
            
            EyeTopicListController *topicListCtl = [[EyeTopicListController alloc] init];
            
            topicListCtl.dataArr = self.dataArr;
            
            [self.navigationController pushViewController:topicListCtl animated:YES];
            
        }else{//跳转到附近话题详细信息
            
            EyeAroundTopicDetailController *detailCtl = [[EyeAroundTopicDetailController alloc] init];
            
            detailCtl.subjectModel = self.dataArr[0];
            
            [self.navigationController pushViewController:detailCtl animated:YES];
        }
        
    }
    
    
     [_mapView deselectAnnotation:view.annotation animated:YES];
}
#pragma mark -- 初始化地图
- (void) initMap
{
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.zoomLevel = 9;
    
    //添加刷新按钮
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    
    [refreshBtn sizeToFit];
    [_mapView addSubview:refreshBtn];
    
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(_mapView.mas_right).offset(-8);
        
        make.bottom.equalTo(_mapView.mas_bottom).offset(-200);
        
    }];
    
    
    [self.view addSubview:_mapView];

    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    _locService.distanceFilter = 10.0;
    
}

- (void)refresh
{
    [_locService startUserLocationService];
    
    //获取附近数据
    [self loadNewLatestData];
    
}


#pragma mark -- BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    ZYLog(@"didUpdateBMKUserLocation");
    
    //展示定位
    self.mapView.showsUserLocation = YES;
    
    //更新位置数据
    [self.mapView updateLocationData:userLocation];
    
    //获取用户的坐标
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    
    self.mapView.zoomLevel = 15;
    
    //关闭定位服务
    [self.locService stopUserLocationService];
}

#pragma mark -- property

-(SDWebImageManager *)imageManager
{
    if (!_imageManager) {
        _imageManager = [SDWebImageManager sharedManager];
        
        _imageManager.delegate = self;
        
    }
    
    return _imageManager;
}


-(BMKClusterManager *)clusterManager
{
    if (!_clusterManager) {
        
        _clusterManager = [[BMKClusterManager alloc] init];
    }
    
    return _clusterManager;
}


-(NSMutableArray *)clusterCaches
{
    if (!_clusterCaches) {
        
        _clusterCaches = [NSMutableArray array];
        
        for (NSInteger i = 3; i <= 21; i++) {
           
            [_clusterCaches addObject:[NSMutableArray array]];
        
        }
    }
    return _clusterCaches;
}



-(NSMutableArray *)aroundDataArr
{
    if (!_aroundDataArr) {
        _aroundDataArr = [NSMutableArray array];
    }
    
    return _aroundDataArr;
}

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
       
        _dataArr = [NSMutableArray array];
        
    }
    
    return _dataArr;
}

@end
