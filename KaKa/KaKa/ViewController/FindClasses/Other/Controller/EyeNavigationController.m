//
//  EyeNavigationController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/21.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeNavigationController.h"

@interface EyeNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation EyeNavigationController


//第一次使用这个类的时候，初始化调用
+(void)initialize
{
    UINavigationBar *navigationBar;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9) {
        navigationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
    } else {
        navigationBar = [UINavigationBar appearanceWhenContainedIn:[self class], nil];
    }
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]
                                            }];
    UIBarButtonItem *barButtonItem;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9) {
        barButtonItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
    } else {
        barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[self class], nil];
    }
    
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                            } forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.interactivePopGestureRecognizer.delegate = self;
    
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    
    [super pushViewController:viewController animated:animated];
}

-(void)back
{
    [self popViewControllerAnimated:YES];
}


#pragma mark -- UIGestureRecognizerDelegate
//取消滑动返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}


@end
