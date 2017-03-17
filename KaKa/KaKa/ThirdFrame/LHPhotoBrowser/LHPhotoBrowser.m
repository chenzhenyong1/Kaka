//
//  LHPhotoBrowser.m
//  LHPhotoBrowserDemo
//
//  Created by slihe on 16/5/17.
//  Copyright © 2016年 slihe. All rights reserved.
//

#import "LHPhotoBrowser.h"
#import "LHPhotoView.h"
#import "LHPhotoTopBar.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>
#import "AlbumsModel.h"
#import "EyeMyPictureController.h"
#import "FMDBTools.h"
#import "MyTools.h"
#import "AlbumsPhotoViewController.h"
#define kBtnW SCREEN_WIDTH/4
#define photoPadding 10

@interface LHPhotoBrowser ()<LHPhotoViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate>
{
    LHPhotoTopBar *_topBar;
    UIScrollView *_scrollView;
    NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    UIView *bg_view;
    NSInteger select_index;
    NSString *beautify_image_name;
    // 照片美化编辑组件
    TuSDKCPPhotoEditMultipleComponent *_photoEditMultipleComponent;
}

@property(nonatomic, strong)NSArray *imgRectArray;
@property(nonatomic, strong)NSMutableArray *imageProgressArray;
@property(nonatomic, assign)NSInteger curImgIndex;
@property(nonatomic, assign)UIInterfaceOrientationMask supportOrientation;
@property(nonatomic, assign)BOOL isRotating;
@property(nonatomic, assign)BOOL isPush;
@property (nonatomic, assign) BOOL isDel;

@end

@implementation LHPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self addTitle:@"照片预览"];
    self.supportOrientation = UIInterfaceOrientationMaskPortrait;
    // 添加返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton setImage:[UIImage imageNamed:@"me_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem * leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
}

- (void)backButtonAction:(UIButton *)sender{
    
    if (self.isDel) {
        
        self.block();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setImgsArray:(NSMutableArray *)imgsArray
{
    _imgsArray = imgsArray;
    
    if (imgsArray.count > 1) {
        
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
        
    }
    
    NSMutableArray *tmpImgRectArray = [NSMutableArray array];
    
    for(UIView *view in imgsArray){
        [tmpImgRectArray addObject:[NSValue valueWithCGRect:[view convertRect:view.bounds toView:nil]]];
    }
    
    _imgRectArray = [tmpImgRectArray copy];
    
}

- (void)setImgUrlsArray:(NSMutableArray *)imgUrlsArray
{
    _imgUrlsArray = imgUrlsArray;
    
    if (imgUrlsArray.count > 1) {
        
        NSMutableArray *array = [NSMutableArray array];
        
        for(int i = 0;i<imgUrlsArray.count;i++){
            
            [array addObject:[NSNumber numberWithFloat:0.0]];
            
        }
        
        _imageProgressArray = array;
        
    }
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width + photoPadding, self.view.bounds.size.height}];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.hidden = YES;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        
    }
    
    return _scrollView;
}

