//
//  AlbumsPathViewControllerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsPathViewControllerTableViewCell.h"
#import "MyTools.h"
@implementation AlbumsPathViewControllerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    AlbumsPathViewControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[AlbumsPathViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  
    }
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.addressLab = [[UILabel alloc] initWithFrame:CGRectMake(20*PSDSCALE_X, 23*PSDSCALE_Y, 500*PSDSCALE_X, 35*PSDSCALE_Y)];
        self.addressLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
        self.addressLab.textAlignment = NSTextAlignmentLeft;
        self.addressLab.text = @"深圳市清祥路1号宝能科技园";
        [self.contentView addSubview:self.addressLab];
        
        self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(self.addressLab), 27*PSDSCALE_Y, 210*PSDSCALE_X, 27*PSDSCALE_Y)];
        self.timeLab.text = @"15分钟前";
        self.timeLab.font = [UIFont systemFontOfSize:20*FONTCALE_Y];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:self.timeLab];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(28*PSDSCALE_X, VIEW_H_Y(self.addressLab)+21*PSDSCALE_Y, SCREEN_WIDTH-28*PSDSCALE_X, 1*PSDSCALE_Y)];
        
        line1.backgroundColor =RGBSTRING(@"eeeeee");
        [self.contentView addSubview:line1];
        
        self.average_speed_lab = [[UILabel alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(line1)+20*PSDSCALE_Y, 198*PSDSCALE_X, 37*PSDSCALE_Y)];
        self.average_speed_lab.textColor = RGBSTRING(@"b11c22");
        self.average_speed_lab.textAlignment = NSTextAlignmentCenter;
        self.average_speed_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
        self.average_speed_lab.text = @"60.0";
        [self.contentView addSubview:self.average_speed_lab];
        
        UIImageView *average_speed_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, VIEW_H_Y(self.average_speed_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 17*PSDSCALE_Y)];
        average_speed_imageView.image = GETYCIMAGE(@"albums_average_speed");
        [self.contentView addSubview:average_speed_imageView];
        
        UILabel *average_speed = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed_imageView)+10*PSDSCALE_X, VIEW_H_Y(self.average_speed_lab)+10*PSDSCALE_Y, 188*PSDSCALE_X, 29*PSDSCALE_Y)];
        average_speed.text = @"平均速度(km/h)";
        average_speed.textAlignment = NSTextAlignmentCenter;
        average_speed.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
        average_speed.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:average_speed];
        
        self.all_time_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed)+52*PSDSCALE_X, VIEW_H_Y(line1)+20*PSDSCALE_Y, 168*PSDSCALE_X, 37*PSDSCALE_Y)];
        self.all_time_lab.textColor = RGBSTRING(@"b11c22");
        self.all_time_lab.textAlignment = NSTextAlignmentCenter;
        self.all_time_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
        self.all_time_lab.text = @"31";
        [self.contentView addSubview:self.all_time_lab];
        
        UIImageView *all_time_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(average_speed)+52*PSDSCALE_X, VIEW_H_Y(self.all_time_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
        all_time_imageView.image = GETYCIMAGE(@"albums_all_time");
        
        [self.contentView addSubview:all_time_imageView];
        
        
        UILabel *all_time = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time_imageView)+10*PSDSCALE_X, VIEW_H_Y(self.all_time_lab)+10*PSDSCALE_Y, 157*PSDSCALE_X, 29*PSDSCALE_Y)];
        all_time.text = @"总时长(分钟)";
        all_time.textAlignment = NSTextAlignmentCenter;
        all_time.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
        all_time.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:all_time];

        self.all_mileage_lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time)+66*PSDSCALE_X, VIEW_H_Y(line1)+20*PSDSCALE_Y, 155*PSDSCALE_X, 37*PSDSCALE_Y)];

        self.all_mileage_lab.textColor = RGBSTRING(@"b11c22");
        self.all_mileage_lab.textAlignment = NSTextAlignmentCenter;
        self.all_mileage_lab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
        self.all_mileage_lab.text = @"181";
        [self.contentView addSubview:self.all_mileage_lab];

        UIImageView *all_mileage_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W_X(all_time)+67*PSDSCALE_X, VIEW_H_Y(self.all_mileage_lab)+14*PSDSCALE_Y, 20*PSDSCALE_X, 20*PSDSCALE_Y)];
        all_mileage_imageView.image = GETYCIMAGE(@"albums_all_mileage");
        [self.contentView addSubview:all_mileage_imageView];

        UILabel *all_mileage = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(all_mileage_imageView)+10*PSDSCALE_X, VIEW_H_Y(self.all_mileage_lab)+10*PSDSCALE_Y, 143*PSDSCALE_X, 29*PSDSCALE_Y)];
        all_mileage.text = @"总里程(km)";
        all_mileage.textAlignment = NSTextAlignmentCenter;
        all_mileage.font = [UIFont systemFontOfSize:22*FONTCALE_Y];
        all_mileage.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:all_mileage];
        
        self.mapImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(average_speed)+10*PSDSCALE_Y, SCREEN_WIDTH, 422*PSDSCALE_Y)];
        self.mapImage.contentMode = UIViewContentModeScaleAspectFill;
        self.mapImage.image = GETYCIMAGE(@"albums_path_default");
        [self.contentView addSubview:self.mapImage];
        
        UIButton *collect_btn = [[UIButton alloc] initWithFrame:CGRectMake(410*PSDSCALE_X, VIEW_H_Y(self.mapImage)+16*PSDSCALE_Y, 40*PSDSCALE_X, 40*PSDSCALE_Y)];
        [collect_btn setImage:GETYCIMAGE(@"album_average_collect") forState:UIControlStateNormal];
        [self.contentView addSubview:collect_btn];
        [collect_btn addTarget:self action:@selector(collect_click) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *share_btn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(collect_btn)+96*PSDSCALE_X, VIEW_H_Y(self.mapImage)+19*PSDSCALE_Y, 40*PSDSCALE_X, 37*PSDSCALE_Y)];
        [share_btn setImage:GETYCIMAGE(@"album_average_share") forState:UIControlStateNormal];
        [self.contentView addSubview:share_btn];
        [share_btn addTarget:self action:@selector(share_click) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *del_btn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W_X(share_btn)+96*PSDSCALE_X, VIEW_H_Y(self.mapImage)+17*PSDSCALE_Y, 38*PSDSCALE_X, 40*PSDSCALE_Y)];
        [del_btn setImage:GETYCIMAGE(@"album_average_del") forState:UIControlStateNormal];
        [self.contentView addSubview:del_btn];
        [del_btn addTarget:self action:@selector(delete_click) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}




