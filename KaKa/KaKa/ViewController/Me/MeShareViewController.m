//
//  MeShareViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeShareViewController.h"
#import "MeShareViewControllerTableViewCell.h"
#import "EyeAudioTool.h"
@interface MeShareViewController ()

@end

@implementation MeShareViewController



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    if (self.playView.player.currentItem) {
//        
//        [self.playView.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.title = @"我的分享";
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.playView.musicName) {
        
        [EyeAudioTool stopMusicWithMusicName:self.playView.musicName];
    }
//    if (self.playView.player.currentItem) {
//        [self.playView.player.currentItem removeObserver:self.playView forKeyPath:@"status"];
//    }
//    [self.playView.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    
}
- (void)back
{
//    if (self.playView.player.currentItem) {
//        [self.playView.player.currentItem removeObserver:self.playView forKeyPath:@"status"];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