- (void)show
{
    [self browserWillShow];
    
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    
    for(int i=0;i<_imgsArray.count;i++){
        
        if (i == _tapImgIndex) {
            [self showPhotoViewAtIndex:_tapImgIndex];
        }
    }
    
    _scrollView.contentSize = CGSizeMake(_imgsArray.count * (bvW + photoPadding), bvH);
    _scrollView.contentOffset = CGPointMake(_tapImgIndex * _scrollView.bounds.size.width, 0);
    
    _topBar = [[LHPhotoTopBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    
    if(_imgsArray.count > 1){
        
        [_topBar setPageNum:_tapImgIndex + 1 andAllPageNum:_imgsArray.count];
        
    }
    
    [self.view addSubview:_topBar];
    
}

- (void)showWithPush:(UIViewController *)superVc
{
    if (!superVc) {
        return;
    }
    
    _isPush = YES;
    
    superVc.navigationController.delegate = self;
    [superVc.navigationController pushViewController:self animated:YES];
    
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    
    for(int i=0;i<_imgsArray.count;i++){
        
        if (i == _tapImgIndex) {
            [self showPhotoViewAtIndex:_tapImgIndex];
        }
    }
    
    _scrollView.contentSize = CGSizeMake(_imgsArray.count * (bvW + photoPadding), bvH);
    _scrollView.contentOffset = CGPointMake(_tapImgIndex * _scrollView.bounds.size.width, 0);
    
    
}

- (void)browserWillShow
{
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:NO completion:^{
        
        _curImgIndex = _tapImgIndex;
        
        
        
        
        UIImageView *originImageView = _imgsArray[_tapImgIndex];
        
        UIImage *animationImg = originImageView.image;
        
        CGRect tapImgRect = [_imgRectArray[_tapImgIndex] CGRectValue];
        
        UIView *animationBgView = [[UIView alloc] initWithFrame:tapImgRect];
        animationBgView.clipsToBounds = YES;
        [self.view addSubview:animationBgView];
        
        UIImageView *animationImgView = [[UIImageView alloc] initWithFrame:animationBgView.bounds];
        animationImgView.contentMode = UIViewContentModeScaleAspectFill;
        animationImgView.image = animationImg;
        [animationBgView addSubview:animationImgView];
        
        CGFloat imageX = 0;
        CGFloat imageY = 0;
        CGFloat imageW = animationBgView.bounds.size.width;
        CGFloat imageH = animationBgView.bounds.size.height;
        
        animationImgView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        CGFloat animationW = [UIScreen mainScreen].bounds.size.width;
        CGFloat animationH = [UIScreen mainScreen].bounds.size.height;
        
        CGRect animationRect = CGRectMake(0, 0, animationW, animationH);
        
        CGFloat animationImgY = ([UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width * animationImg.size.height / animationImg.size.width) / 2;
        CGFloat animationImgH = [UIScreen mainScreen].bounds.size.width * animationImg.size.height / animationImg.size.width;
        
        if (animationImgY < 0) {
            animationImgY = 0;
        }
        
//        [UIView animateWithDuration:0.4 animations:^{
        
            animationBgView.frame = animationRect;
            animationImgView.frame = CGRectMake(0, animationImgY, animationW, animationImgH);
            
//        } completion:^(BOOL finished) {
            
            [animationBgView removeFromSuperview];
            _supportOrientation = UIInterfaceOrientationMaskAllButUpsideDown;
            _scrollView.hidden = NO;
            [UIViewController attemptRotationToDeviceOrientation];
            
//        }];
        
    }];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutPhotoBrowser];
}

- (void)layoutPhotoBrowser
{
    CGPoint point = _scrollView.contentOffset;
    CGFloat offsetX = point.x;
    NSInteger curIndex = offsetX / _scrollView.bounds.size.width;
    
    _scrollView.frame = (CGRect){0, 0, self.view.bounds.size.width + 10, self.view.bounds.size.height};
    
    CGFloat bvW = _scrollView.bounds.size.width - 10;
    CGFloat bvH = _scrollView.bounds.size.height;
    
    for (LHPhotoView *bv in _visiblePhotoViews) {
        
        bv.frame = (CGRect){(bv.tag - 1) * (bvW + 10), 0, bvW, bvH};
        [bv resetSize];
        
    }
    
    _scrollView.contentSize = CGSizeMake(_imgsArray.count * (bvW + 10), bvH);
    _scrollView.contentOffset = CGPointMake(curIndex * (bvW + 10), 0);
    _topBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    
    
    if ([self.superVc isKindOfClass:[AlbumsPhotoViewController class]])
    {
        
        if (!bg_view)
        {
            bg_view = [[UIView alloc] init];
            //    if (self.isPush)
            //    {
            //        bg_view.frame = CGRectMake(0, VIEW_H(self.view)-100*PSDSCALE_Y, SCREEN_WIDTH, 100*PSDSCALE_Y);
            //    }
            //    else
            //    {
            bg_view.frame = CGRectMake(0, VIEW_H(self.view)-100*PSDSCALE_Y, SCREEN_WIDTH, 100*PSDSCALE_Y);
            //    }
            
            bg_view.backgroundColor = RGBSTRING(@"323232");
            [self.view addSubview:bg_view];
            
            NSArray *images = @[@"albums_meihua",@"albums_shoucang",@"albums_fenxiang",@"albums_shanchu"];
            NSArray *titles = @[@"美化",@"收藏",@"分享",@"删除"];
            for (int i = 0; i < images.count; i ++) {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kBtnW*i, 0, kBtnW, 100*PSDSCALE_Y)];
                btn.tag = 1+i;
                [btn setImageEdgeInsets:UIEdgeInsetsMake(22*PSDSCALE_Y, 77*PSDSCALE_X, 44*PSDSCALE_Y, 77*PSDSCALE_X)];
                [btn setImage:GETYCIMAGE(images[i]) forState:UIControlStateNormal];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [bg_view addSubview:btn];
                UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 68*PSDSCALE_Y, kBtnW, 27*PSDSCALE_Y)];
                lab.text = titles[i];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = [UIColor whiteColor];
                lab.font = [UIFont systemFontOfSize:20*FONTCALE_Y];
                [btn addSubview:lab];
                
                [btn addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
    }
    
    
 
    
}

