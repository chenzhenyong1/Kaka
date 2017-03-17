//
//  CameraCarBrandTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraCarBrandTableViewCell.h"
#import "CarBrandModel.h"
@implementation CameraCarBrandTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    CameraCarBrandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[CameraCarBrandTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.car_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15*PSDSCALE_X, 10*PSDSCALE_X, 80*PSDSCALE_X, 80*PSDSCALE_Y)];
        self.car_imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.car_imageView];
        
        self.car_nameLab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(self.car_imageView)+20*PSDSCALE_X, 33*PSDSCALE_Y, 200*PSDSCALE_X, 34*PSDSCALE_Y)];
        self.car_nameLab.textAlignment = NSTextAlignmentLeft;
        self.car_nameLab.textColor = RGBSTRING(@"666666");
        self.car_nameLab.font = [UIFont systemFontOfSize:27*FONTCALE_Y];
        [self.contentView addSubview:self.car_nameLab];
    }
    return self;
}

- (void)refreshData:(CarBrandModel *)model
{
    self.car_imageView.image = GETYCIMAGE(model.car_image_name);
    self.car_nameLab.text = model.car_name;
}

@end
