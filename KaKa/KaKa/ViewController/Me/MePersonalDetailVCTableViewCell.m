//
//  MePersonalDetailVCTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MePersonalDetailVCTableViewCell.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
@implementation MePersonalDetailVCTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    MePersonalDetailVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MePersonalDetailVCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (void)setItem:(MeParentModel *)item
{
    _item = item;
    [self setupData];
}

- (void)setupData
{
    [self.titleLab removeFromSuperview];
    [self.detailLab removeFromSuperview];
    [self.headView removeFromSuperview];
    self.titleLab = [[UILabel alloc] init];
    if (_item.titleImage.length != 0) {
        
        if ([_item isKindOfClass:[MeArrowItemModel class]]) {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
            
        }
        else
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.titleLab.frame = CGRectMake(32*PSDSCALE_X, (130-35)/2*PSDSCALE_Y, 100*PSDSCALE_X, 35*PSDSCALE_Y);
        self.headView = [[UIImageView alloc] initWithFrame:CGRectMake(588*PSDSCALE_X, 20*PSDSCALE_Y, 90*PSDSCALE_Y, 90*PSDSCALE_Y)];
        self.headView.contentMode = UIViewContentModeScaleAspectFill;
        self.headView.layer.masksToBounds = YES;
        self.headView.layer.cornerRadius = 45*PSDSCALE_Y;
        [self.headView sd_setImageWithURL:[NSURL URLWithString:_item.titleImage] placeholderImage:GETYCIMAGE(@"default_headImage.png") options:SDWebImageDelayPlaceholder];
        [self.contentView addSubview:self.headView];
        
    }
    else
    {
        self.titleLab.frame = CGRectMake(32*PSDSCALE_X, (100-35)/2*PSDSCALE_Y, 160*PSDSCALE_X, 35*PSDSCALE_Y);
        self.detailLab = [[UILabel alloc] init];
        if ([_item isKindOfClass:[MeArrowItemModel class]]) {
            
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
            self.detailLab.frame = CGRectMake(300*PSDSCALE_X, (100-32)/2*PSDSCALE_Y, SCREEN_WIDTH-370*PSDSCALE_X, 32*PSDSCALE_Y);
        }
        else
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            
            if (_item.title.length != 0)
            {
                self.userInteractionEnabled = NO;
                self.detailLab.frame = CGRectMake(100*PSDSCALE_X, (100-32)/2*PSDSCALE_Y, SCREEN_WIDTH-130*PSDSCALE_X, 32*PSDSCALE_Y);
            }
            else
            {
                self.detailLab.frame = CGRectMake(0, (100-37)/2*PSDSCALE_Y, SCREEN_WIDTH, 37*PSDSCALE_Y);
            }
        }
        
        if (_item.title.length == 0)
        {
            self.detailLab.textColor = RGBSTRING(@"333333");
            self.detailLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
            self.detailLab.textAlignment = NSTextAlignmentCenter;
            self.detailLab.text = _item.detail;
            [self.contentView addSubview:self.detailLab];
        }
        else
        {
            self.detailLab.textColor = RGBSTRING(@"777777");
            self.detailLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
            self.detailLab.textAlignment = NSTextAlignmentRight;
            self.detailLab.text = _item.detail;
            [self.contentView addSubview:self.detailLab];
        }
    }
    self.titleLab.textAlignment = NSTextAlignmentLeft;
    self.titleLab.textColor = RGBSTRING(@"333333");
    self.titleLab.font = [UIFont systemFontOfSize:28*FONTCALE_Y];
    [self.contentView addSubview:self.titleLab];
    self.titleLab.text = _item.title;
}

@end
