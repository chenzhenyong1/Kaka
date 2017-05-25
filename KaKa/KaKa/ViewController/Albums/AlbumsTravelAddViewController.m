//
//  AlbumsTravelAddViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/29.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelAddViewController.h"
#import "TZImagePickerController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "PRGAnnotation.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "AlbumsTravelAddCollectionViewCell.h"
#import "MyTools.h"

@interface AlbumsTravelAddViewController ()<BMKMapViewDelegate,UIScrollViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, AlbumsTravelAddCollectionViewCellDelegate>

@property (nonatomic, strong) UIImageView *timeAxisImageView;

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSMutableArray *photoNamesArray;
@property (nonatomic, strong) NSMutableArray *annotationObjects; //标注数组

@property (nonatomic, strong) AlbumsTravelDetailModel *selectedDetailModel;

/** 坐标数组 */
@property (nonatomic, assign) CLLocationCoordinate2D *coords;
@end

@implementation AlbumsTravelAddViewController
{
    BMKMapView *_mapView;
    BMKPolyline *polyline;
    UIScrollView *_timeAxisScrollView;
    NSMutableArray *times;
//    CLLocationCoordinate2D coords[1000];
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitle:@"编辑游记"];
    _annotationObjects = [[NSMutableArray alloc] init];
    
    _coords = malloc([_travelDetailArray count] * sizeof(CLLocationCoordinate2D));
    
    [self addBackButtonWith:nil];
    
    [self addMapView];
    
    [self addTimeAxisView];

    [self addBottomSureButton];

    
    // 首次进入
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appVersion = [UserDefaults objectForKey:@"AppVersion"];
    if (![currentAppVersion isEqualToString:appVersion]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 蒙版
            [self addLayerMaskView];
        });
        [UserDefaults setObject:currentAppVersion forKey:@"AppVersion"];
        [UserDefaults synchronize];
    }
    
    
    
    
    [self.view addSubview:self.photoCollectionView];
    
     
}

- (NSMutableArray *)photoArray {
    
    if (!_photoArray) {
        _photoArray = [NSMutableArray arrayWithObjects:GETNCIMAGE(@"albums_photo_add.png"), nil];
    }
    
    return _photoArray;
}

- (NSMutableArray *)photoNamesArray {
    if (!_photoNamesArray) {
        _photoNamesArray = [NSMutableArray array];
    }
    
    return _photoNamesArray;
}

- (UICollectionView *)photoCollectionView {
    
    if (!_photoCollectionView) {
        // _timeAxisScrollView
        
        CGFloat margin = 5;
        CGFloat space = 3;
        CGFloat photoWidth = (SCREEN_WIDTH - 2 * (margin + space)) / 3;
        
        LXReorderableCollectionViewFlowLayout *flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = space;
        flowLayout.minimumInteritemSpacing = space;
        flowLayout.itemSize = CGSizeMake(photoWidth, photoWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(margin, margin, space, margin);
        
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(_timeAxisScrollView) + 30 * PSDSCALE_Y, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT - 48 - (VIEW_H_Y(_timeAxisScrollView) + 30 * PSDSCALE_Y)) collectionViewLayout:flowLayout];
        _photoCollectionView.dataSource = self;
        _photoCollectionView.delegate = self;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_photoCollectionView registerClass:[AlbumsTravelAddCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    
    return _photoCollectionView;
}

- (void)addMapView
{
    //设置地图
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 524 * PSDSCALE_Y)];
    [self.view addSubview: _mapView];
    _mapView.delegate = self;
    [self addOverlayView];
}