- (void)btn_click:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:
        {
            TuSDKResult *result = [[TuSDKResult alloc] init];
            if ([_imgsArray[select_index] isKindOfClass:[UIImageView class]])
            {
                result.image = [(UIImageView *)_imgsArray[select_index] image];
            }
            else
            {
                AlbumsModel *model = _imgsArray[select_index];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
                result.image = image;
            }
            
            [self openEditMultipleWithController:self result:result];
            
        }
            break;
        case 2:
        {
            
            AlbumsModel *model = [self.albumsPhotoSource objectAtIndex:select_index];
            
            if ([FMDBTools selectContactMember:model.imageName userName:UserName])
            {
                [self addActityText:@"不能重复收藏" deleyTime:1];
                return;
            }
            
            if ([FMDBTools saveContactsWithImageUrl:model.imageName type:kCollectTypePhoto])
            {
                [self addActityText:@"收藏成功" deleyTime:1];
                [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
            }
            else
            {
                [self addActityText:@"收藏失败" deleyTime:1];
            }
            
            
        }
            break;
        case 3:
        {
            AlbumsModel *model = [_albumsPhotoSource objectAtIndex:select_index];
            
            EyeMyPictureController *ctl = [EyeMyPictureController new];
            
            ctl.picArr = @[model];
            
            [self.navigationController pushViewController:ctl animated:YES];
            
            ZYLog(@"点击分享");
        }
            break;
        case 4:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否删除该图片" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            if (self.albumsPhotoSource.count > 0)
            {
                
                AlbumsModel *model = [_albumsPhotoSource objectAtIndex:select_index];
                
                //删除数据库中的
                if ([FMDBTools selectContactMember:model.imageName userName:UserName])
                {
                    [FMDBTools deleteCollectWithimageUrl:model.imageName];
                }
                
                //删除本地文件夹
                if ([self deleteDirInCache:model.imageName]) {
                    MMLog(@"删除成功");
                    _isDel = YES;
                }
                else
                {
                    MMLog(@"删除失败");
                }
                [_albumsPhotoSource removeObjectAtIndex:select_index];
                [_imgsArray removeObjectAtIndex:select_index];
                
                if (_albumsPhotoSource.count)
                {
                    
                    if (select_index == _albumsPhotoSource.count)
                    {
                        select_index = _albumsPhotoSource.count-1;
                    }
                    
                    for(int i=0;i<_imgsArray.count;i++){
                        
                        if (i == select_index) {
                            [self showPhotoViewAtIndex:select_index];
                        }
                    }
                    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
                    CGFloat bvH = self.scrollView.bounds.size.height;
                    _scrollView.contentSize = CGSizeMake(_imgsArray.count * (bvW + photoPadding), bvH);
                    _scrollView.contentOffset = CGPointMake(_tapImgIndex * _scrollView.bounds.size.width, 0);
                    
                }
                else
                {
                    self.block();
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                
            }
        }
            break;
            
        default:
            break;
    }
}

//删除文件

-(BOOL)deleteDirInCache:(NSString *)dirName
{
    BOOL isDeleted = NO;
    //不存在就下载
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirName])
    {
        isDeleted = [[NSFileManager defaultManager] removeItemAtPath:dirName error:nil];
        return isDeleted;
    }
    return isDeleted;
}

/**
 *  开启裁切+滤镜组件
 *
 *  @param controller 来源控制器
 *  @param result     处理结果
 */
- (void)openEditMultipleWithController:(UIViewController *)controller
                                result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    __weak typeof(self) weakSelf = self;
    _photoEditMultipleComponent =
    [TuSDKGeeV1 photoEditMultipleWithController:controller
                                  callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller)
     {
         // 获取图片失败
         if (error) {
             lsqLError(@"editMultiple error: %@", error.userInfo);
             return;
         }
         [result logInfo];
         NSLog(@"美化成功!");
         [weakSelf openEditorWithImage:result.image];
     }];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionSticker];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionSmudge];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionSkin];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionAdjust];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionWipeFilter];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionSharpness];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionVignette];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionAperture];
    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionHolyLight];
    _photoEditMultipleComponent.options.editFilterOptions.enableOnlineFilter = NO;
    _photoEditMultipleComponent.options.editFilterOptions.enableFilterHistory = NO;
    _photoEditMultipleComponent.options.editMultipleOptions.saveToAlbum = NO;
    _photoEditMultipleComponent.options.editMultipleOptions.isAutoRemoveTemp = YES;
    // 设置图片
    _photoEditMultipleComponent.inputImage = result.image;
    _photoEditMultipleComponent.inputTempFilePath = result.imagePath;
    _photoEditMultipleComponent.inputAsset = result.imageAsset;
    // 是否在组件执行完成后自动关闭组件 (默认:NO)
    _photoEditMultipleComponent.autoDismissWhenCompelted = YES;
    // 当上一个页面是NavigationController时,是否通过 pushViewController 方式打开编辑器视图 (默认：NO，默认以 presentViewController 方式打开）
    // SDK 内部组件采用了一致的界面设计，会通过 push 方式打开视图。如果用户开启了该选项，在调用时可能会遇到布局不兼容问题，请谨慎处理。
    _photoEditMultipleComponent.autoPushViewController = NO;
    [_photoEditMultipleComponent showComponent];
    
}

