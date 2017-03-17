//
//  AlbumsTravelListTableViewCell.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/29.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelListTableViewCell.h"
#import "MyTools.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface AlbumsTravelListTableViewCell () <BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) UIImageView *travelImageView;
// 发布时间
@property (nonatomic, strong) UILabel *publishTimeLabel;
// 地址
@property (nonatomic, strong) UILabel *addressLabel;
// 速度
@property (nonatomic, strong) UILabel *speedLabel;
// 时长
@property (nonatomic, strong) UILabel *timeLabel;
// 里程
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) BMKGeoCodeSearch *startSearch;
@property (nonatomic, strong) BMKGeoCodeSearch *endSearch;

@property (nonatomic, copy) NSString *startAddress;
@property (nonatomic, copy) NSString *endAddress;
@end

@implementation AlbumsTravelListTableViewCell

- (void)dealloc {
    
    if (self.startSearch) {
        self.startSearch.delegate = nil;
        self.startSearch = nil;
    }
    
    if (self.endSearch) {
        self.endSearch.delegate = nil;
        self.endSearch = nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    
    _travelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 68)];
    _travelImageView.contentMode = UIViewContentModeScaleAspectFill;
    _travelImageView.clipsToBounds = YES;
    _travelImageView.image = GETNCIMAGE(@"camera_detail_video_bg.png");
    [self.contentView addSubview:_travelImageView];
    
    // 箭头
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_right_arrow.png")];
    [self.contentView addSubview:rightArrowImageView];
    [rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-10);
        make.top.mas_equalTo(self.mas_top).with.offset(10);
    }];
    
    _publishTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(_travelImageView) + 10, 10, SCREEN_WIDTH - (VIEW_W_X(_travelImageView) + 20 + VIEW_W(rightArrowImageView)), 14)];
    _publishTimeLabel.font = [UIFont systemFontOfSize:20 * FONTCALE_Y];
    _publishTimeLabel.text = @"15分钟前";
    _publishTimeLabel.textColor = RGBSTRING(@"a0a0a0");
    [self.contentView addSubview:_publishTimeLabel];
    
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_X(_publishTimeLabel), 30, VIEW_W(_publishTimeLabel), 56)];
    _addressLabel.font = [UIFont systemFontOfSize:28 * FONTCALE_Y];
    _addressLabel.text = @"深圳市清祥路1号宝能科技园->深圳市麻雀岭秀软科技";
    _addressLabel.numberOfLines = 3;
    _addressLabel.textColor = RGBSTRING(@"a0a0a0");
    [self.contentView addSubview:_addressLabel];
    _addressLabel.attributedText = LINESPACING(_addressLabel.text, 5, RGBSTRING(@"a0a0a0"), 28 * FONTCALE_Y);
    
    NSArray *valuesArray = @[@"60.0", @"31", @"181"];
    NSArray *namesArray = @[@" 平均速度 (km/h)", @" 总时长 (分钟)", @" 总里程 (km)"];
    NSArray *iconsArray  =@[GETNCIMAGE(@"albums_average_speed.png"), GETNCIMAGE(@"albums_all_time.png"), GETNCIMAGE(@"albums_all_mileage.png")];
    for (NSInteger i = 0; i < namesArray.count; i++) {
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * (SCREEN_WIDTH) / 3, VIEW_H_Y(_travelImageView) + 13, SCREEN_WIDTH / 3, 23)];
        valueLabel.textColor = RGBSTRING(@"b11c22");
        valueLabel.font = [UIFont systemFontOfSize:30 * FONTCALE_Y];
        valueLabel.text = [valuesArray objectAtIndex:i];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.tag = i + 1;
        [self.contentView addSubview:valueLabel];
        
        UIButton *nameBtn = [[UIButton alloc] initWithFrame:CGRectMake(i * (SCREEN_WIDTH) / 3, VIEW_H_Y(valueLabel), SCREEN_WIDTH / 3, 22)];
        [nameBtn setImage:iconsArray[i] forState:UIControlStateNormal];
        [nameBtn setTitle:namesArray[i] forState:UIControlStateNormal];
        [nameBtn setTitleColor:RGBSTRING(@"a0a0a0") forState:UIControlStateNormal];
        nameBtn.titleLabel.font = [UIFont systemFontOfSize:22 * FONTCALE_Y];
        nameBtn.userInteractionEnabled  =NO;
        [self.contentView addSubview:nameBtn];
    }
    
}

