//
//  AlbumsTravelReviewViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/29.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelReviewViewController.h"
#import "AlbumsTravelAddViewController.h"
#import "AlbumsTravelReviewViewDetailController.h"
#import "AlbumsTravelReviewTableHeaderBtn.h"
#import "AlbumsTravelReviewTableViewCell.h"
#import "UIView+addBorderLine.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "PRGAnnotation.h"
#import "AlbumsTravelReviewModel.h"
#import "AlbumsTravelReviewHourModel.h"
#import "AlbumsMapPaopaoImageVIew.h"
#import "EyeShareTravelsController.h"//游记分享
#import "EyeNavigationController.h"
#import "FMDBTools.h"

@interface AlbumsTravelReviewViewController () <UITableViewDataSource, UITableViewDelegate,BMKMapViewDelegate,AlbumsTravelReviewTableViewCellDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *annotationObjects; //标注数组
@property (nonatomic, strong) BMKMapView *mapView;

// 游记数据源
@property (nonatomic, strong) NSMutableArray *travelDetailArray;
// 先对小时进行分组
@property (nonatomic, strong) NSMutableArray *hourModelArray;

@property (nonatomic, strong) NSMutableArray *tempTimeArray;

@end

@implementation AlbumsTravelReviewViewController
{
    // 划线
    BMKPolyline *polyline;
    NSInteger num;
    
    BOOL needRefresh;
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    if (needRefresh) {
        [self refreshUI];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    needRefresh = NO;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addTitle:@"游记预览"];
    
    [self addBackButtonWith:nil];
    
    _annotationObjects = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:GETNCIMAGE(@"albums_travel_add.png") wordNum:2 actionBlock:^(UIButton *sender) {
        // 点击跳转到游记添加页面
        AlbumsTravelAddViewController *travelAddVC = [[AlbumsTravelAddViewController alloc] init];
        travelAddVC.model = weakSelf.model;
        travelAddVC.travelDetailArray = weakSelf.travelDetailArray;
        [weakSelf.navigationController pushViewController:travelAddVC animated:YES];
        
//        UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 524*PSDSCALE_Y)];
//        imagev.image = [weakSelf.mapView takeSnapshot:CGRectMake(0, 0, SCREEN_WIDTH, 524*PSDSCALE_Y)];
//        [weakSelf.view addSubview:imagev];
        
        
    }];
    
    [self addMapView];
    
    [self.view addSubview:self.tableView];
    
    [self addBottomToolBar];
    
    [self loadDateFromDBAndMakeGroups];
    
    [self addOverlayView];
    
    [NotificationCenter addObserver:self selector:@selector(setNeedRefresh) name:@"TravelAddSuccess" object:nil];
    [NotificationCenter addObserver:self selector:@selector(setNeedRefresh) name:@"TravelPrettifiedNoti" object:nil];
}

- (void)setNeedRefresh {
    needRefresh = YES;
}

- (void)refreshUI {
    
    [self loadDateFromDBAndMakeGroups];
    [_mapView removeOverlay:polyline];
    polyline = nil;
    num = 0;
    [_mapView removeAnnotations:_annotationObjects];
    [_annotationObjects removeAllObjects];
    [self addOverlayView];
}

//数组去重
- (NSArray *)setWithArray:(NSMutableArray *)arr
{
    NSSet *set = [NSSet setWithArray:arr];
    return [set allObjects];
}

