//
//  MeNewsDetailViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/25.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeNewsDetailViewController.h"

@interface MeNewsDetailViewController ()

@end

@implementation MeNewsDetailViewController
{
    UILabel *timeLab;
    UILabel *detailLab;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:self.msgModel.title wordNun:(int)[self.msgModel.title length]];
    self.view.backgroundColor = RGBSTRING(@"ffffff");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    timeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-144*PSDSCALE_X, 26*PSDSCALE_Y, 144*PSDSCALE_X, 32*PSDSCALE_Y)];
    timeLab.text = TIMESTAMP_TO_TIMESTRING([_msgModel.createTime doubleValue], @"yyyy/MM/dd");;
    timeLab.textAlignment = NSTextAlignmentLeft;
    timeLab.textColor = RGBSTRING(@"777777");
    timeLab.font = [UIFont systemFontOfSize:25*PSDSCALE_Y];
    [self.view addSubview:timeLab];
    
    NSString *str = _msgModel.content;
    CGSize size = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-62*PSDSCALE_X, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30*FONTCALE_Y]} context:nil].size;
    
    detailLab = [[UILabel alloc] initWithFrame:CGRectMake(31*PSDSCALE_X, VIEW_H_Y(timeLab)+49*PSDSCALE_Y, SCREEN_WIDTH-62*PSDSCALE_X, size.height+7*PSDSCALE_Y)];
    detailLab.font = [UIFont systemFontOfSize:30*FONTCALE_Y];
    detailLab.text =str;
    detailLab.numberOfLines = 0;
    detailLab.textColor = RGBSTRING(@"333333");
    [self.view addSubview:detailLab];
    
}



@end
