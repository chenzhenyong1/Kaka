//
//  EyeTrackCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeTrackCell.h"


@interface EyeTrackCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;


@end


@implementation EyeTrackCell


+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"EyeTrackCell";
    EyeTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil]lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverImageView.image = [UIImage imageNamed:@"track"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