- (void)refreshData:(AlbumsPathModel *)model
{
    self.model = model;
    
    NSArray *time_arr = [[model.fileName componentsSeparatedByString:@"."][0] componentsSeparatedByString:@"_"];
    
    NSString *end_time = time_arr[1];
    NSString *use_time = time_arr.lastObject;
    
    end_time = [MyTools yearToTimestamp:end_time];
    end_time = [NSString stringWithFormat:@"%lld",[end_time longLongValue]+[use_time intValue]];
    
    NSString *now_time = [MyTools getCurrentTimestamp];
    
    //时间差
    NSString *temp_time = [NSString stringWithFormat:@"%ld",[now_time integerValue]-[end_time integerValue]];
    
    if ([temp_time integerValue] >= 48*3600)
    {
        self.timeLab.text = [MyTools timestampChangesStandarTime:end_time];
    }
    else if (([temp_time integerValue]<48*3600) && ([temp_time integerValue] >= 24*3600))
    {
        self.timeLab.text = [NSString stringWithFormat:@"昨天 %@",[MyTools timestampChangesStandarTimeHaveHoureAndMin:end_time]];
    }
    else if (([temp_time integerValue]<24*3600) && ([temp_time integerValue] >= 1*3600))
    {
        self.timeLab.text = [NSString stringWithFormat:@"%ld小时前",[temp_time integerValue]/3600];
    }
    else if ([temp_time integerValue]<1*3600 &&([temp_time integerValue]>60))
    {
        self.timeLab.text = [NSString stringWithFormat:@"%ld分钟前",[temp_time integerValue]/60];
    }
    else
    {
        self.timeLab.text = @"1分钟前";
    }
    
    self.addressLab.text = model.start_address;
    self.all_mileage_lab.text = model.tirpMileage;
    self.all_time_lab.text = [NSString stringWithFormat:@"%.2f",[model.tirpTime integerValue]/60.0];
    self.average_speed_lab.text = [NSString stringWithFormat:@"%.2f",[model.tirpMileage integerValue]/([model.tirpTime integerValue]/3600.0)];
    
    
    NSArray *pathArr =[MyTools getAllDataWithPath:Path_Small_Photo(model.mac_adr) mac_adr:model.mac_adr];
    for (NSString *str in pathArr)
    {
        NSString *temp_str1 = [model.fileName componentsSeparatedByString:@"."][0];
        NSString *temp_str2 = [str componentsSeparatedByString:@"/"].lastObject;
        temp_str2 = [temp_str2 componentsSeparatedByString:@"."][0];
        if ([temp_str1 isEqualToString:temp_str2])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:str];
            self.mapImage.image = image;
        }
        
    }
    
}

- (void)delete_click
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteDataWithCell:)]) {
        [_delegate deleteDataWithCell:self];
    }
}

- (void)collect_click {
    if (_delegate && [_delegate respondsToSelector:@selector(collectDataWithCell:)]) {
        [_delegate collectDataWithCell:self];
    }
}

- (void)share_click
{
    if (_delegate && [_delegate respondsToSelector:@selector(shareDataWithCell:)]) {
        [_delegate shareDataWithCell:self];
    }
}

@end
