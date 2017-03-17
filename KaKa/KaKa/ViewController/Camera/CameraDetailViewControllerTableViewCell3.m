//
//  CameraDetailViewControllerTableViewCell3.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraDetailViewControllerTableViewCell3.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CameraTime_lineModel.h"

@implementation CameraDetailViewControllerTableViewCell3

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell3";
    CameraDetailViewControllerTableViewCell3 *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (cell == nil) {
        cell = [[CameraDetailViewControllerTableViewCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, 0, 1, 55*PSDSCALE_Y)];
        line1.backgroundColor = RGBSTRING(@"333333");
        [self.contentView addSubview:line1];
        
        UIImageView *tishiImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50*PSDSCALE_Y)/2, VIEW_H_Y(line1)+17*PSDSCALE_Y, 50*PSDSCALE_X, 50*PSDSCALE_Y)];
        tishiImage.layer.masksToBounds = YES;
        tishiImage.layer.cornerRadius = 25*PSDSCALE_X;
        tishiImage.image = GETYCIMAGE(@"camera_C");
        [self.contentView addSubview:tishiImage];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, VIEW_H_Y(tishiImage)+23*PSDSCALE_Y, 1, 75*PSDSCALE_Y)];
        line2.backgroundColor = RGBSTRING(@"333333");
        [self.contentView addSubview:line2];
        
        self.detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, 19*PSDSCALE_Y, 230*PSDSCALE_X, 160*PSDSCALE_Y)];
        self.detailImage.layer.masksToBounds = YES;
        self.detailImage.layer.cornerRadius = 5;
        self.detailImage.image = GETYCIMAGE(@"camera_timeLine_defaultImage.png");
        self.detailImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self.detailImage addGestureRecognizer:tap];
        [self.contentView addSubview:self.detailImage];
        
        self.time_lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-300*PSDSCALE_X, 91*PSDSCALE_Y, 265*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.time_lab.text = @"00:00~07:21";
        self.time_lab.textAlignment = NSTextAlignmentRight;
        self.time_lab.textColor = RGBSTRING(@"666666");
        self.time_lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        [self.contentView addSubview:self.time_lab];
        
    }
    return self;
}

- (void)refreshData:(CameraTime_lineModel *)model
{
//    [self.detailImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,model.media]] placeholderImage:GETYCIMAGE(@"camera_detailImage")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *imagePath = [TimeLine_Photo_Path(model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", model.media]];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.detailImage.image = image;
            });
        } else {
            if (model.media) {
                [self.detailImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", [SettingConfig shareInstance].ip_url,model.media]] placeholderImage:GETYCIMAGE(@"camera_timeLine_defaultImage.png")];
            }
        }
        
    });
    
    NSString *time = [model.time substringWithRange:NSMakeRange(8, 4)];
    NSMutableString *time1 = [[NSMutableString alloc] initWithString:time];
    [time1 insertString:@":" atIndex:2];
    self.time_lab.text = [NSString stringWithFormat:@"%@",time1];
}

- (void)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(showBIgImageWithCell:)]) {
        [_delegate showBIgImageWithCell:self];
    }
}

@end
