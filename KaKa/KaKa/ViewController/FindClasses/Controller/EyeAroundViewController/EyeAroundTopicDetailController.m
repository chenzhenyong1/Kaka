//
//  EyeTopicController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeAroundTopicDetailController.h"
#import <Masonry.h>
#import "EyeCustomBtn.h"
#import "EyeSubjectsModel.h"
#import "EyeCommentController.h"
#import "EyeSubjectDetailResultModel.h"
#import "Subject.h"
#import "EyeAroundDetailScrollView.h"
#import "InteractList.h"
#import "TrackList.h"

@interface EyeAroundTopicDetailController ()<BMKMapViewDelegate>

/** 图片 */
@property (nonatomic, strong) UIImageView *imageView;


/** 数据源 */
@property (nonatomic, strong) EyeSubjectDetailResultModel *data;

/** 装有主要内容的View */
@property (nonatomic, weak) EyeAroundDetailScrollView *contentView;

/** 底部视图 */
@property (nonatomic, weak) UIView *bottomView;
/** 查看按钮 */
@property (nonatomic, weak) EyeCustomBtn *viewButton;
/** 收藏按钮 */
@property (nonatomic, weak) EyeCustomBtn *favButton;
/** 点赞按钮 */
@property (nonatomic, weak) EyeCustomBtn *voteButton;
/** 评论按钮 */
@property (nonatomic, weak) EyeCustomBtn *commentButton;
/** 分享按钮 */
@property (nonatomic, weak) EyeCustomBtn *shareButton;

/** 总时长 */
@property (nonatomic, weak) UILabel *timeLabel;
/** 总里程 */
@property (nonatomic, weak) UILabel *mileLabel;

/** 地图视图  */
@property (nonatomic,strong) BMKMapView *mapView;

@end

@implementation EyeAroundTopicDetailController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = self.subjectModel.title;
    self.view.backgroundColor = [UIColor blackColor];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    //初始化底部视图
    [self bottomView];
    
    // 联网取得数据
    [self loadData];
    
    if ([self.subjectModel.subjectKind integerValue] == 1) {
        // 初始化地图
        [self initMap];
    }
    
    
}

- (void)back
{
    [self.contentView deleteAndPause];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
   
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil

}


#pragma mark -- 初始化地图
- (void) initMap
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height * 0.25)];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.zoomLevel = 9;
    [self.view addSubview:_mapView];
    
    UIView *bottomMapView = [UIView new];
    bottomMapView.backgroundColor = [UIColor blackColor];
    bottomMapView.alpha = 0.6;
    [_mapView addSubview:bottomMapView];
    [bottomMapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(_mapView);
        
        make.bottom.equalTo(_mapView.mas_bottom);
        
        make.height.equalTo(@50);
    }];
    //总时长
    UIButton *timeLengthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    timeLengthBtn.userInteractionEnabled = NO;
    timeLengthBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    timeLengthBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    timeLengthBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [timeLengthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [timeLengthBtn setImage:[UIImage imageNamed:@"find_track_time"] forState:UIControlStateNormal];
    [timeLengthBtn setTitle:@"总时长(分钟)" forState:UIControlStateNormal];
    [timeLengthBtn sizeToFit];
    [bottomMapView addSubview:timeLengthBtn];
    
    [timeLengthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(@(bottomMapView.centerX)).offset(-kScreenWidth * 1/4);
        make.centerY.equalTo(bottomMapView.mas_centerY).offset(2);
        
    }];
    
    //总里程
    UIButton *mileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    mileBtn.userInteractionEnabled = NO;
    mileBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    mileBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    //        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    mileBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [mileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mileBtn setImage:[UIImage imageNamed:@"find_track_speed"] forState:UIControlStateNormal];
    [mileBtn setTitle:@"总里程(km)" forState:UIControlStateNormal];
    [mileBtn sizeToFit];
    [bottomMapView addSubview:mileBtn];
    
    [mileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(@(bottomMapView.centerX)).offset(kScreenWidth * 1/4);
        make.centerY.equalTo(timeLengthBtn.mas_centerY);
        
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = ZYRGBColor(168, 24, 36);
    [timeLabel sizeToFit];
    [bottomMapView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(timeLengthBtn.mas_centerX);
        make.bottom.equalTo(timeLengthBtn.mas_top).offset(-2);
        
    }];
    _timeLabel = timeLabel;
    
    
    UILabel *mileLabel = [[UILabel alloc] init];
    mileLabel.textAlignment = NSTextAlignmentCenter;
    mileLabel.font = [UIFont systemFontOfSize:14];
    mileLabel.textColor = ZYRGBColor(168, 24, 36);
    [mileLabel sizeToFit];
    [bottomMapView addSubview:mileLabel];
    [mileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(mileBtn.mas_centerX);
        make.bottom.equalTo(timeLabel.mas_bottom);
        
    }];
    _mileLabel = mileLabel;
    
    
}

/**
 *  联网取得数据
 */
