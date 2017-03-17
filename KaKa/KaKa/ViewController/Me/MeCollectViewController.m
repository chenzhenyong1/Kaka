//
//  MeCollectViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeCollectViewController.h"
#import "MeCollectViewControllerTableViewCell.h"
#import "EyeLatestModel.h"
#import "EyeCommentController.h"
#import "MeLocalCollectViewController.h"
#import "EyeSubjectsController.h"
#import "EyeAudioTool.h"

@interface MeCollectViewController ()

@property (nonatomic, strong) EyeSubjectsController *networkCollectVC;
@property (nonatomic, strong) MeLocalCollectViewController *localCollectViewController;
@end

@implementation MeCollectViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    if (self.networkCollectVC.playView.player.currentItem) {
//        
//        [self.networkCollectVC.playView.player.currentItem  addObserver:self.networkCollectVC.playView  forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    [self.view addSubview:self.localCollectViewController.view];
    [self initNavigationSegCtrl];
}



- (void)initNavigationSegCtrl {
    
    UISegmentedControl *segCtrl = [[UISegmentedControl alloc] initWithItems:@[@"本地", @"网络"]];
    segCtrl.bounds = CGRectMake(0, 0, 200, 27);
    segCtrl.tintColor = RGBSTRING(@"b11c22");
    [segCtrl addTarget:self action:@selector(segCtrl_valueChanged:) forControlEvents:UIControlEventValueChanged];
    [segCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    segCtrl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segCtrl;
}

- (MeLocalCollectViewController *)localCollectViewController {
    if (!_localCollectViewController) {
        _localCollectViewController = [[MeLocalCollectViewController alloc] init];
        [self addChildViewController:_localCollectViewController];
    }
    
    return _localCollectViewController;
}

- (EyeSubjectsController *)networkCollectVC {
    if (!_networkCollectVC) {
        _networkCollectVC = [[EyeSubjectsController alloc] init];
        _networkCollectVC.type = EyeSubjectsControllerTypeCollect;
        NSDictionary *userInfo = UserInfo;
        _networkCollectVC.collectedBy = VALUEFORKEY(userInfo, @"userId");
        _networkCollectVC.view.height = self.view.height;
        [self addChildViewController:_networkCollectVC];
        [self.view addSubview:_networkCollectVC.view];
    }
    
    return _networkCollectVC;
}

- (void)segCtrl_valueChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.localCollectViewController.view.hidden = NO;
        self.networkCollectVC.view.hidden = YES;
    } else {
        self.localCollectViewController.view.hidden = YES;
        self.networkCollectVC.view.hidden = NO;
    }
}

@end