//添加内置覆盖物
- (void)addOverlayView
{
    //添加折线(分段颜色绘制)覆盖物
    if (polyline == nil) {
        
        for (NSInteger i = 0; i < _travelDetailArray.count + 2; i++) {
            if (i == 0) {
                _coords[i] = [MyTools getLocationWithGPRMC:self.model.startPostion];
            } else if (i == _travelDetailArray.count + 1) {
                _coords[i] = [MyTools getLocationWithGPRMC:self.model.endPostion];
            } else {
                AlbumsTravelDetailModel *model = [_travelDetailArray objectAtIndex:i - 1];
                _coords[i] = [MyTools getLocationWithGPRMC:model.gps];
            }
        }

        //构建BMKPolyline,使用分段颜色索引，其对应的BMKPolylineView必须设置colors属性
        polyline = [BMKPolyline polylineWithCoordinates:_coords count:_travelDetailArray.count + 2 textureIndex:@[@0]];
    }
    [_mapView addOverlay:polyline];
    
    //计算最优视野
    double maxLon ,minLon ,maxLat , minLat;
    //经度
    maxLon = _coords[0].longitude;
    minLon = _coords[0].longitude;
    //纬度
    maxLat = _coords[0].latitude;
    minLat = _coords[0].latitude;
    
    for (int i = 0; i < _travelDetailArray.count + 2; i++) {
        //最大纬度
        if (_coords[i].latitude > maxLat) {
            maxLat = _coords[i].latitude;
        }
        //最小纬度
        if (_coords[i].latitude < minLat) {
            minLat = _coords[i].latitude;
        }
        //最大经度
        if (_coords[i].longitude > maxLon) {
            maxLon = _coords[i].longitude;
        }
        //最小经度
        if (_coords[i].longitude < minLon) {
            minLon = _coords[i].longitude;
        }
        
    }
    
    
    PRGAnnotation *annotation1 = [[PRGAnnotation alloc] init];
    annotation1.type = @"0";
    annotation1.coordinate = _coords[0];
    [_mapView addAnnotation:annotation1];
    [_annotationObjects addObject:annotation1];
    
    PRGAnnotation *annotation2 = [[PRGAnnotation alloc] init];
    annotation2.type = @"2";
    annotation2.coordinate = _coords[_travelDetailArray.count + 1];
    [_mapView addAnnotation:annotation2];
    [_annotationObjects addObject:annotation2];
    
    BMKPointAnnotation * one = [[BMKPointAnnotation alloc]init];
    one.coordinate = CLLocationCoordinate2DMake(maxLat + (maxLat - minLat)/2, maxLon + (maxLon - minLon)/2);
    BMKPointAnnotation * two = [[BMKPointAnnotation alloc]init];
    two.coordinate = CLLocationCoordinate2DMake(minLat - (maxLat - minLat)/2, minLon - (maxLon - minLon)/2);
    [_mapView showAnnotations:@[one,two] animated:YES];
    
    
    
}

- (void)addTimeAxisView
{
    // 结束时间
    NSString *endTimestring = [MyTools yearToTimestamp:_model.endTime];
    NSTimeInterval endTimestamp = [endTimestring longLongValue];
    NSTimeInterval startTimestamp = [[MyTools yearToTimestamp:_model.startTime] longLongValue];
    // 总时长
    NSTimeInterval timestamp = endTimestamp - startTimestamp;
    NSInteger minue = timestamp / 60;
    NSInteger count = minue / 20;
    if (minue % 20) {
        count++;
    }
    
    times = [NSMutableArray array];
    for (AlbumsTravelDetailModel *detailModel in _travelDetailArray) {
        NSTimeInterval modelTimestamp = [[MyTools yearToTimestamp:detailModel.time] longLongValue];
        NSTimeInterval tempTimestamp = modelTimestamp - startTimestamp;
        CGFloat tempMinue = tempTimestamp / 60.0;
        
        [times addObject:[NSString stringWithFormat:@"%f", tempMinue]];
    }
    
    // 添加开始和结束时间
    [times insertObject:@"0" atIndex:0];
    [times addObject:[NSString stringWithFormat:@"%f", timestamp/60.0]];
    
    _timeAxisScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 524*PSDSCALE_Y, SCREEN_WIDTH, 80*PSDSCALE_Y)];
    _timeAxisScrollView.showsHorizontalScrollIndicator = NO;
    _timeAxisScrollView.delegate = self;
    _timeAxisScrollView.bounces = NO;
//    _timeAxisScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_timeAxisScrollView];
    _timeAxisScrollView.contentSize = CGSizeMake((count + 2)*SCREEN_WIDTH/2, 0);
