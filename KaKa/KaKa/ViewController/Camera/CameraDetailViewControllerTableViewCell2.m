//
//  CameraDetailViewControllerTableViewCell2.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailViewControllerTableViewCell2.h"
#import "CameraTime_lineModel.h"
@implementation CameraDetailViewControllerTableViewCell2
{
    UIView *line2;
    UIImageView *tishiImage;
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell2";
    CameraDetailViewControllerTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (cell == nil) {
        cell = [[CameraDetailViewControllerTableViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, 0, 1, 40*PSDSCALE_Y)];
        line1.backgroundColor = RGBSTRING(@"333333");
        [self.contentView addSubview:line1];
        
        tishiImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50*PSDSCALE_Y)/2, VIEW_H_Y(line1)+17*PSDSCALE_Y, 50*PSDSCALE_X, 50*PSDSCALE_Y)];
        tishiImage.layer.masksToBounds = YES;
        tishiImage.layer.cornerRadius = 25*PSDSCALE_X;
        tishiImage.image = GETYCIMAGE(@"camera_S");
        [self.contentView addSubview:tishiImage];
        
        
        UILabel *tishiLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 73*PSDSCALE_Y, 160*PSDSCALE_X, 32*PSDSCALE_Y)];
        tishiLab.text = @"开始行车";
        tishiLab.textAlignment = NSTextAlignmentRight;
        
        tishiLab.textColor = RGBSTRING(@"666666");
        tishiLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:tishiLab];
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-300*PSDSCALE_X, 76*PSDSCALE_Y, 265*PSDSCALE_X, 32*PSDSCALE_Y)];
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
    
    
    if (indexPath.row < dataSource.count-1)
    {
        CameraTime_lineModel *temp_model = dataSource[indexPath.row+1];
        if ([temp_model.type isEqualToString:@"Stop CDR"])
        {
            line2 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, VIEW_H_Y(tishiImage)+13*PSDSCALE_Y, 1, 10*PSDSCALE_Y)];
            line2.backgroundColor = RGBSTRING(@"333333");
            [self.contentView addSubview:line2];
        }
        
    }
}

@end
