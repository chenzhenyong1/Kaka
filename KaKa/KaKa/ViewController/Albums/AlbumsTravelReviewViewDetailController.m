//
//  AlbumsTravelReviewViewDetailController.m
//  KaKa
//
//  Created by Change_pan on 16/8/8.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "AlbumsTravelReviewViewDetailController.h"
#import "AlbumsTravelDetailModel.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>
@interface AlbumsTravelReviewViewDetailController ()<UITextViewDelegate>
{
    // 照片美化编辑组件
    TuSDKCPPhotoEditMultipleComponent *_photoEditMultipleComponent;
}
// 选择下标
@property (nonatomic, assign) NSInteger select_index;
@end

@implementation AlbumsTravelReviewViewDetailController
{
    UIImageView *detailImage;
    UITextView *opinionTextView;
    UILabel *tishiLab;
    UIScrollView *_scrollView;
    UIButton *_old_btn;
    UIButton *_share_btn;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"我的游记" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:GETYCIMAGE(@"albums_meihua") wordNum:2 actionBlock:^(UIButton *sender) {
        
        if (weakSelf.select_index < _model.dataSource.count) {
            AlbumsTravelDetailModel *selectDetailModel = weakSelf.model.dataSource[weakSelf.select_index];
            NSString *path = [Travel_Path(weakSelf.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)selectDetailModel.travelId]];
            NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", selectDetailModel.fileName]];
            
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:imageData];
            TuSDKResult *result = [[TuSDKResult alloc] init];
            result.image = image;
            
            [weakSelf openEditMultipleWithController:weakSelf result:result];
        }
    }];
    
    // 图片美化
    
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    [self initUI];
}