//    [_timeAxisScrollView setContentOffset:CGPointMake([self getFrameWithTime:[times[0] floatValue]*60]*16*PSDSCALE_X-5*PSDSCALE_X-SCREEN_WIDTH/2+3, 0) animated:YES];
    UIImage *timeAxisImage = GETNCIMAGE(@"albums_travelAdd_timeAxis.png");
    _timeAxisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,  0, (count + 2)*SCREEN_WIDTH/2, 80*PSDSCALE_Y)];
    _timeAxisImageView.image = timeAxisImage;
    [_timeAxisScrollView addSubview:_timeAxisImageView];
    
    CGFloat space = SCREEN_WIDTH/2 / 20;
    for (int i = 1; i < 20*count; i ++) {
        UIView *short_line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+i*space, 30*PSDSCALE_Y, 1*PSDSCALE_X, 21*PSDSCALE_Y)];
        short_line.backgroundColor = RGBSTRING(@"636363");
        [_timeAxisImageView addSubview:short_line];
    }
    
    for (int i = 0; i < count + 2; i ++)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+i*SCREEN_WIDTH/2, 10*PSDSCALE_Y, 2*PSDSCALE_X, 60*PSDSCALE_Y)];
        line.backgroundColor = RGBSTRING(@"cccccc");
        
        [_timeAxisImageView addSubview:line];
    }
    
    UIView *center_line = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-6*PSDSCALE_X)/2, 524*PSDSCALE_Y, 6*PSDSCALE_X, 80*PSDSCALE_Y)];
    center_line.backgroundColor = RGBSTRING(@"b11c22");
    [self.view addSubview:center_line];
    
    UIImageView *center_jiantou = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-26*PSDSCALE_X)/2, VIEW_H_Y(center_line), 26*PSDSCALE_X, 22*PSDSCALE_Y)];
    center_jiantou.image = GETYCIMAGE(@"albums_center");
    [self.view addSubview:center_jiantou];
    
    for (NSInteger i = 0; i < times.count; i++) {
        if (i == 0 || i == times.count - 1) {
            continue;
        }
        
        NSString *time = [times objectAtIndex:i];
        
        UIView *red_point = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+[time floatValue]*space-6*PSDSCALE_X, 35*PSDSCALE_Y, 12*PSDSCALE_X, 12*PSDSCALE_Y)];
        red_point.backgroundColor = RGBSTRING(@"b11c22");
        red_point.layer.masksToBounds = YES;
        red_point.layer.cornerRadius = 6*PSDSCALE_X;
        [_timeAxisImageView addSubview:red_point];
    }
//    for (NSString *time in times)
//    {
//        UIView *red_point = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+[time floatValue]*space-6*PSDSCALE_X, 35*PSDSCALE_Y, 12*PSDSCALE_X, 12*PSDSCALE_Y)];
//        red_point.backgroundColor = RGBSTRING(@"b11c22");
//        red_point.layer.masksToBounds = YES;
//        red_point.layer.cornerRadius = 6*PSDSCALE_X;
//        [_timeAxisImageView addSubview:red_point];
//    }
    
}

//根据时间获得点的位置
- (int)getFrameWithTime:(int)minute
{
    int a;
    a = minute/3;
    return a;
}

- (void)addBottomSureButton {
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT - 48, SCREEN_WIDTH, 48)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    [sureBtn setBackgroundImage:GETIMAGEWITHCOLORANDSIZE(RGBSTRING(@"b11c22"), CGSizeMake(SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT - 48, 48)) forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureButton_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
}

- (void)addLayerMaskView {
    
    UIButton *bgBtn = [[UIButton alloc] initWithFrame:SCREEN_BOUNDS];
//    bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [bgBtn addTarget:self action:@selector(layerMaskBg_button_action:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:bgBtn];
    
    UIImage *handImage = GETNCIMAGE(@"albums_travel_add_layerMask.png");
    UIImageView *handImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * handImage.size.height / handImage.size.width)];
    handImageView.image = handImage;
    [bgBtn addSubview:handImageView];
    
    UIButton *knownBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 142) / 2, SCREEN_HEIGHT_4s-135, 142, 35)];
    [knownBtn addTarget:self action:@selector(layerMask_button_action:) forControlEvents:UIControlEventTouchUpInside];
    knownBtn.layer.borderWidth = 1;
    knownBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [knownBtn setTitle:@"我知道了" forState:UIControlStateNormal];
    knownBtn.titleLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
    [bgBtn addSubview:knownBtn];
    
}

#pragma mark button action
- (void)layerMaskBg_button_action:(UIButton *)sender {
    [sender removeFromSuperview];
}

