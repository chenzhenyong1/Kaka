//
//  MeViewControllerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeViewControllerTableViewCell.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
@implementation MeViewControllerTableViewCell

- (void)setItem:(MeParentModel *)item
{
    _item = item;
    [self setupData];
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    MeViewControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MeViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}



- (void)setupData
{
    
    if (![_item isKindOfClass:[MeArrowItemModel class]])
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.subLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 39*PSDSCALE_Y, SCREEN_WIDTH-31*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.subLab.text = _item.detail;
        self.subLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
        self.subLab.textAlignment = NSTextAlignmentRight;
        self.subLab.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:self.subLab];
        
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    
    self.titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(30*PSDSCALE_X, 42*PSDSCALE_Y, 25*PSDSCALE_X, 25*PSDSCALE_Y)];
    self.titleImage.image = GETYCIMAGE(_item.titleImage);
    self.titleImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.titleImage];
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(self.titleImage)+34*PSDSCALE_X, (100-37)/2*PSDSCALE_Y, 150*PSDSCALE_X, 37*PSDSCALE_Y)];
    self.titleLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    self.titleLab.textAlignment = NSTextAlignmentLeft;
    self.titleLab.textColor = RGBSTRING(@"333333");
    self.titleLab.text = _item.title;
    [self.contentView addSubview:self.titleLab];
}

@end