- (void)initUI
{
    detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 422*PSDSCALE_Y)];
    detailImage.contentMode = UIViewContentModeScaleAspectFill;
    detailImage.clipsToBounds = YES;
    [self.view addSubview:detailImage];
    
    AlbumsTravelDetailModel *firstDetailModel = [_model.dataSource firstObject];
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)firstDetailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", firstDetailModel.fileName]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    detailImage.image = image;
    
    self.select_index = 0;

    
    opinionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, VIEW_H_Y(detailImage), SCREEN_WIDTH, 275*PSDSCALE_Y)];
    opinionTextView.font = [UIFont systemFontOfSize:30*PSDSCALE_Y];
    opinionTextView.textAlignment = NSTextAlignmentLeft;
    opinionTextView.editable =YES;
    opinionTextView.delegate = self;
    opinionTextView.keyboardType = UIKeyboardAppearanceDefault;
    opinionTextView.returnKeyType = UIReturnKeyDone;
    
    tishiLab = [[UILabel alloc] init];
    tishiLab.frame = CGRectMake(25*PSDSCALE_X, 15*PSDSCALE_Y, 800*PSDSCALE_X, 35*PSDSCALE_Y);
    tishiLab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    tishiLab.text = @"写上您的心情吧....";
    tishiLab.textColor = RGBSTRING(@"9a9a9a");
    [opinionTextView addSubview:tishiLab];
    [self.view addSubview:opinionTextView];
    if (firstDetailModel.mood.length) {
        opinionTextView.text = firstDetailModel.mood;
        tishiLab.text = @"";
    }
    
    UIButton *share_btn = [[UIButton alloc] initWithFrame:CGRectMake(27*PSDSCALE_X, VIEW_H_Y(opinionTextView)+18*PSDSCALE_Y, 65*PSDSCALE_X, 47*PSDSCALE_Y)];
    [share_btn setImage:GETYCIMAGE(@"albums_my_youji_share_nor") forState:UIControlStateNormal];
    [share_btn setImage:GETYCIMAGE(@"albums_my_youji_share_sel") forState:UIControlStateSelected];
    [share_btn addTarget:self action:@selector(share_btn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share_btn];
    _share_btn = share_btn;
    if (!firstDetailModel.shared) {
        share_btn.selected = YES;
    }
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(share_btn)+29*PSDSCALE_X, VIEW_H_Y(opinionTextView)+30*PSDSCALE_Y, 200*PSDSCALE_X, 32*PSDSCALE_Y)];
    lab.text = @"不分享此照片";
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = RGBSTRING(@"cccccc");
    lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:lab];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT-148*PSDSCALE_Y, SCREEN_WIDTH, 148*PSDSCALE_Y)];
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.showsHorizontalScrollIndicator = NO;

    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < _model.dataSource.count; i ++)
    {
        AlbumsTravelDetailModel *model = [_model.dataSource objectAtIndex:i];
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i+1;
        if (i==0)
        {
            btn.frame = CGRectMake(0, 24*PSDSCALE_Y, 186*PSDSCALE_X, 106*PSDSCALE_Y);
            btn.userInteractionEnabled = NO;
            _old_btn = btn;
        }
        else
        {
            btn.frame = CGRectMake(157*PSDSCALE_X*i+31*PSDSCALE_X, 33*PSDSCALE_Y, 155*PSDSCALE_X, 88*PSDSCALE_Y);
        }
        
        
        NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)model.travelId]];
        NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", model.fileName]];
        
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.imageView.clipsToBounds = YES;
        [btn setImage:image forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:btn];
        
        UIImageView *unShare_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44*PSDSCALE_X, 28*PSDSCALE_Y)];
        unShare_imageView.image = GETYCIMAGE(@"albums_my_youji_share_sel");
        unShare_imageView.contentMode = UIViewContentModeScaleAspectFit;
        unShare_imageView.center = CGPointMake(VIEW_W(btn)/2, VIEW_H(btn)/2);
        unShare_imageView.tag = 100;
        [btn addSubview:unShare_imageView];
        unShare_imageView.hidden = model.shared;
    }
    
    _scrollView.contentSize = CGSizeMake(_model.dataSource.count*157*PSDSCALE_X+33*PSDSCALE_Y, 0);
    
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
//         weakSelf.isPush = YES;
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
    detailImage.image = image;
    [_old_btn setImage:image forState:UIControlStateNormal];
    //保存到游记相册     Save to album
    
    AlbumsTravelDetailModel *selectDetailModel = [_model.dataSource objectAtIndex:_old_btn.tag - 1];
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)selectDetailModel.travelId]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //设置一个图片的存储路径
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", selectDetailModel.fileName]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    BOOL isWriteOK = [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
    if (isWriteOK) {
        [NotificationCenter postNotificationName:@"TravelPrettifiedNoti" object:nil];
    }
}









- (void)share_btn_click:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
    
    UIView *unShare_imageView = [_old_btn viewWithTag:100];
    unShare_imageView.hidden = !btn.selected;
    
    AlbumsTravelDetailModel *detailModel = [_model.dataSource objectAtIndex:_old_btn.tag - 1];
    detailModel.shared = !btn.selected;
    
    // 保存到数据库
    [CacheTool updateTravelDetailWithDetailModel:detailModel];
}