-(void)openEditorWithImage:(UIImage *)image
{
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:UserName];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:_mac_adr];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Photo"];
    NSString *file_Path = [documentsDirectoryURL absoluteString];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        NSLog(@"文件夹已存在");
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *filePath = [Photo_Path(_mac_adr) stringByAppendingPathComponent:[NSString stringWithFormat:@"Retouching%@.png",[MyTools getCurrentStandarTimeWithMinute1]]];
    
    beautify_image_name = filePath;
    //不存在就下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:file_Path])
    {
        MMLog(@"%@",filePath);
        MMLog(@"不存在");
        if ([data writeToFile:filePath atomically:NO])
        {
            self.block();
        }
        
        //        AlbumsModel *model = [[AlbumsModel alloc] init];
        
        
        [_imgsArray removeAllObjects];
        
        
        NSArray *pathArr =[MyTools getAllDataWithPath:Photo_Path(nil) mac_adr:nil];
        for (int i = 0; i < pathArr.count; i ++)
        {
            
            AlbumsModel *model = [[AlbumsModel alloc] init];
            model.imageName = [pathArr objectAtIndex:i];
            model.isSelect = NO;
            model.isShow = NO;
            [_imgsArray addObject:model];
        }
        [self newArray:_imgsArray];
        
    }
}

//遍历数组，将文件按照时间重新排序
- (void)newArray:(NSMutableArray *)arr
{
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(AlbumsModel *obj1, AlbumsModel *obj2) {
        
        //这里的代码可以参照上面compare:默认的排序方法，也可以把自定义的方法写在这里，给对象排序
        //NSComparisonResult result = [obj1 compareFile:obj2];
        NSComparisonResult result = [[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj2.imageName] longLongValue]] compare:[NSNumber numberWithLongLong:[[self getTimeWithFilePath:obj1.imageName] longLongValue]]];
        return result;
    }];
    [_imgsArray removeAllObjects];
    [_albumsPhotoSource removeAllObjects];
    [_imgsArray addObjectsFromArray:sortedArray];
    [self.albumsPhotoSource addObjectsFromArray:sortedArray];
    
    if (beautify_image_name.length != 0)
    {
        for (int i = 0; i < _imgsArray.count; i ++)
        {
            AlbumsModel *model = _imgsArray[i];
            if ([beautify_image_name isEqualToString:model.imageName])
            {
                select_index = i;
                break;
            }
        }
    }
    for(int i=0;i<_imgsArray.count;i++){
        
        if (i == select_index) {
            [self showPhotoViewAtIndex:select_index];
        }
    }
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    _scrollView.contentSize = CGSizeMake(_imgsArray.count * (bvW + photoPadding), bvH);
    _scrollView.contentOffset = CGPointMake(select_index * _scrollView.bounds.size.width, 0);
    
}


//获取时间
- (NSString *)getTimeWithFilePath:(NSString *)filePath
{
    
    NSString *file_path = [filePath componentsSeparatedByString:@"/"].lastObject;
    file_path = [file_path componentsSeparatedByString:@"."].firstObject;
    if ([file_path hasPrefix:@"G"])
    {
        file_path = [file_path substringFromIndex:1];
    }
    return file_path;
    
}

















- (void)showPhotoViewAtIndex:(NSInteger)index
{
    select_index = index;
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    
    LHPhotoView *bv = [self dequeueReusablePhotoView];
    if (!bv) {
        bv = [[LHPhotoView alloc] initWithFrame:(CGRect){index * (_scrollView.bounds.size.width), 0, bvW, bvH}];
    } else {
        bv.frame = (CGRect){index * (_scrollView.bounds.size.width), 0, bvW, bvH};
    }
    
    [_visiblePhotoViews addObject:bv];
    
    bv.tag = index + 1;
    bv.photoViewDelegate = self;
    [_scrollView addSubview:bv];
    
    UIImageView *originImageView;
    if ([_imgsArray[index] isKindOfClass:[UIImageView class]]) {
        
        originImageView = _imgsArray[index];
        bv.itemImage = originImageView.image;
    }
    else
    {
        AlbumsModel *model = _imgsArray[index];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.imageName];
        bv.itemImage = image;
    }
    bv.itemImageUrl = _imgUrlsArray[index];

    
}

