//
//  MeLocalCollectTableViewCell.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/9/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeLocalCollectTableViewCell.h"
#import "FMDBTools.h"
#import "MyTools.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface MeLocalCollectTableViewCell () <BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) BMKGeoCodeSearch *search;

@property (nonatomic, strong) UIButton *playVideoBtn;
@end

@implementation MeLocalCollectTableViewCell

- (void)dealloc {
    
    if (self.search) {
        self.search.delegate = nil;
        self.search = nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createUI];
    }
    
    return self;
}

- (void)createUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // 头像
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 9, 37, 37)];
    _headImageView.image = GETYCIMAGE(@"default_headImage_big");
    _headImageView.layer.masksToBounds = YES;
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.layer.cornerRadius = 37/2;
    [self.contentView addSubview:_headImageView];
    
    // 用户名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(_headImageView)+11, 7, 150, 25)];
    _nameLabel.text = @"小李";
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.font = [UIFont systemFontOfSize:32*FONTCALE_Y];
    _nameLabel.textColor = RGBSTRING(@"333333");
    [self.contentView addSubview:_nameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-220, 9, 200, 15)];
    _timeLabel.text = @"15分钟前";
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    _timeLabel.textColor = RGBSTRING(@"777777");
    [self.contentView addSubview:_timeLabel];
    
    // 地址
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_X(_nameLabel), VIEW_H_Y(_nameLabel), SCREEN_WIDTH-VIEW_X(_nameLabel)-20, 15)];
    _addressLabel.text = @"无地点";
    _addressLabel.textAlignment = NSTextAlignmentLeft;
    _addressLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    _addressLabel.textColor = RGBSTRING(@"777777");
    [self.contentView addSubview:_addressLabel];
    
    // 大图
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(_headImageView)+8, SCREEN_WIDTH, 209)];
    _coverImageView.image = GETYCIMAGE(@"bg_loadimg_fail");
    _coverImageView.clipsToBounds = YES;
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_coverImageView];
    
    // 收藏信息
    UIImage *icon = GETNCIMAGE(@"me_collect_local_infoIcon.png");
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, VIEW_H_Y(_coverImageView)+16, icon.size.width, icon.size.height)];
    iconImageView.image = icon;
    [self.contentView addSubview:iconImageView];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(iconImageView)+14, VIEW_H_Y(_coverImageView), 150, 315-VIEW_H_Y(_coverImageView))];
    _infoLabel.text = @"图片";
    _infoLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    _infoLabel.textColor = RGBSTRING(@"777777");
    [self.contentView addSubview:_infoLabel];
    
    // 取消收藏按钮
    UIButton *cancelCollectBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120, VIEW_H_Y(_coverImageView), 120, 315-VIEW_H_Y(_coverImageView))];
    cancelCollectBtn.backgroundColor = RGBSTRING(@"cccccc");
    [cancelCollectBtn setImage:GETNCIMAGE(@"albums_travel_collect.png") forState:UIControlStateNormal];
    [cancelCollectBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
    [cancelCollectBtn setImageEdgeInsets:UIEdgeInsetsMake(-16, 26, 0, -26)];
    [cancelCollectBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, -7, -20, 7)];
    cancelCollectBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cancelCollectBtn.titleLabel.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [cancelCollectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelCollectBtn addTarget:self action:@selector(cancelCollectBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelCollectBtn];
    
    _playVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playVideoBtn setBackgroundImage:[UIImage imageNamed:@"find_videoPlay"] forState:UIControlStateNormal];
    [_playVideoBtn sizeToFit];
    _playVideoBtn.hidden = YES;
    [_coverImageView addSubview:_playVideoBtn];
    
    [_playVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(_coverImageView.mas_centerY);
        make.centerX.equalTo(_coverImageView.mas_centerX);
    }];

}

-(void)setFrame:(CGRect)frame
{
    frame.size.height = 315;
    
    [super setFrame:frame];
}

- (BMKGeoCodeSearch *)search {
    if (!_search) {
        _search = [[BMKGeoCodeSearch alloc] init];
        _search.delegate = self;
    }
    
    return _search;
}