- (void)btn_click:(UIButton *)btn
{
    
    if (btn.tag > _old_btn.tag)
    {
        btn.userInteractionEnabled = NO;
        _old_btn.userInteractionEnabled = YES;
        CGRect frame = btn.frame;
        
        frame = _old_btn.frame;
        frame.size.width = 155*PSDSCALE_X;
        frame.size.height = 88*PSDSCALE_Y;
        frame.origin.y =33*PSDSCALE_Y;
        frame.origin.x = 157*PSDSCALE_X * (_old_btn.tag -1);
        _old_btn.frame = frame;
        
        UIView *old_unShare_imageView = [_old_btn viewWithTag:100];
        old_unShare_imageView.center = CGPointMake(VIEW_W(btn)/2, VIEW_H(btn)/2);
        
        frame.size.width = 186*PSDSCALE_X;
        frame.size.height = 106*PSDSCALE_Y;
        frame.origin.y =24*PSDSCALE_Y;
        frame.origin.x =157*PSDSCALE_X * (btn.tag -1);
        btn.frame = frame;
        
        
        
        
        if (btn.tag - _old_btn.tag == 1)
        {
            for (NSInteger i = btn.tag; i <_model.dataSource.count; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                frame.origin.x = 157*PSDSCALE_X*i+31*PSDSCALE_X;
                temp_btn.frame =frame;
            }
        }
        else
        {
            for (NSInteger i = _old_btn.tag; i < btn.tag; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                
                frame.origin.x = 157*PSDSCALE_X*i;
                temp_btn.frame =frame;
            }
            
            for (NSInteger i = btn.tag; i <_model.dataSource.count; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                frame.origin.x = 157*PSDSCALE_X*i+31*PSDSCALE_X;
                temp_btn.frame =frame;
            }
        }
        _old_btn = btn;
        
    }
    else
    {
        _old_btn.userInteractionEnabled = YES;
        btn.userInteractionEnabled = NO;
        CGRect frame = _old_btn.frame;
        frame.origin.x +=31*PSDSCALE_X;
        frame.size.width = 155*PSDSCALE_X;
        frame.size.height = 88*PSDSCALE_Y;
        frame.origin.y =33*PSDSCALE_Y;
        _old_btn.frame = frame;
        UIView *old_unShare_imageView = [_old_btn viewWithTag:100];
        old_unShare_imageView.center = CGPointMake(VIEW_W(btn)/2, VIEW_H(btn)/2);
        
        if (_old_btn.tag -btn.tag == 1) {
            
            for (NSInteger i =_old_btn.tag; i <_model.dataSource.count; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                frame.origin.x = 157*PSDSCALE_X*i+31*PSDSCALE_X;
                temp_btn.frame =frame;
            }
        }
        else
        {
            for (NSInteger i =btn.tag; i <_old_btn.tag; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                frame.origin.x = 157*PSDSCALE_X*i+31*PSDSCALE_X;
                temp_btn.frame =frame;
            }
            
            for (NSInteger i =_old_btn.tag; i <_model.dataSource.count; i ++)
            {
                UIButton *temp_btn = (UIButton *)_scrollView.subviews[i];
                frame = temp_btn.frame;
                frame.origin.x = 157*PSDSCALE_X*i+31*PSDSCALE_X;
                temp_btn.frame =frame;
            }
        }
        
        
        
        frame = btn.frame;
        frame.size.width = 186*PSDSCALE_X;
        frame.size.height = 106*PSDSCALE_Y;
        frame.origin.y =24*PSDSCALE_Y;
        btn.frame = frame;
        _old_btn = btn;
        
    }
    
    UIView *unShare_imageView = [_old_btn viewWithTag:100];
    unShare_imageView.center = CGPointMake(VIEW_W(btn)/2, VIEW_H(btn)/2);
    
    AlbumsTravelDetailModel *detailModel = [_model.dataSource objectAtIndex:_old_btn.tag - 1];
    unShare_imageView.hidden = detailModel.shared;
    
    self.select_index = _old_btn.tag - 1;
    
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    detailImage.image = image;

    _share_btn.selected = !detailModel.shared;
    if (detailModel.mood.length) {
        opinionTextView.text = detailModel.mood;
        tishiLab.text = @"";
    } else {
        tishiLab.text = @"写上您的心情吧....";
        opinionTextView.text = nil;
    }
}



#pragma mark- UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    
    if (textView.text.length == 0) {
        tishiLab.text = @"写上您的心情吧....";
    }
    else
    {
        tishiLab.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text] == YES)
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    AlbumsTravelDetailModel *detailModel = [_model.dataSource objectAtIndex:_old_btn.tag - 1];
    detailModel.mood = textView.text;
    
    // 保存到数据库
    [CacheTool updateTravelDetailWithDetailModel:detailModel];
}




@end