- (void)loadData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"subjectId"] = self.subjectModel.ID;
    [HttpTool get:SubjectDetail_URL params:params success:^(id responseObj) {
        
        ZYLog(@"SubjectDetail_URL responseObj = %@",responseObj);
        
        EyeSubjectDetailResultModel *model =[EyeSubjectDetailResultModel mj_objectWithKeyValues:responseObj[@"result"]];
        
        self.data = model;
        //底部按钮赋值
        [self bottomButtonCount:self.data.subject];
        //给scrollVeiw内部赋值
        self.contentView.mediaListArr = self.data.mediaList;
        self.contentView.trackListArr = self.data.trackList;
        
        self.timeLabel.text = self.data.subject.timeLength;
        self.mileLabel.text = self.data.subject.mileage;
        
        // 是否发送查看
        if (![self.data.subject.viewed boolValue]) {
            //发送话题查看请求
            [self checkTopic];
        }
        
        //是否收藏
        if ([self.data.subject.favSet boolValue]) {
            self.favButton.selected = YES;
        }else{
            self.favButton.selected = NO;
        }
        
        //是否点赞
        if ([self.data.subject.voted boolValue]) {
            self.voteButton.selected = YES;
        }else{
            self.voteButton.selected = NO;
        }
        
        if ([self.subjectModel.subjectKind integerValue] == 1) {
            
            //添加覆盖物
            [self addOverPolylineView];
            
        }


        

        
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    
    
}
/**
 *  添加覆盖物
 */
- (void)addOverPolylineView
{
    CLLocationCoordinate2D startCoordinate;
    TrackList *trackList = self.data.trackList[0];
    startCoordinate.latitude = [trackList.lat doubleValue];
    startCoordinate.longitude = [trackList.lon doubleValue];
    //获取用户的坐标
    _mapView.centerCoordinate = startCoordinate;
    
    _mapView.zoomLevel = 18;
    
    
    NSMutableArray *trackListsArr = [NSMutableArray array];
    
    for (TrackList *trackList in self.data.trackList) {
        
        CLLocationCoordinate2D coordinate;
        
        coordinate.latitude = [trackList.lat doubleValue];
        coordinate.longitude = [trackList.lon doubleValue];
        [trackListsArr addObject:[NSValue value:&coordinate withObjCType:@encode(CLLocationCoordinate2D)]];
        
    }
      CLLocationCoordinate2D coords[trackListsArr.count];//声明一个数组  用来存放画线的点

    for (int i = 0; i < trackListsArr.count; i++) {
        CLLocationCoordinate2D coor;
        [trackListsArr[i] getValue:&coor];
//        coor.latitude -=  0.5;//会有点偏，不知道为啥
//        coor.latitude +=  0.0000;
//        coor.longitude += 0.0000;
        coords[i] = coor;
//         ZYLog(@"coor.longitude = %lf coor.latitude= %lf",coor.longitude,coor.latitude);
    }
   
    //构建分段纹理索引数组
    NSMutableArray *textureIndex = [NSMutableArray array];
    for (int i = 0 ; i < trackListsArr.count; i ++) {
        [textureIndex addObject:[NSNumber numberWithInt:0]];
    }
//    NSArray *textureIndex = [NSArray arrayWithObjects:
//                             [NSNumber numberWithInt:0],
//                              nil];
    
    BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coords count:self.data.trackList.count textureIndex:textureIndex];
    [_mapView addOverlay:polyline];

    //添加大头针
    [self addAnnotation];
}

- (void)addAnnotation
{
    for (TrackList *trackList in self.data.trackList) {
        
        
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = [trackList.lat doubleValue];
        coor.longitude = [trackList.lon doubleValue];
        annotation.coordinate = coor;
        
        [_mapView addAnnotation:annotation];
    
//        ZYLog(@"annotation.longitude = %lf annotation.latitude= %lf",coor.longitude,coor.latitude);
    }
    
    
}

#pragma mark -- 百度地图代理

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.canShowCallout = NO;//在点击大头针的时候会弹出那个黑框框
        newAnnotationView.draggable = NO;//禁止标注在地图上拖动
        newAnnotationView.image = [UIImage imageNamed:@"ic_position"];
        
        return newAnnotationView;
    }
    return nil;
}





- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 10.0;

        polylineView.tileTexture = YES;
//        polylineView.keepScale = YES;
        polylineView.isFocus = YES;// 是否分段纹理绘制（突出显示），默认YES
        polylineView.lineDash = YES;
        //加载分段纹理图片，必须否则不能进行分段纹理绘制
        [polylineView loadStrokeTextureImages:
         [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_road_red_arrow"],
          nil]];
        
        
        return polylineView;
    }
    return nil;
}


#pragma mark -- 底部按钮赋值
- (void)bottomButtonCount:(Subject *)subject
{
    [self.viewButton setTitle:subject.viewCount forState:UIControlStateNormal];
    [self.favButton setTitle:subject.setFavCount forState:UIControlStateNormal];
    [self.voteButton setTitle:subject.voteCount forState:UIControlStateNormal];
    [self.commentButton setTitle:subject.remarkCount forState:UIControlStateNormal];
    
}



#pragma mark -- property