- (void)setModel:(CollectModel *)model {
    _model = model;
    
    _coverImageView.image = GETYCIMAGE(@"bg_loadimg_fail");
    NSDictionary *userInfo = UserInfo;
    // 头像
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:FORMATSTRING(VALUEFORKEY(userInfo, @"portraitImgUrl"))] placeholderImage:GETYCIMAGE(@"default_headImage.png")];
    
    // 用户名
    NSString *nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"nickName"));
    if (nickName.length == 0) {
        // 昵称没有取用户名
        nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"userName"));
    }
    _nameLabel.text = nickName;
    
    _playVideoBtn.hidden = YES;
    
    NSString *type = nil;
    if ([_model.collectType isEqualToString:kCollectTypePath]) {
        // 轨迹
        type = @"轨迹";
        
        AlbumsPathModel *pathModel = [FMDBTools getPathsFromDataBaseWithFile_name:_model.collectSoruce];
        _addressLabel.text = pathModel.start_address;
        
        NSArray *pathArr =[MyTools getAllDataWithPath:Path_Small_Photo(pathModel.mac_adr) mac_adr:pathModel.mac_adr];
        for (NSString *str in pathArr)
        {
            NSString *temp_str1 = [pathModel.fileName componentsSeparatedByString:@"."][0];
            NSString *temp_str2 = [str componentsSeparatedByString:@"/"].lastObject;
            temp_str2 = [temp_str2 componentsSeparatedByString:@"."][0];
            if ([temp_str1 isEqualToString:temp_str2])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:str];
                _coverImageView.image = image;
            }
            
        }

        
    } else if ([_model.collectType isEqualToString:kCollectTypeVideo]) {
        _playVideoBtn.hidden = NO;
        // 视频
        type = @"视频";dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:_model.collectSoruce];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageData) {
                    _coverImageView.image = [UIImage imageWithData:imageData];
                } else {
                    _coverImageView.image = GETYCIMAGE(@"bg_loadimg_fail");
                }
                
                
            });
        });
        
        NSString *time = [[_model.collectSoruce componentsSeparatedByString:@"/"] lastObject];
        time = [[time componentsSeparatedByString:@"."] firstObject];
        time = [[time componentsSeparatedByString:@"_"] firstObject];
        
        // 结束时间
        NSString *endTimestring = [MyTools yearToTimestamp:time];
        NSTimeInterval endTimestamp = [endTimestring longLongValue];
        
        NSTimeInterval nowTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timestamp = nowTimestamp - endTimestamp;
        
        _timeLabel.text = [self getTimeStringWithTimestamp:timestamp endTime:endTimestring];
        _addressLabel.text = @"无地点";


    } else if ([_model.collectType isEqualToString:kCollectTypePhoto]) {
        // 图片
        type = @"图片";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:_model.collectSoruce];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageData) {
                    _coverImageView.image = [UIImage imageWithData:imageData];
                } else {
                    _coverImageView.image = GETYCIMAGE(@"bg_loadimg_fail");
                }
                
                
            });
        });
        
        _addressLabel.text = @"无地点";
        
        NSString *time = [[_model.collectSoruce componentsSeparatedByString:@"/"] lastObject];
        time = [[time componentsSeparatedByString:@"."] firstObject];
        if ([time hasPrefix:@"G"]) {
            time = [time substringFromIndex:1];
        }
        
        // 结束时间
        NSString *endTimestring = [MyTools yearToTimestamp:time];
        NSTimeInterval endTimestamp = [endTimestring longLongValue];
        
        NSTimeInterval nowTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timestamp = nowTimestamp - endTimestamp;
        
        _timeLabel.text = [self getTimeStringWithTimestamp:timestamp endTime:endTimestring];

    } else if ([_model.collectType isEqualToString:kCollectTypeTravel]) {
        // 游记
        type = @"游记";
        
        AlbumsTravelModel *travelModel = [CacheTool queryTravelsWithTravelId:_model.collectSoruce];
        NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:travelModel.travelId];
        AlbumsTravelDetailModel *detailModel = [travelDetailArray lastObject];
        
        NSString *path = [Travel_Path(travelModel.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
        NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        _coverImageView.image = image;
        
        // 结束时间
        NSString *endTimestring = [MyTools yearToTimestamp:travelModel.endTime];
        NSTimeInterval endTimestamp = [endTimestring longLongValue];
        
        NSTimeInterval nowTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timestamp = nowTimestamp - endTimestamp;
        
        _timeLabel.text = [self getTimeStringWithTimestamp:timestamp endTime:endTimestring];
        
        if (!travelModel.endPostionShow.length) {
            
            CLLocationCoordinate2D coor = [MyTools getLocationWithGPRMC:travelModel.endPostion];
            BMKReverseGeoCodeOption *codeOption = [[BMKReverseGeoCodeOption alloc] init];
            codeOption.reverseGeoPoint = coor;
            [self.search reverseGeoCode:codeOption];
        } else {
            _addressLabel.text = @"无地点";
        }
    }
    
    _infoLabel.text = type;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (result.address.length) {
        _addressLabel.text = result.address;
        
        // 更新地址到数据库
        AlbumsTravelModel *travelModel = [CacheTool queryTravelsWithTravelId:_model.collectSoruce];
        travelModel.endPostionShow = result.address;
        [CacheTool updateTravelWithTravelModel:travelModel];
    } else {
        _addressLabel.text = @"无地点";
    }
}


- (NSString *)getTimeStringWithTimestamp:(NSTimeInterval)timestamp endTime:(NSString *)endTime {
    
    NSString *timeStr = nil;
    if (timestamp >= 48*3600)
    {
        timeStr = [MyTools timestampChangesStandarTime:endTime];
    }
    else if ((timestamp<48*3600) && (timestamp >= 24*3600))
    {
        timeStr = [NSString stringWithFormat:@"昨天 %@",[MyTools timestampChangesStandarTimeHaveHoureAndMin:endTime]];
    }
    else if ((timestamp<24*3600) && (timestamp >= 1*3600))
    {
        timeStr = [NSString stringWithFormat:@"%.0f小时前",timestamp/3600];
    }
    else if (timestamp<1*3600 &&(timestamp>60))
    {
        timeStr = [NSString stringWithFormat:@"%.0f分钟前",timestamp/60];
    }
    else
    {
        timeStr = @"1分钟前";
    }
    
    return timeStr;
    
}


- (void)cancelCollectBtn_clicked_action:(UIButton *)sender {
    
    BOOL isDeleteSuccess = [FMDBTools deleteCollectWithimageUrl:_model.collectSoruce];
    
    if (isDeleteSuccess)
    {
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
    }
    
    if (self.cancelCollectBlock) {
        self.cancelCollectBlock(isDeleteSuccess);
    }
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
