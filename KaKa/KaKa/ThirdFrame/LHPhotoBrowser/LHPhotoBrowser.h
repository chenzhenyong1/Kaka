//
//  LHPhotoBrowser.h
//  LHPhotoBrowserDemo
//
//  Created by slihe on 16/5/17.
//  Copyright © 2016年 slihe. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^RefreshBlock)();

@interface LHPhotoBrowser : BaseViewController

@property(nonatomic, strong)NSMutableArray *imgsArray;

@property(nonatomic, strong)NSMutableArray *imgUrlsArray;

@property(nonatomic, assign)NSInteger tapImgIndex;

@property(nonatomic, weak)UIViewController *superVc;
@property (nonatomic, strong) NSMutableArray *albumsPhotoSource;

@property(nonatomic, assign)BOOL hideStatusBar;
@property (nonatomic, strong) NSString *mac_adr;

@property (nonatomic, strong) RefreshBlock block;

- (void)show;

- (void)showWithPush:(UIViewController *)superVc;
@end
