 //
//  AlbumsPathDetailViewController.m
//  KaKa
//
//  Created by Change_pan on 16/8/3.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsPathDetailViewController.h"
#import "MyTools.h"
#import "FMDBTools.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "EyeShareTrackController.h"
#import "AlbumsPathViewController.h"
#import "MeTrajectoryViewController.h"
@interface AlbumsPathDetailViewController ()<BMKGeoCodeSearchDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch1;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch2;
@end

@implementation AlbumsPathDetailViewController
{
    UIImageView *headView;//头像
    UILabel *nameLab;//姓名
    UILabel *timeLab;//时间
    UILabel *startAddress;//开始地址
    UILabel *endAddress;//停止地址
    UIImageView *mapView;//地图
    UILabel *average_speed_lab;//平均速度
    UILabel *all_time_lab;//总时间
    UILabel *all_mileage_lab;//总里程
    UIScrollView *_scrollView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"轨迹预览" wordNun:4];
    _scrollView.backgroundColor = RGBSTRING(@"f5f8fa");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    //初始化逆地理编码
    BMKGeoCodeSearch *search1 = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch1 = search1;
    
    BMKGeoCodeSearch *search2 = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch2 = search2;
    [self initUI];
}

#pragma mark - 初始化界面

- (void)initUI
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    headView = [[UIImageView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, 31*PSDSCALE_Y, 70*PSDSCALE_X, 70*PSDSCALE_Y)];
    headView.layer.masksToBounds = YES;
    headView.layer.cornerRadius = 35*PSDSCALE_X;
    [_scrollView addSubview:headView];
    NSDictionary *userInfo = UserInfo;
    // 头像
    [headView sd_setImageWithURL:[NSURL URLWithString:FORMATSTRING(VALUEFORKEY(userInfo, @"portraitImgUrl"))] placeholderImage:GETYCIMAGE(@"default_headImage_big.png")];
    nameLab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(headView)+30*PSDSCALE_X, 50*PSDSCALE_Y, 350*PSDSCALE_X, 39*PSDSCALE_Y)];
    nameLab.text = FORMATSTRING(VALUEFORKEY(userInfo, @"nickName"));
    nameLab.textAlignment = NSTextAlignmentLeft;
    nameLab.font = [UIFont systemFontOfSize:32*FONTCALE_Y];
    nameLab.textColor = RGBSTRING(@"333333");
    [_scrollView addSubview:nameLab];
    
    timeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220*PSDSCALE_X, 34*PSDSCALE_Y, 200*PSDSCALE_X, 27*PSDSCALE_Y)];
    
    NSArray *time_arr = [[self.model.fileName componentsSeparatedByString:@"."][0] componentsSeparatedByString:@"_"];
    
    NSString *end_time = time_arr[1];
    NSString *use_time = time_arr.lastObject;
    
    end_time = [MyTools yearToTimestamp:end_time];
    end_time = [NSString stringWithFormat:@"%lld",[end_time longLongValue]+[use_time intValue]];
    
    NSString *now_time = [MyTools getCurrentTimestamp];
    
    //时间差
    NSString *temp_time = [NSString stringWithFormat:@"%ld",[now_time integerValue]-[end_time integerValue]];
    
    if ([temp_time integerValue] >= 48*3600)
    {
        timeLab.text = [MyTools timestampChangesStandarTime:end_time];
    }
    else if (([temp_time integerValue]<48*3600) && ([temp_time integerValue] >= 24*3600))
    {
        timeLab.text = [NSString stringWithFormat:@"昨天 %@",[MyTools timestampChangesStandarTimeHaveHoureAndMin:end_time]];
    }
    else if (([temp_time integerValue]<24*3600) && ([temp_time integerValue] >= 1*3600))
    {
       timeLab.text = [NSString stringWithFormat:@"%ld小时前",[temp_time integerValue]/3600];
    }
    else if ([temp_time integerValue]<1*3600 &&([temp_time integerValue]>60))
    {
        timeLab.text = [NSString stringWithFormat:@"%ld分钟前",[temp_time integerValue]/60];
    }
    else
    {
        timeLab.text = @"1分钟前";
    }
    
    
    timeLab.textAlignment = NSTextAlignmentRight;
    timeLab.font = [UIFont systemFontOfSize:20*FONTCALE_Y];
    timeLab.textColor = RGBSTRING(@"777777");
    [_scrollView addSubview:timeLab];
    
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(28*PSDSCALE_X, VIEW_H_Y(headView)+20*PSDSCALE_Y, SCREEN_WIDTH-28*PSDSCALE_X, 1*PSDSCALE_Y)];
    line.backgroundColor = RGBSTRING(@"eeeeee");
    [_scrollView addSubview:line];
    
    UIView *startView = [[UIView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(line)+30*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    startView.backgroundColor = RGBSTRING(@"2fa820");
    startView.layer.masksToBounds = YES;
    startView.layer.cornerRadius = 10*PSDSCALE_X;
    [_scrollView addSubview:startView];
    
    startAddress = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(startView)+30*PSDSCALE_X, VIEW_H_Y(line)+20*PSDSCALE_Y, SCREEN_WIDTH-VIEW_W_X(startView)+30*PSDSCALE_X, 35*PSDSCALE_Y)];
    startAddress.textColor = RGBSTRING(@"333333");
    
    startAddress.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
    
    startAddress.textAlignment = NSTextAlignmentLeft;
    startAddress.text = @"深圳市南山区宝能科技园";
    
    //1.创建经纬度结构体
    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake([self.model.start_lat doubleValue], [self.model.start_long doubleValue]);
    [self GeoCodeSearchCoordinate:center1 geoCodeSearch:_geoCodeSearch1];
    [_scrollView addSubview:startAddress];
    
    UIView *endView = [[UIView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(startView)+35*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    endView.backgroundColor = RGBSTRING(@"b11c22");
    endView.layer.masksToBounds = YES;
    endView.layer.cornerRadius = 10*PSDSCALE_X;
    [_scrollView addSubview:endView];
    
    endAddress = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(startView)+30*PSDSCALE_X, VIEW_H_Y(startAddress)+23*PSDSCALE_Y, SCREEN_WIDTH-VIEW_W_X(startView)+30*PSDSCALE_X, 35*PSDSCALE_Y)];
    endAddress.textColor = RGBSTRING(@"333333");
    endAddress.font = [UIFont systemFontOfSize:28*PSDSCALE_Y];
    endAddress.textAlignment = NSTextAlignmentLeft;
    endAddress.text = @"深圳市南山区宝能科技园";
    
    //创建经纬度结构体
    CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake([self.model.end_lat doubleValue], [self.model.end_long doubleValue]);
    [self GeoCodeSearchCoordinate:center2 geoCodeSearch:_geoCodeSearch2];
    [_scrollView addSubview:endAddress];
    
    mapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(endAddress)+24*PSDSCALE_Y, SCREEN_WIDTH, 720*PSDSCALE_Y)];
    mapView.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *pathArr =[MyTools getAllDataWithPath:Path_Photo(self.model.mac_adr) mac_adr:self.model.mac_adr];
    
    NSString *image_url;
    for (NSString *str in pathArr)
    {
        NSString *temp_str1 = [self.model.fileName componentsSeparatedByString:@"."][0];
        NSString *temp_str2 = [str componentsSeparatedByString:@"/"].lastObject;
        temp_str2 = [temp_str2 componentsSeparatedByString:@"."][0];
        if ([temp_str1 isEqualToString:temp_str2])
        {
            image_url = str;
            break;
        }
    }
    
    if (image_url.length)
    {
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:image_url];
        mapView.image = image;
    }
    else
    {
        mapView.image = GETYCIMAGE(@"albums_path_default");
    }

    