- (void)setModel:(AlbumsTravelModel *)model {
    
    _model = model;
    
    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:_model.travelId];
    AlbumsTravelDetailModel *detailModel = [travelDetailArray lastObject];
    
    NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    _travelImageView.image = image;

    
    // 游记开始时间
    NSString *startTimestring = [MyTools yearToTimestamp:_model.startTime];
    NSTimeInterval startTimestamp = [startTimestring doubleValue];
    
    // 结束时间
    NSString *endTimestring = [MyTools yearToTimestamp:_model.endTime];
    NSTimeInterval endTimestamp = [endTimestring doubleValue];
    
    // 总时间
    NSTimeInterval allTimestamp = endTimestamp - startTimestamp;
    NSString *allMinuteStr = [NSString stringWithFormat:@"%.0f", allTimestamp / 60];
    
    NSString *speed = [NSString stringWithFormat:@"%.1f", [_model.tirpMileage doubleValue] / (allTimestamp / 3600)];
    
    NSString *tirpMileage = FORMATSTRING(_model.tirpMileage);
    if (tirpMileage.length == 0) {
        tirpMileage = @"0";
    }
    
    NSArray *valuesArray = @[speed, allMinuteStr, tirpMileage];
    for (NSInteger i = 0; i < valuesArray.count; i++) {
        UILabel *valueLabel = (UILabel *)[self.contentView viewWithTag:i + 1];
        valueLabel.text = valuesArray[i];
    }
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval nowTimestamp = [dat timeIntervalSince1970];
    NSTimeInterval timestamp = nowTimestamp - endTimestamp;
    
     _publishTimeLabel.text = [self getTimeStringWithTimestamp:timestamp endTime:endTimestring];

    _addressLabel.text = nil;
    
    CLLocationCoordinate2D startCoor;
    CLLocationCoordinate2D endCoor;
    // 开始地址和结束地址
    BMKReverseGeoCodeOption *endOption = nil;
    BMKReverseGeoCodeOption *startOption = nil;
    if (_model.startPostionShow.length && _model.endPostionShow.length) {
        // 如果有开始地址和结束直接显示
        self.startAddress = _model.startPostionShow;
        self.endAddress = _model.endPostionShow;
    } else if (_model.startPostionShow.length) {
        // 没有显示“未知地名”， 并反地理编码获取地址
        self.startAddress = _model.startPostionShow;
        self.endAddress = @"未知地名";
        
        endCoor = [MyTools getLocationWithGPRMC:_model.endPostion];
        endOption = [[BMKReverseGeoCodeOption alloc] init];
        endOption.reverseGeoPoint = endCoor;
    } else if (_model.endPostionShow.length) {
        self.startAddress = @"未知地名";
        self.endAddress = _model.endPostionShow;
        
        // 开始地址
        startCoor = [MyTools getLocationWithGPRMC:_model.startPostion];
        startOption = [[BMKReverseGeoCodeOption alloc] init];
        startOption.reverseGeoPoint = startCoor;
    } else {
        // 开始地址和结束地址都不存在，两个都要反地理编码
        startCoor = [MyTools getLocationWithGPRMC:_model.startPostion];
        startOption = [[BMKReverseGeoCodeOption alloc] init];
        startOption.reverseGeoPoint = startCoor;
        endCoor = [MyTools getLocationWithGPRMC:_model.endPostion];
        endOption = [[BMKReverseGeoCodeOption alloc] init];
        endOption.reverseGeoPoint = endCoor;
        
         self.startAddress = @"未知地名";
        self.endAddress = @"未知地名";
    }
    
    _addressLabel.text = [NSString stringWithFormat:@"%@->%@", self.startAddress, self.endAddress];
    
    if (startOption) {
        [self.startSearch reverseGeoCode:startOption];
    }
    
    if (endOption) {
        [self.endSearch reverseGeoCode:endOption];
    }
}


/**
 根据时间去显示时间

 @param timestamp 时间戳
 @param endTime 结束时间
 @return 要显示的时间
 */
- (NSString *)getTimeStringWithTimestamp:(NSTimeInterval)timestamp endTime:(NSString *)endTime {
    
    NSString *timeStr = nil;
    if (timestamp >= 24*3600)
    {
        // 如果大于两天，直接显示MM-dd HH:mm
        timeStr = [MyTools timestampChangesStandarTime:endTime];
    }
//    else if ((timestamp<48*3600) && (timestamp >= 24*3600))
//    {
//        // 大于一天小于两天，显示昨天几点几点
//        timeStr = [NSString stringWithFormat:@"昨天 %@",[MyTools timestampChangesStandarTimeHaveHoureAndMin:endTime]];
//    }
    else if ((timestamp<24*3600) && (timestamp >= 1*3600))
    {
        // 小于一天，大于一小时，显示xx小时前
        timeStr = [NSString stringWithFormat:@"%.0f小时前",timestamp/3600];
    }
    else if (timestamp<1*3600 &&(timestamp>60))
    {
        // 小于一小时大于60s 显示xx分钟前
        timeStr = [NSString stringWithFormat:@"%.0f分钟前",timestamp/60];
    }
    else
    {
        timeStr = @"1分钟前";
    }
    
    return timeStr;

}

/**
 开始地址反地理编码

 @return 反地理编码类
 */
- (BMKGeoCodeSearch *)startSearch {
    
    if (!_startSearch) {
        _startSearch = [[BMKGeoCodeSearch alloc] init];
        _startSearch.delegate = self;
    }
    
    return _startSearch;
}
/**
 结束地址反地理编码
 
 @return 反地理编码类
 */
- (BMKGeoCodeSearch *)endSearch {
    if (!_endSearch) {
        _endSearch = [[BMKGeoCodeSearch alloc] init];
        _endSearch.delegate = self;
    }
    
    return _endSearch;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (searcher == self.startSearch) {
        
        if (result.address.length) {
            self.startAddress = result.address;
            
            // 更新地址到数据库
            _model.startPostionShow = result.address;
            [CacheTool updateTravelWithTravelModel:_model];
        } else {
            self.startAddress = @"未知地名";
        }
    } else {
        if (result.address.length) {
            self.endAddress = result.address;
            
            // 更新地址到数据库
            _model.endPostionShow = result.address;
            [CacheTool updateTravelWithTravelModel:_model];
        } else {
            self.endAddress = @"未知地名";
        }
    }
    
    _addressLabel.text = [NSString stringWithFormat:@"%@->%@", self.startAddress, self.endAddress];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