- (void)showPhotos
{
    
    if (_imgsArray.count == 1) {
        return;
    }
    
    if (_isRotating) {
        return;
    }
    
    CGRect visibleBounds = _scrollView.bounds;
    NSInteger firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+photoPadding) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-photoPadding-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _imgsArray.count) firstIndex = _imgsArray.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _imgsArray.count) lastIndex = _imgsArray.count - 1;
    
    NSInteger photoViewIndex;
    for (LHPhotoView *bv in _visiblePhotoViews) {
        photoViewIndex = bv.tag - 1;
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:bv];
            [bv removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
    
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (LHPhotoView *bv in _visiblePhotoViews) {
        if (bv.tag - 1 == index) {
            return YES;
        }
    }
    return  NO;
}

- (LHPhotoView *)dequeueReusablePhotoView
{
    LHPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    
    return photoView;
}

#pragma -mark navigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    _supportOrientation = UIInterfaceOrientationMaskAllButUpsideDown;
    _scrollView.hidden = NO;
    [UIViewController attemptRotationToDeviceOrientation];
    
}

#pragma -mark photoViewDelegate

- (void)photoViewSingleTap:(NSInteger)index
{
    if (_isPush) {
        return;
    }
    
    NSInteger curIndex = index - 1;
    
    _scrollView.hidden = YES;
    
    UIImageView *originImageView = _imgsArray[curIndex];
    
    UIImage *animationImg = originImageView.image;
    
    UIView *animationBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    animationBgView.clipsToBounds = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:animationBgView];
    
    CGFloat animationImgY = (self.view.bounds.size.height - self.view.bounds.size.width * animationImg.size.height / animationImg.size.width) / 2;
    CGFloat animationImgH = self.view.bounds.size.width * animationImg.size.height / animationImg.size.width;
    
    if (animationImgY < 0) {
        animationImgY = 0;
    }
    
    UIImageView *animationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, animationImgY, self.view.bounds.size.width, animationImgH)];
    animationImgView.contentMode = UIViewContentModeScaleAspectFill;
    animationImgView.image = animationImg;
    [animationBgView addSubview:animationImgView];
    
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = [_imgRectArray[curIndex] CGRectValue].size.width;
    CGFloat imageH = [_imgRectArray[curIndex] CGRectValue].size.height;
    
//    [UIView animateWithDuration:0.4 animations:^{
    
        animationBgView.frame = [_imgRectArray[curIndex] CGRectValue];
        animationImgView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
//    } completion:^(BOOL finished) {
    
        [animationBgView removeFromSuperview];
        
//    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)photoIsShowingPhotoViewAtIndex:(NSUInteger)index
{
    return [self isShowingPhotoViewAtIndex:index];
}

- (void)updatePhotoProgress:(CGFloat)progress andIndex:(NSInteger)index
{
    _imageProgressArray[index] = [NSNumber numberWithFloat:progress];
}

- (void)updatePage
{
    CGRect visibleBounds = _scrollView.bounds;
    CGFloat MidBoundary = CGRectGetMinX(visibleBounds) + (_scrollView.bounds.size.width - photoPadding) * .5;
    int leftPage = MidBoundary / CGRectGetWidth(visibleBounds);
    CGFloat rightPage = MidBoundary - leftPage * CGRectGetWidth(visibleBounds);
    
    if (rightPage > CGRectGetWidth(visibleBounds) - photoPadding / 2) {
        
        [_topBar setPageNum:(leftPage + 2) andAllPageNum:_imgsArray.count];
        if (_isPush) {
//            self.title = [NSString stringWithFormat:@"%d/%d", (leftPage + 2), _imgsArray.count];
        }
        
    } else {
        
        [_topBar setPageNum:(leftPage + 1) andAllPageNum:_imgsArray.count];
        if (_isPush) {
//            self.title = [NSString stringWithFormat:@"%d/%d", (leftPage + 1), _imgsArray.count];
        }
        
    }
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showPhotos];
    [self updatePage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x/VIEW_W(_scrollView);
    select_index = page;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    _isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    _isRotating = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return _hideStatusBar;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return _supportOrientation;
}

@end
