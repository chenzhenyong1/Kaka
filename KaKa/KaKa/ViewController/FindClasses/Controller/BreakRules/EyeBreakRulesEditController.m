//
//  EyeBreakRulesEditController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBreakRulesEditController.h"
#import "EyeBreakRulesController.h"
#import "EyeAudioTool.h"

@interface EyeBreakRulesEditController ()

@end

@implementation EyeBreakRulesEditController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];

   
}



- (void)rightItemClick
{
    ZYLog(@"durationTime = %lf",[self.playView durationTime]);
    
    if ([self.playView durationTime] < 5.0 || [self.playView durationTime] > 30.0) {
        
        [self addActityText:@"只支持5~30的视频分享" deleyTime:1.0];
        return;
    }
    [self.playView pause];
    [self.playView removeFromSuperview];
    
    if (self.playView.musicName) {
        [EyeAudioTool stopMusicWithMusicName:self.playView.musicName];
    }
    
    //跳转到违章举报页面
    EyeBreakRulesController *breakRulesCtl = [[EyeBreakRulesController alloc] init];
    
    breakRulesCtl.videoPath = self.originalVideoPath;
    breakRulesCtl.musicName = self.playView.musicName;
    breakRulesCtl.mute = self.playView.player.volume == 0 ? YES:NO;
    breakRulesCtl.path = self.path;
    
    [self.navigationController pushViewController:breakRulesCtl animated:YES];
}



@end