- (void)layerMask_button_action:(UIButton *)sender {
    
    [sender.superview removeFromSuperview];
    [sender removeFromSuperview];
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(PRGAnnotation *)annotation
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
    
//    // 设置位置
//    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    if ([annotation.type isEqualToString:@"0"]) {
        // 设置位置
        annotationView.centerOffset = CGPointMake(-(annotationView.frame.size.width*0.2), 0);
        annotationView.image = GETNCIMAGE(@"albums_travel_start_icon");
    }
    else if ([annotation.type isEqualToString:@"1"])
    {
        // 设置位置
        annotationView.centerOffset = CGPointMake(30*PSDSCALE_X, -(annotationView.frame.size.height * 0.3));
        annotationView.image = GETNCIMAGE(@"albums_travelAdd_mapPaopao.png");
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, annotationView.image.size.width, annotationView.image.size.height)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:27*FONTCALE_Y];
        [annotationView addSubview:timeLabel];
        
        NSTimeInterval timeInterval = [[MyTools yearToTimestamp:annotation.time] doubleValue];
        NSString *dateStr = [MyTools getDateStringWithDateFormatter:@"yyyy-MM-dd HH:mm:ss" date:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        timeLabel.text = dateStr;
        
    }
    else
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

#pragma mark - UIscrollViewDelegate


//scrollView滚动时，就调用该方法。任何offset值改变都调用该方法。即滚动过程中，调用多次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGPoint point=scrollView.contentOffset;
    
    CGFloat space = SCREEN_WIDTH/2 / 20;
    if (point.x < [times[0] floatValue]*space-6*PSDSCALE_X-SCREEN_WIDTH/2+3)
    {
        
        [_timeAxisScrollView setContentOffset:CGPointMake([times[0] floatValue]*space-6*PSDSCALE_X-SCREEN_WIDTH/2+3, 0) animated:NO];
    }
    
    
}

// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewDidEndDecelerating");
    int contentOffset_x = (int)(_timeAxisScrollView.contentOffset.x+ SCREEN_WIDTH/2);
    
    CGFloat space = SCREEN_WIDTH/2 / 20;
    for (int i = 0; i < times.count; i++) {
        NSString *time = times[i];
        int num = (int)([time floatValue]*space-6*PSDSCALE_X + SCREEN_WIDTH/2);
        if (contentOffset_x>num && contentOffset_x<(num +9)) {
            
//            if (i != 0)
//            {
//                if (_annotationObjects.count >2) {
//                    
//                    PRGAnnotation *annotation = _annotationObjects.lastObject;
//                    [_mapView removeAnnotation:annotation];
//                    [_annotationObjects removeObject:_annotationObjects.lastObject];
//                }
//                
//                PRGAnnotation *annotation = [[PRGAnnotation alloc] init];
//                annotation.type = @"1";
//                annotation.coordinate = coords[i];
//                [_mapView addAnnotation:annotation];
//                [_annotationObjects addObject:annotation];
//            }
            // 如果滚动标尺正好落到某个点上，显示标注
            [self addAnnotationWithIndex:i];
        }
    }
    
}

//拖拽停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSLog(@"scrollViewDidEndDragging");
    NSLog(@"%d",(int)( SCREEN_WIDTH/2));
    int contentOffset_x = (int)(_timeAxisScrollView.contentOffset.x+ SCREEN_WIDTH/2);
    
    CGFloat space = SCREEN_WIDTH/2 / 20;
    for (int i = 0; i < times.count; i++) {
        NSString *time = times[i];
        int num = (int)([time floatValue]*space-6*PSDSCALE_X + SCREEN_WIDTH/2);
        if (contentOffset_x>num && contentOffset_x<(num +9)) {
            // 如果滚动标尺正好落到某个点上，显示标注
            [self addAnnotationWithIndex:i];
        }
    }
    
}

