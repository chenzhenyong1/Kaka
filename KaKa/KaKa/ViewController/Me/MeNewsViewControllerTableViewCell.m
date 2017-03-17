//
//  MeNewsViewControllerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeNewsViewControllerTableViewCell.h"

@implementation MeNewsViewControllerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    MeNewsViewControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MeNewsViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.pointView = [[UIView alloc] initWithFrame:CGRectMake(17*PSDSCALE_X, 60*PSDSCALE_Y, 25*PSDSCALE_X, 25*PSDSCALE_Y)];
        self.pointView.backgroundColor = RGBSTRING(@"007aff");
        self.pointView.layer.masksToBounds = YES;
        self.pointView.layer.cornerRadius = VIEW_H(self.pointView)/2;
        [self.contentView addSubview:self.pointView];
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(69*PSDSCALE_X, 20*PSDSCALE_Y, 160*PSDSCALE_X, 37*PSDSCALE_Y)];
        self.titleLab.font = [UIFont boldSystemFontOfSize:30*FONTCALE_Y];
        self.titleLab.text = @"系统消息";
        self.titleLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLab];
        
        self.timelab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-171*PSDSCALE_X, 24*PSDSCALE_Y, 171*PSDSCALE_X, 32*PSDSCALE_Y)];
        self.timelab.textAlignment = NSTextAlignmentLeft;
        self.timelab.text = @"16/07/25";
        self.timelab.font = [UIFont systemFontOfSize:25*PSDSCALE_Y];
        self.timelab.textColor = RGBSTRING(@"777777");
        [self.contentView addSubview:self.timelab];
        
        self.detaillab = [[UILabel alloc] initWithFrame:CGRectMake(69*PSDSCALE_X, VIEW_H_Y(self.timelab)+12*PSDSCALE_Y, 632*PSDSCALE_X, 77*PSDSCALE_Y)];
        self.detaillab.font = [UIFont systemFontOfSize:30*PSDSCALE_Y];
        self.detaillab.numberOfLines = 0;
        self.detaillab.textColor = RGBSTRING(@"777777");
        self.detaillab.textAlignment = NSTextAlignmentLeft;
        self.detaillab.text = @"深圳市清祥路1号宝能科技园->深圳市麻雀岭秀软科技";
        [self.contentView addSubview:self.detaillab];
    }
    return self;
}

- (void)setMsgModel:(MessageModel *)msgModel {
    
    _msgModel = msgModel;
    
    self.pointView.hidden = _msgModel.readed;
    self.titleLab.text = _msgModel.title;
    self.detaillab.text = _msgModel.content;
    
    self.timelab.text = TIMESTAMP_TO_TIMESTRING([_msgModel.createTime doubleValue], @"yyyy/MM/dd");
}

@end