// 从数据库加载数据并分组
- (void)loadDateFromDBAndMakeGroups {
    [self.dataSource removeAllObjects];
    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
    _travelDetailArray = travelDetailArray;
    
    if (_tempTimeArray) {
        [_tempTimeArray removeAllObjects];
        _tempTimeArray = nil;
    }
    
    _tempTimeArray = [NSMutableArray array];
    //    // 先对小时进行分组
    _hourModelArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _travelDetailArray.count; i++)
    {
         AlbumsTravelDetailModel *model = [_travelDetailArray objectAtIndex:i];
        [_tempTimeArray addObject:[model.time substringToIndex:10]];
        
    }
    _tempTimeArray = [[self setWithArray:_tempTimeArray] mutableCopy];
    
    for (NSInteger i =0; i < _tempTimeArray.count; i++)
    {
        NSMutableArray *timeGroupArray = [NSMutableArray array];
        AlbumsTravelReviewHourModel *hourModel = [[AlbumsTravelReviewHourModel alloc] init];
        NSString *timeStr = [_tempTimeArray objectAtIndex:i];
        for (NSInteger i = 0; i < _travelDetailArray.count; i ++)
        {
            AlbumsTravelDetailModel *model = [_travelDetailArray objectAtIndex:i];
            if ([[model.time substringToIndex:10] isEqualToString:timeStr])
            {
                [timeGroupArray addObject:model];
            }
        }
        hourModel.time = timeStr;
        hourModel.dataSource = timeGroupArray;
        [_hourModelArray addObject:hourModel];
        
    }
    
    
//    // 先对小时进行分组
//    _hourModelArray = [NSMutableArray array];
//    NSString *timeString = nil;
//    NSMutableArray *timeGroupArray = nil;
//    AlbumsTravelReviewHourModel *hourModel = nil;
//    for (NSInteger i = 0; i < _travelDetailArray.count; i++) {
//        AlbumsTravelDetailModel *model = [_travelDetailArray objectAtIndex:i];
//        
//        if ([[model.time substringToIndex:10] isEqualToString:timeString]) {
//            [timeGroupArray addObject:model];
//        } else {
//            if (hourModel) {
//                hourModel.dataSource = timeGroupArray;
//                [_hourModelArray addObject:hourModel];
//                
//                timeString = nil;
//                timeGroupArray = nil;
//                hourModel = nil;
//            }
//            
//            timeString = [model.time substringToIndex:10];
//            timeGroupArray = [NSMutableArray array];
//            [timeGroupArray addObject:model];
//            hourModel = [[AlbumsTravelReviewHourModel alloc] init];
//            hourModel.time = timeString;
//        }
//        
//    }
//    if (hourModel) {
//        hourModel.dataSource = timeGroupArray;
//        [_hourModelArray addObject:hourModel];
//    }
    // 再对日期进行分组
    NSString *dateString = nil;
    NSMutableArray *dateGroupArray = nil;
    AlbumsTravelReviewModel *dateModel = nil;
    for (NSInteger i = 0; i < _hourModelArray.count; i++) {
        AlbumsTravelReviewHourModel *model = [_hourModelArray objectAtIndex:i];
        
        if ([[model.time substringToIndex:8] isEqualToString:dateString]) {
            [dateGroupArray addObject:model];
        } else {
            if (dateModel) {
                dateModel.dataSource = dateGroupArray;
                [self.dataSource addObject:dateModel];
                
                dateString = nil;
                dateGroupArray = nil;
                dateModel = nil;
            }
            
            dateString = [model.time substringToIndex:8];
            dateGroupArray = [NSMutableArray array];
            [dateGroupArray addObject:model];
            dateModel = [[AlbumsTravelReviewModel alloc] init];
            dateModel.time = dateString;
            if (i == 0) {
                // 开始
                dateModel.index = 0;
            } else if (i == _hourModelArray.count - 1) {
                dateModel.index = 2;
            } else {
                // 结束
                dateModel.index = 1;
            }

        }
        
    }
    if (dateModel) {
        dateModel.dataSource = dateGroupArray;
        [self.dataSource addObject:dateModel];
    }
    
    [self.tableView reloadData];

}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
    }
    
    return _dataSource;
}


- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 524 * PSDSCALE_Y, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT - 524 * PSDSCALE_Y) style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 68, 0);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    
    return _tableView;
}

- (void)addMapView
{
    num = 0;
    //设置地图
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 524 * PSDSCALE_Y)];
    [self.view addSubview: _mapView];
    _mapView.delegate = self;
//    [self addOverlayView];
}

