//
//  MeShareViewControllerTableViewCell.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeShareViewControllerTableViewCell.h"

@implementation MeShareViewControllerTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    MeShareViewControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MeShareViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *bg_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 650*PSDSCALE_Y)];
        bg_view.image = GETYCIMAGE(@"me_share_bg");
        [self.contentView addSubview:bg_view];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height -= 20*PSDSCALE_Y;
    
    [super setFrame:frame];
}

@end
