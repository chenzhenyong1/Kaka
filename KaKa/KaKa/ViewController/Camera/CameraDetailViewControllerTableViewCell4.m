//
//  CameraDetailViewControllerTableViewCell4.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailViewControllerTableViewCell4.h"
#import "CameraTime_lineModel.h"
@implementation CameraDetailViewControllerTableViewCell4
{
    UIView *line2;
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell4";
    CameraDetailViewControllerTableViewCell4 *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (cell == nil) {
        cell = [[CameraDetailViewControllerTableViewCell4 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.tishiImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50*PSDSCALE_Y)/2, 25*PSDSCALE_Y, 50*PSDSCALE_X, 50*PSDSCALE_Y)];
        self.tishiImage.layer.masksToBounds = YES;
        self.tishiImage.layer.cornerRadius = 25*PSDSCALE_X;
        self.tishiImage.image = GETYCIMAGE(@"camera_E");
        [self.contentView addSubview:self.tishiImage];
        
        self.mileage_lab = [[UILabel alloc] initWithFrame:CGRectMake(28*PSDSCALE_X, 0, 300*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.mileage_lab.text = @"里程4.44Km";
        self.mileage_lab.textAlignment = NSTextAlignmentLeft;
        self.mileage_lab.textColor = RGBSTRING(@"666666");
        self.mileage_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:self.mileage_lab];
        
        self.average_velocity = [[UILabel alloc] initWithFrame:CGRectMake(28*PSDSCALE_X, VIEW_H_Y(self.mileage_lab)+17*PSDSCALE_Y, 300*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.average_velocity.text = @"平均时速15.5Km/h";
        self.average_velocity.textAlignment = NSTextAlignmentLeft;
        self.average_velocity.textColor = RGBSTRING(@"666666");
        self.average_velocity.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:self.average_velocity];
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-300*PSDSCALE_X, 23*PSDSCALE_Y, 265*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.time_lab.text = @"00:00~07:21";
        self.time_lab.textAlignment = NSTextAlignmentRight;
        self.time_lab.textColor = RGBSTRING(@"666666");
        self.time_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:self.time_lab];
        
        
    }
    return self;
}

- (void)refreshData:(CameraTime_lineModel *)model dataSource:(NSMutableArray *)dataSource indexPath:(NSIndexPath *)indexPath
{
    NSString *time = [model.time substringWithRange:NSMakeRange(8, 4)];
    NSMutableString *time1 = [[NSMutableString alloc] initWithString:time];
    [time1 insertString:@":" atIndex:2];
    self.time_lab.text = [NSString stringWithFormat:@"%@",time1];
    
    [self.line1 removeFromSuperview];
    self.line1 = nil;
    
    [line2 removeFromSuperview];
    line2 = nil;
    
    if (indexPath.row < dataSource.count-1)
    {
        CameraTime_lineModel *temp_model = dataSource[indexPath.row+1];
        if ([temp_model.type isEqualToString:@"P"])
        {
            self.line1 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, VIEW_H_Y(self.tishiImage)+20*PSDSCALE_Y, 1, 20*PSDSCALE_Y)];
            self.line1.backgroundColor = RGBSTRING(@"333333");
            [self.contentView addSubview:self.line1];
        }
        
        if (indexPath.row > 0)
        {
            temp_model = dataSource[indexPath.row-1];
            line2 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, 0, 1, 10*PSDSCALE_Y)];
            line2.backgroundColor = RGBSTRING(@"333333");
            [self.contentView addSubview:line2];
            
        }
    }
    

    
    self.mileage_lab.text = [NSString stringWithFormat:@"里程%dKm",[model.tirpMileage intValue]];
    
    if ([model.tirpTime doubleValue] != 0) {
        self.average_velocity.text = [NSString stringWithFormat:@"平均时速%.1fKm/h", [model.tirpMileage doubleValue]/([model.tirpTime doubleValue]/3600)];
    }
    
}


@end