//添加内置覆盖物
- (void)addOverlayView
{
    CLLocationCoordinate2D coords[_hourModelArray.count + 2];
    
    //添加折线(分段颜色绘制)覆盖物
    if (polyline == nil) {
        
        for (NSInteger i = 0; i < _hourModelArray.count + 2; i++) {
            if (i == 0) {
                // 开始坐标
                coords[i] = [MyTools getLocationWithGPRMC:self.model.startPostion];
            } else if (i == _hourModelArray.count + 1) {
                // 结束坐标
                coords[i] = [MyTools getLocationWithGPRMC:self.model.endPostion];
            } else {
                // 其他
                AlbumsTravelReviewHourModel *hourModel = [_hourModelArray objectAtIndex:i - 1];
                coords[i] = [MyTools getLocationWithGPRMC:[[hourModel.dataSource lastObject] gps]];
            }
        }
        
//        coords[0].latitude = 22.541971;
//        coords[0].longitude = 113.952167;
//        coords[1].latitude = 22.542038;
//        coords[1].longitude = 113.956461;
//        coords[2].latitude = 22.53855;
//        coords[2].longitude = 113.956479;
//        coords[3].latitude = 22.545856;
//        coords[3].longitude = 113.960418;
//        coords[4].latitude = 22.55118;
//        coords[4].longitude = 113.956268;
        //构建BMKPolyline,使用分段颜色索引，其对应的BMKPolylineView必须设置colors属性
        polyline = [BMKPolyline polylineWithCoordinates:coords count:_hourModelArray.count + 2 textureIndex:@[@0]];
    }
    [_mapView addOverlay:polyline];
    
//    CLLocationCoordinate2D coords[5] = {0};
//    
//    coords[0].latitude = 22.541971;
//    coords[0].longitude = 113.952167;
//    coords[1].latitude = 22.542038;
//    coords[1].longitude = 113.956461;
//    coords[2].latitude = 22.53855;
//    coords[2].longitude = 113.956479;
//    coords[3].latitude = 22.545856;
//    coords[3].longitude = 113.960418;
//    coords[4].latitude = 22.55118;
//    coords[4].longitude = 113.956268;
    
    //计算最优视野
    double maxLon ,minLon ,maxLat , minLat;
    //经度
    maxLon = coords[0].longitude;
    minLon = coords[0].longitude;
    //纬度
    maxLat = coords[0].latitude;
    minLat = coords[0].latitude;
    
    for (int i = 0; i < _hourModelArray.count + 2; i++) {
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
         
        PRGAnnotation *annotation = [[PRGAnnotation alloc] init];

        annotation.coordinate = coords[i];
        
        [_mapView addAnnotation:annotation];
        [_annotationObjects addObject:annotation];
    }
    
    BMKPointAnnotation * one = [[BMKPointAnnotation alloc]init];
    one.coordinate = CLLocationCoordinate2DMake(maxLat + (maxLat - minLat)/2, maxLon + (maxLon - minLon)/2);
    BMKPointAnnotation * two = [[BMKPointAnnotation alloc]init];
    two.coordinate = CLLocationCoordinate2DMake(minLat - (maxLat - minLat)/2, minLon - (maxLon - minLon)/2);
    [_mapView showAnnotations:@[one,two] animated:YES];
    
    

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
    else if (num == _hourModelArray.count + 1)
    {
        // 设置位置
        annotationView.centerOffset = CGPointMake(-(annotationView.frame.size.width*0.2),0);
        annotationView.image = GETNCIMAGE(@"albums_travel_end_icon");
    }
    else
    {
        // 设置位置
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
//        annotationView.image = GETNCIMAGE(@"albums_annotation");
        
        AlbumsTravelReviewHourModel *hourModel = [_hourModelArray objectAtIndex:num - 1];
        
        AlbumsMapPaopaoImageVIew *view = [[AlbumsMapPaopaoImageVIew alloc] initWithFrame:CGRectMake(-annotationView.frame.size.width/2, 0, 107*PSDSCALE_X, 67*PSDSCALE_Y)];
        
        AlbumsTravelDetailModel *datailModel = [hourModel.dataSource lastObject];
        
        NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)datailModel.travelId]];
        NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", datailModel.fileName]];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        view.imageView.image = image;
        
        view.imageCountLabel.text = [NSString stringWithFormat:@"%d", (int)hourModel.dataSource.count];
        [annotationView addSubview:view];
    }
    num++;
    annotationView.userInteractionEnabled = YES;
    return annotationView;
}