//    mapView.image = GETYCIMAGE(@"albums_guiji");
    [_scrollView addSubview:mapView];
    
    
    average_speed_lab = [[UILabel alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(mapView)+40*PSDSCALE_Y, 198*PSDSCALE_X, 37*PSDSCALE_Y)];
    average_speed_lab.textColor = RGBSTRING(@"b11c22");
    average_speed_lab.textAlignment = NSTextAlignmentCenter;
    average_speed_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    average_speed_lab.text = [NSString stringWithFormat:@"%.2f",[self.model.tirpMileage integerValue]/([self.model.tirpTime integerValue]/3600.0)];;
    
    [_scrollView addSubview:average_speed_lab];
    
    UIImageView *average_speed_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(average_speed_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 17*PSDSCALE_Y)];
    average_speed_imageView.image = GETYCIMAGE(@"albums_average_speed");
    [_scrollView addSubview:average_speed_imageView];
    
    UILabel *average_speed = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed_imageView)+10*PSDSCALE_X, VIEW_H_Y(average_speed_lab)+10*PSDSCALE_Y, 188*PSDSCALE_X, 29*PSDSCALE_Y)];
    average_speed.text = @"平均速度(km/h)";
    average_speed.textAlignment = NSTextAlignmentCenter;
    average_speed.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
    average_speed.textColor = RGBSTRING(@"777777");
    [_scrollView addSubview:average_speed];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed)+32*PSDSCALE_X, VIEW_H_Y(mapView)+22*PSDSCALE_Y, 1*PSDSCALE_X, 100*PSDSCALE_Y)];
    line2.backgroundColor = RGBSTRING(@"eeeeee");
    [_scrollView addSubview:line2];
    
    all_time_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed)+62*PSDSCALE_X, VIEW_H_Y(mapView)+40*PSDSCALE_Y, 168*PSDSCALE_X, 37*PSDSCALE_Y)];
    all_time_lab.textColor = RGBSTRING(@"b11c22");
    all_time_lab.textAlignment = NSTextAlignmentCenter;
    all_time_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    all_time_lab.text = [NSString stringWithFormat:@"%.2f",[self.model.tirpTime integerValue]/60.0];;
    [_scrollView addSubview:all_time_lab];
    
    UIImageView *all_time_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed)+62*PSDSCALE_X, VIEW_H_Y(all_time_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    all_time_imageView.image = GETYCIMAGE(@"albums_all_time");
    
    [_scrollView addSubview:all_time_imageView];
    
    
    UILabel *all_time = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time_imageView)+10*PSDSCALE_X, VIEW_H_Y(all_time_lab)+10*PSDSCALE_Y, 157*PSDSCALE_X, 29*PSDSCALE_Y)];
    all_time.text = @"总时长(分钟)";
    all_time.textAlignment = NSTextAlignmentCenter;
    all_time.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
    all_time.textColor = RGBSTRING(@"777777");
    [_scrollView addSubview:all_time];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time)+22*PSDSCALE_X, VIEW_H_Y(mapView)+22*PSDSCALE_Y, 1*PSDSCALE_X, 100*PSDSCALE_Y)];
    line3.backgroundColor = RGBSTRING(@"eeeeee");
    [_scrollView addSubview:line3];

    all_mileage_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time)+66*PSDSCALE_X, VIEW_H_Y(mapView)+40*PSDSCALE_Y, 155*PSDSCALE_X, 37*PSDSCALE_Y)];
    
    all_mileage_lab.textColor = RGBSTRING(@"b11c22");
    all_mileage_lab.textAlignment = NSTextAlignmentCenter;
    all_mileage_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    all_mileage_lab.text = self.model.tirpMileage;
    [_scrollView addSubview:all_mileage_lab];
    
    UIImageView *all_mileage_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time)+67*PSDSCALE_X, VIEW_H_Y(all_mileage_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
    all_mileage_imageView.image = GETYCIMAGE(@"albums_all_mileage");
    [_scrollView addSubview:all_mileage_imageView];
    
    UILabel *all_mileage = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_mileage_imageView)+10*PSDSCALE_X, VIEW_H_Y(all_mileage_lab)+10*PSDSCALE_Y, 143*PSDSCALE_X, 29*PSDSCALE_Y)];
    all_mileage.text = @"总里程(km)";
    all_mileage.textAlignment = NSTextAlignmentCenter;
    all_mileage.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
    all_mileage.textColor = RGBSTRING(@"777777");
    [_scrollView addSubview:all_mileage];
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(line2)+23*PSDSCALE_Y, SCREEN_WIDTH, 1*PSDSCALE_Y)];
    line4.backgroundColor = RGBSTRING(@"eeeeee");
    [_scrollView addSubview:line4];
    
    if ([self.superVC isKindOfClass:[AlbumsPathViewController class]] ||[self.superVC isKindOfClass:[MeTrajectoryViewController class]])
    {
        UIButton *collect_btn = [[UIButton alloc] initWithFrame:CGRectMake(410*PSDSCALE_X, VIEW_H_Y(line4)+24*PSDSCALE_Y, 40*PSDSCALE_X, 40*PSDSCALE_Y)];
        [collect_btn setImage:GETYCIMAGE(@"album_average_collect") forState:UIControlStateNormal];
        [collect_btn addTarget:self action:@selector(collect_click) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:collect_btn];
        
        UIButton *share_btn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(collect_btn)+96*PSDSCALE_X, VIEW_H_Y(line4)+24*PSDSCALE_Y, 40*PSDSCALE_X, 37*PSDSCALE_Y)];
        [share_btn setImage:GETYCIMAGE(@"album_average_share") forState:UIControlStateNormal];
        
        [share_btn addTarget:self action:@selector(share_click) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:share_btn];
        
        UIButton *del_btn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(share_btn)+96*PSDSCALE_X, VIEW_H_Y(line4)+24*PSDSCALE_Y, 38*PSDSCALE_X, 40*PSDSCALE_Y)];
        [del_btn setImage:GETYCIMAGE(@"album_average_del") forState:UIControlStateNormal];
        [del_btn addTarget:self action:@selector(delete_click) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:del_btn];
        
        _scrollView.contentSize = CGSizeMake(0, VIEW_H_Y(del_btn)+40*PSDSCALE_Y);
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(0, VIEW_H_Y(line4)+40*PSDSCALE_Y);
    }

    
    
    
}