-(EyeAroundDetailScrollView *)contentView
{
    if (!_contentView) {
        
        EyeAroundDetailScrollView *contentView = [EyeAroundDetailScrollView detailScrollView];
        
        contentView.frame = CGRectMake(0,self.view.height * 0.25, self.view.width, kScreenHeight - NAVIGATIONBARHEIGHT - TABBARHEIGHT - self.view.height * 0.25);
//        contentView.backgroundColor = [UIColor orangeColor];
        
        
        contentView.aroundDetailBlock = ^(TrackList *trackList){
        
            CLLocationCoordinate2D coordinate;
            
            coordinate.latitude = [trackList.lat doubleValue];
            coordinate.longitude = [trackList.lon doubleValue];
            
            
            [_mapView setCenterCoordinate:coordinate animated:YES];
                
           
            
            _mapView.zoomLevel = 18;
            
            
            
        
        };
        
        
        contentView.subjectKind = self.subjectModel.subjectKind;
        
        [self.view addSubview:contentView];
        
        _contentView = contentView;
    }
    
    return _contentView;
}


-(UIView *)bottomView
{
    if (!_bottomView) {
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - TABBARHEIGHT - NAVIGATIONBARHEIGHT , self.view.width, 49)];
        bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:bottomView];
        _bottomView = bottomView;
        
        CGFloat buttonW = self.view.width / 5.0;
        CGFloat buttonH = bottomView.height;
        
        NSArray *imageArr = @[@"find_around_check",@"find_around_collect",@"find_latest_praise",@"find_latest_comment",@"find_share"];
        
        for (int i = 0; i < imageArr.count ; i ++) {
            
            EyeCustomBtn *customBtn = [self setupButtonFrame:CGRectMake(i * buttonW, 0, buttonW, buttonH) imageName:imageArr[i]];
            
            if (i == 0) {
                _viewButton = customBtn;
                
            }else if (i == 1){//收藏
                
                [customBtn setImage:[UIImage imageNamed:@"ic_shouchang_press(1)"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                _favButton = customBtn;
                
            }else if (i == 2){
                //点赞
                [customBtn setImage:[UIImage imageNamed:@"find_around_praise_Click"] forState:UIControlStateSelected];
                
                [customBtn addTarget:self action:@selector(voteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                _voteButton = customBtn;
                
            }else if (i == 3){
                [customBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
                
                _commentButton = customBtn;
                
            }else if (i == 4) {
                
                [customBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
                
                [customBtn setBackgroundColor:ZYRGBColor(171, 24, 36)];
                
                [customBtn setTitle:@"分享" forState:UIControlStateNormal];
                _shareButton = customBtn;
            }
            
            
            
            [bottomView addSubview:customBtn];
        }
        
    }
    
    return _bottomView;
}

#pragma mark -- 底部话题按钮网络请求

- (void)shareClick
{
    ZYLog(@"点击附近分享");
    [self shareClick:self withSubjectID:self.subjectModel.ID title:self.subjectModel.title];
}

//点击收藏
- (void)favButtonClick:(UIButton *)button
{
    ZYLog(@"favButtonClick");
    
    button.selected = !button.selected;
    //发送 收藏/取消收藏 请求
    [self favTopic:button.selected withSubjectId:self.subjectModel.ID success:^(id responseObj) {
        
        ZYLog(@"favTopic responseObj = %@",responseObj);
        NSString *voteCount = responseObj[@"result"][@"setFavCount"];
        [self.favButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
        
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
    } failure:^(NSError *error) {
        [self addActityText:@"网络错误" deleyTime:0.5];
        ZYLog(@"error = %@",error);
    }];

    
}

//点击点赞
- (void)voteButtonClick:(UIButton *)button
{
    ZYLog(@"voteButtonClick");
    
    button.selected = !button.selected;
    //发送 点赞/取消点赞 请求
    [self voteTopic:button.selected withSubjectId:self.subjectModel.ID success:^(id responseObj) {
        
        ZYLog(@"favTopic responseObj = %@",responseObj);
        NSString *voteCount = responseObj[@"result"][@"voteCount"];
        [self.voteButton setTitle:[NSString stringWithFormat:@"%@",voteCount] forState:UIControlStateNormal];
        
    } failure:^(NSError *error) {
        [self addActityText:@"网络错误" deleyTime:0.5];
        ZYLog(@"error = %@",error);
    }];
    
}


//点击评论按钮
-(void)commentClick
{
    //跳转到评论页面
    EyeCommentController *commentCtl = [[EyeCommentController alloc] init];
    
    commentCtl.ID = self.subjectModel.ID;
    
    [self.navigationController pushViewController:commentCtl animated:YES];
}

- (void)checkTopic
{
    [self checkTopicWithSubjectID:self.subjectModel.ID success:^(id responseObj) {
        
        ZYLog(@"查看成功 responseObj = %@",responseObj);
        NSString *viewCount = responseObj[@"result"][@"viewCount"];
        [self.viewButton setTitle:[NSString stringWithFormat:@"%ld",[viewCount integerValue]] forState:UIControlStateNormal];
        
    } failure:^(NSError *error) {
        [self addActityText:@"网络错误" deleyTime:0.5];
        ZYLog(@"error = %@",error);
    }];
}






@end