- (void)addBottomToolBar {
    
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_4s - 48 - NAVIGATIONBARHEIGHT, SCREEN_WIDTH, 48)];
    toolBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:toolBar];
    
    NSArray *imagesArray = @[GETNCIMAGE(@"albums_travel_collect"), GETNCIMAGE(@"albums_travel_share"), GETNCIMAGE(@"albums_travel_trash")];
    NSArray *namesArray = @[@"收藏", @"分享 ", @"删除"];
    CGFloat itemWidth = 40;
    CGFloat martin = (SCREEN_WIDTH - 3 * itemWidth) / 10;
    CGFloat space = 4 * martin;
    for (NSInteger i = 0; i < imagesArray.count; i++) {
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(i * (itemWidth + space) + martin, 0, itemWidth, VIEW_H(toolBar))];
        [item setImage:imagesArray[i] forState:UIControlStateNormal];
        [item setTitle:namesArray[i] forState:UIControlStateNormal];
        item.titleLabel.font = [UIFont systemFontOfSize:20 * FONTCALE_Y];
        item.contentMode = UIViewContentModeScaleAspectFit;
        item.tag = i + 1;
        [item addTarget:self action:@selector(bottomToolBar_button_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:item];
        
        [item setImageEdgeInsets:UIEdgeInsetsMake(-12, 10, 0, 0)];
        [item setTitleEdgeInsets:UIEdgeInsetsMake(5, -7, -20, 7)];
    }

}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    AlbumsTravelReviewModel *model = self.dataSource[section];
    if (model.isOpen) {
        
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"Cell";
    
    AlbumsTravelReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[AlbumsTravelReviewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    cell.delegate = self;
    
    AlbumsTravelReviewModel *model = self.dataSource[indexPath.section];
    NSArray *dataArray = model.dataSource;
    
    cell.cameraMac = self.model.cameraMac;
    cell.dataSource = dataArray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumsTravelReviewModel *model = self.dataSource[indexPath.section];
    NSArray *dataArray = model.dataSource;
    
    if (dataArray.count) {
        return dataArray.count * 150 *PSDSCALE_Y + 40 * PSDSCALE_Y;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    AlbumsTravelReviewTableHeaderBtn *headerView = [[AlbumsTravelReviewTableHeaderBtn alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
    
    AlbumsTravelReviewModel *model = self.dataSource[section];
    NSString *time = model.time;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [formatter dateFromString:time];
    
    headerView.textLabel.text = [MyTools getDateStringWithDateFormatter:@"yyyy-MM-dd" date:date];
    
    NSInteger index = model.index;
    if (index == 0) {
        // 开始
        headerView.leftImageView.image = GETNCIMAGE(@"albums_travel_start_icon.png");
    } else if (index == 2) {
        // 结束
        headerView.leftImageView.image = GETNCIMAGE(@"albums_travel_end_icon.png");
    } else {
        headerView.leftImageView.image = nil;
    }
    
    if ([[self.model.startTime substringToIndex:8] isEqualToString:[self.model.endTime substringToIndex:8]]) {
        // 开始和结束在同一天
        headerView.isStartAndEndSame = YES;
    }
    
    if (section == 0) {
        [headerView addBorderLineWithColor:RGBSTRING(@"cccccc") borderWidth:1 direction:kBorderLineDirectionTop|kBorderLineDirectionBottom];
    } else {
        [headerView addBorderLineWithColor:RGBSTRING(@"cccccc") borderWidth:1 direction:kBorderLineDirectionBottom];
    }
    [headerView addTarget:self action:@selector(header_btn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    headerView.tag = section + 1;
    
    BOOL isOpen = model.isOpen;
    headerView.arrowImageView.highlighted = isOpen;
    
    return headerView;
    
}

- (void)header_btn_clicked_action:(AlbumsTravelReviewTableHeaderBtn *)sender {
    
    AlbumsTravelReviewModel *model = self.dataSource[sender.tag - 1];
    model.isOpen = !model.isOpen;
    
    [self.tableView reloadData];
    
}

#pragma AlbumsTravelReviewTableViewCellDelegate
-(void)btn_clickWithModel:(AlbumsTravelReviewHourModel *)model
{
    AlbumsTravelReviewViewDetailController *albumsTravelReviewViewDetailVC = [[AlbumsTravelReviewViewDetailController alloc] init];
    albumsTravelReviewViewDetailVC.cameraMac = self.model.cameraMac;
    albumsTravelReviewViewDetailVC.model = model;
    [self.navigationController pushViewController:albumsTravelReviewViewDetailVC animated:YES];
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
            polylineView.colors = [NSArray arrayWithObjects: RGBSTRING(@"b11c22"), nil];
        } else {
            polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
            polylineView.lineWidth = 20.0;
            [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"texture_arrow.png"]];
        }
        return polylineView;
    }
    
    
    return nil;
}

- (void)bottomToolBar_button_clicked_action:(UIButton *)sender {
    
    if (sender.tag == 1) {
        // 收藏
        if ([FMDBTools selectContactMember:[NSString stringWithFormat:@"%ld", (long)self.model.travelId] userName:UserName])
        {
            [self addActityText:@"不能重复收藏" deleyTime:1];
            return;
        }
        
        if ([FMDBTools saveContactsWithImageUrl:[NSString stringWithFormat:@"%ld", (long)self.model.travelId] type:kCollectTypeTravel])
        {
            [self addActityText:@"收藏成功" deleyTime:1];
            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        }
        else
        {
            [self addActityText:@"收藏失败" deleyTime:1];
        }

    } else if (sender.tag == 2) {
        
         NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:self.model.travelId];
        
        BOOL isShare = NO;
        for (int i = 0; i < travelDetailArray.count; i ++) {
            
            AlbumsTravelDetailModel *detailModel = travelDetailArray[i];
            isShare = detailModel.shared;
            if (isShare) {//代表有图片可以分享
                
                // 分享
                EyeShareTravelsController *shareCtl = [[EyeShareTravelsController alloc] init];
                
                shareCtl.model = self.model;
                
                [self.navigationController pushViewController:shareCtl animated:YES];
                return;
            }
        }
        
        if (!isShare) {
            [self addActityText:@"没有图片可以分享" deleyTime:1];
        }
        
        
    } else if (sender.tag == 3) {
        // 删除
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除该游记吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        if ([FMDBTools selectContactMember:[NSString stringWithFormat:@"%ld", (long)self.model.travelId] userName:UserName])
        {
            // 有收藏，先删除收藏
            BOOL isDeleteSuccess = [FMDBTools deleteCollectWithimageUrl:[NSString stringWithFormat:@"%ld", (long)self.model.travelId]];
            if (isDeleteSuccess)
            {
                [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
            }
        }
        
        
        NSString *temp_path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", (long)self.model.travelId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path])
        {
            // 删除本地图片
            [[NSFileManager defaultManager] removeItemAtPath:temp_path error:nil];
        }
        
        // 确定删除
        BOOL deleted = [CacheTool deleteTravelWithTravelId:self.model.travelId];
        if ([self.model.flag isEqualToString:@"3"] || [self.model.flag isEqualToString:@"1"]) {
            [UserDefaults setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@_traveling", self.model.userId, self.model.cameraMac]];
        }

        if (deleted) {
            [self addActityText:@"游记删除成功" deleyTime:2];
            
            [NotificationCenter postNotificationName:@"TravelDeleteSuccess" object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
}

@end