- (void)addAnnotationWithIndex:(int)index {
    
    _selectedDetailModel = nil;
    if (_annotationObjects.count > 2) {
        [_mapView removeAnnotation:[_annotationObjects lastObject]];
        [_annotationObjects lastObject];
    }
    
    PRGAnnotation *annotation = [[PRGAnnotation alloc] init];
    annotation.type = @"1";
    annotation.coordinate = _coords[index];
    
    if (index == 0) {
        // 开始
//        annotation.time = self.model.startTime;
    } else if (index == _travelDetailArray.count + 1) {
        // 结束位置
//        annotation.time = self.model.endTime;
    } else {
        
        if ((index - 1) < _travelDetailArray.count) {
            AlbumsTravelDetailModel *model = [_travelDetailArray objectAtIndex:index - 1];
            annotation.time = model.time;
            _selectedDetailModel = model;
        }
        
        [_mapView addAnnotation:annotation];
        [_annotationObjects addObject:annotation];
    }
//    [_mapView addAnnotation:annotation];
//    [_annotationObjects addObject:annotation];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumsTravelAddCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.itemImage.image = [self.photoArray objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    if (indexPath.row == self.photoArray.count - 1) {
        // 加号隐藏删除按钮
        cell.deleteBtn.hidden = YES;
    } else {
        cell.deleteBtn.hidden = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != self.photoArray.count - 1) {
        return;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXFLOAT delegate:nil];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    
    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        // 选中相片后
        for (UIImage *image in photos) {
            [weakSelf.photoArray insertObject:image atIndex:weakSelf.photoArray.count - 1];
        }
        
        for (NSDictionary *info in infos) {
            
            NSString *fileName = [NSString stringWithFormat:@"%@", [info objectForKey:@"PHImageFileURLKey"]];
            fileName = [[fileName componentsSeparatedByString:@"/"] lastObject];
            
            NSString *imageName = [MyTools getDateStringWithDateFormatter:@"yyyyMMddHHmmss" date:[NSDate date]];
            imageName = [imageName stringByAppendingString:[NSString stringWithFormat:@"_%@", fileName]];
            [self.photoNamesArray addObject:imageName];
        }
        
        
        [weakSelf.photoCollectionView reloadData];

    }];

    [SharedApplication.keyWindow.rootViewController presentViewController:imagePickerVc animated:YES completion:nil];

}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
//    if (toIndexPath.row == self.photoArray.count - 1) {
//        
//        // 不能移到加号上
//        return;
//    }
    
    UIImage *image = self.photoArray[fromIndexPath.item];
    
    [self.photoArray removeObjectAtIndex:fromIndexPath.item];
    [self.photoArray insertObject:image atIndex:toIndexPath.item];
    
    NSString *imageName = self.photoNamesArray[fromIndexPath.item];
    [self.photoNamesArray removeObjectAtIndex:fromIndexPath.item];
    [self.photoNamesArray insertObject:imageName atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.photoArray.count - 1) {
        // 加号不能移动
        return NO;
    }
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {

    if (toIndexPath.row == self.photoArray.count - 1) {
    
        // 不能移到加号上
        return NO;
    }
    
    return YES;
}

#pragma mark - AlbumsTravelAddCollectionViewCellDelegate
// 删除按钮点击
- (void)didClickDeleteBtnWithIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.photoArray.count) {
        [self.photoArray removeObjectAtIndex:indexPath.row];
        [self.photoNamesArray removeObjectAtIndex:indexPath.row];
        
        [self.photoCollectionView reloadData];
    }
}

- (void)sureButton_clicked_action:(UIButton *)sender {
    
    if (!_selectedDetailModel) {
        [self addActityText:@"请选择一个时间点" deleyTime:1];
        return;
    }
    
    if (self.photoNamesArray.count == 0) {
        [self addActityText:@"请选择游记图片" deleyTime:1];
        return;
    }
    
    BOOL addSuccess = NO;
    for (NSInteger i = 0; i < self.photoArray.count - 1; i++) {
        NSString *path = [Travel_Path(_model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)_model.travelId]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (i >= self.photoNamesArray.count) {
            return;
        }
        
        UIImage *image = [self.photoArray objectAtIndex:i];
        
        //设置一个图片的存储路径
        NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", self.photoNamesArray[i]]];
        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
        
        AlbumsTravelDetailModel *detailModel = [[AlbumsTravelDetailModel alloc] init];
        detailModel.travelId = self.model.travelId;
        detailModel.date = _selectedDetailModel.date;
        detailModel.gps = _selectedDetailModel.gps;
        detailModel.type = @"photo";
        detailModel.time = _selectedDetailModel.time;
        detailModel.fileName = self.photoNamesArray[i];

        addSuccess = [CacheTool updateTravelDetailWithDetailModel:detailModel];
    }
    
    if (addSuccess) {
        [self addActityText:@"游记添加成功" deleyTime:1];
        
        [NotificationCenter postNotificationName:@"TravelAddSuccess" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });

    } else {
        [self addActityText:@"游记添加失败" deleyTime:1];
    }
    
}

@end