- (void)collect_click {
    // 收藏
    if ([FMDBTools selectContactMember:[NSString stringWithFormat:@"%@", self.model.fileName] userName:UserName])
    {
        [self addActityText:@"不能重复收藏" deleyTime:1];
        return;
    }
    
    if ([FMDBTools saveContactsWithImageUrl:[NSString stringWithFormat:@"%@", self.model.fileName] type:kCollectTypePath])
    {
        [self addActityText:@"收藏成功" deleyTime:1];
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
    }
    else
    {
        [self addActityText:@"收藏失败" deleyTime:1];
    }

}

- (void)delete_click
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定删除该记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            BOOL isSussess = [FMDBTools updatePathdelWithFile_name:self.model.fileName userName:UserName];
            
            if (isSussess) {
                
                NSString *temp_path = [Path_Photo(_model.mac_adr) stringByAppendingPathComponent:self.model.fileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path])
                {
                    BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:temp_path error:nil];
                    
                    if (isSuccess)
                    {
                        temp_path = [Path_Small_Photo(_model.mac_adr) stringByAppendingPathComponent:self.model.fileName];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path])
                        {
                            if ([[NSFileManager defaultManager] removeItemAtPath:temp_path error:nil])
                            {
                                if ([FMDBTools selectContactMember:self.model.fileName userName:UserName])
                                {
                                    // 有收藏，先删除收藏
                                    BOOL isDeleteSuccess = [FMDBTools deleteCollectWithimageUrl:self.model.fileName];
                                    if (isDeleteSuccess)
                                    {
                                        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
                                    }
                                }
                                self.block();
                                [self.navigationController popViewControllerAnimated:YES];
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


- (void)share_click
{
    ZYLog(@"轨迹预览");
    EyeShareTrackController *ctl = [EyeShareTrackController new];
    
    ctl.model = self.model;
    
    [self.navigationController pushViewController:ctl animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _geoCodeSearch1.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geoCodeSearch2.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 不用时，置nil
    _geoCodeSearch1.delegate = nil;
    _geoCodeSearch2.delegate = nil;
}


- (void)GeoCodeSearchCoordinate:(CLLocationCoordinate2D)coordinate geoCodeSearch:(BMKGeoCodeSearch *)geoCodeSearch
{
    
    //初始化逆地理编码类
    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    //需要逆地理编码的坐标位置
    reverseGeoCodeOption.reverseGeoPoint = coordinate;
    if (geoCodeSearch == _geoCodeSearch1)
    {
        [_geoCodeSearch1 reverseGeoCode:reverseGeoCodeOption];
    }
    else
    {
        [_geoCodeSearch2 reverseGeoCode:reverseGeoCodeOption];
    }
    
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
    if (searcher == _geoCodeSearch1)
    {
        startAddress.text = result.address;
    }
    else
    {
        endAddress.text = result.address;
    }
    
}


@end
