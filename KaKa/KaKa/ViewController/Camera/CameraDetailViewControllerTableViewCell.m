//
//  CameraDetailViewControllerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailViewControllerTableViewCell.h"
#import "CameraTime_lineModel.h"
#import "MyTools.h"

@interface  CameraDetailViewControllerTableViewCell () <BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKGeoCodeSearch *geocodeSearch;
@property (nonatomic, strong) UILabel *address_lab;
@end

@implementation CameraDetailViewControllerTableViewCell

- (void)dealloc {
    
    if (self.geocodeSearch) {
        self.geocodeSearch.delegate = nil;
        self.geocodeSearch = nil;
    }
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell1";
    CameraDetailViewControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (cell == nil) {
        cell = [[CameraDetailViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *location = [[UIImageView alloc] initWithFrame:CGRectMake(29*PSDSCALE_X, 25*PSDSCALE_Y, 19*PSDSCALE_X, 25*PSDSCALE_Y)];
        location.image = GETYCIMAGE(@"camera_location");
        [self.contentView addSubview:location];
        
        UILabel *address_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(location)+14*PSDSCALE_X, (82*PSDSCALE_Y - 62*PSDSCALE_Y)/2-3*PSDSCALE_Y, 280*PSDSCALE_X, 62*PSDSCALE_Y)];
        address_lab.text = @"未知地名";
        address_lab.textAlignment = NSTextAlignmentLeft;
        address_lab.textColor = RGBSTRING(@"666666");
        address_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        address_lab.numberOfLines = 2;
        [self.contentView addSubview:address_lab];
        _address_lab = address_lab;
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-300*PSDSCALE_X, 28*PSDSCALE_Y, 265*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.time_lab.text = @"00:00~07:21";
        self.time_lab.textAlignment = NSTextAlignmentRight;
        self.time_lab.textColor = RGBSTRING(@"666666");
        self.time_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:self.time_lab];
        
        UIImageView *tishiImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50*PSDSCALE_Y)/2, 21*PSDSCALE_Y, 50*PSDSCALE_X, 50*PSDSCALE_Y)];
        tishiImage.layer.masksToBounds = YES;
        tishiImage.layer.cornerRadius = 25*PSDSCALE_X;
        tishiImage.image = GETYCIMAGE(@"camera_P");
        [self.contentView addSubview:tishiImage];
    }
    return self;
}

- (void)refreshData:(CameraTime_lineModel *)model
{
    NSString *startTime = nil;
    if (model.startTime.length < 14) {
        startTime =[NSString stringWithFormat:@"%@000000",[model.endTime substringWithRange:NSMakeRange(0, model.endTime.length-6)]];
        startTime = [MyTools yearToTimestamp:startTime];
    } else {
        startTime = [MyTools yearToTimestamp:model.startTime];
    }
    NSString *endTime = [MyTools yearToTimestamp:model.endTime];
    
    long long time = [endTime longLongValue]-[startTime longLongValue];
    
    NSString *allTime =[NSString stringWithFormat:@"%lld",time];
    
    if ([allTime longLongValue]>=86400)
    {
        if ([allTime longLongValue] == 86400)
        {
            self.time_lab.text = @"1天";
        }
        else
        {
            int day = (int)[allTime longLongValue]/86400;
            
            int hour = (int)([allTime longLongValue]-day*86400)/3600;
            
            int mintue = (int)([allTime longLongValue]-day*86400-hour*3600)/60;
            
            self.time_lab.text = [NSString stringWithFormat:@"%d天%d时%d分钟",day,hour,mintue];
        }
    }
    else
    {
        
        if ([allTime longLongValue] >=3600)
        {
            int hour = (int)[allTime longLongValue]/3600;
            
            int mintue = (int)([allTime longLongValue]-hour*3600)/60;
            
            self.time_lab.text = [NSString stringWithFormat:@"%d时%d分钟",hour,mintue];
        }
        else
        {
            int mintue = (int)[allTime longLongValue]/60;
            
            self.time_lab.text = [NSString stringWithFormat:@"%d分钟",mintue];
        }
        
    }
    
    CLLocationCoordinate2D gpsCoor = [MyTools getLocationWithGPRMC:model.gps];
    BMKReverseGeoCodeOption *gpsOption = [[BMKReverseGeoCodeOption alloc] init];
    gpsOption.reverseGeoPoint = gpsCoor;
    
    [self.geocodeSearch reverseGeoCode:gpsOption];
}

- (BMKGeoCodeSearch *)geocodeSearch {
    
    if (!_geocodeSearch) {
        _geocodeSearch = [[BMKGeoCodeSearch alloc] init];
        _geocodeSearch.delegate = self;
    }
    
    return _geocodeSearch;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (result.address.length) {
        // 更新地址到数据库
        _address_lab.text = result.address;
    } else {
        _address_lab.text = @"未知地名";
    }
    
}


@end
