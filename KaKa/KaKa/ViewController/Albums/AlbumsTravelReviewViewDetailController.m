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
#import "PhotoCell.h"


static NSString * const PhotoCellID = @"PhotoCell";

@interface AlbumsTravelReviewViewDetailController ()<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    // 照片美化编辑组件
    TuSDKCPPhotoEditMultipleComponent *_photoEditMultipleComponent;
}


/** 选中的位置 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;



@end

@implementation AlbumsTravelReviewViewDetailController
{
    UIImageView *detailImage;
    UITextView *opinionTextView;
    UILabel *tishiLab;
   
    UIButton *_share_btn;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"我的游记" wordNun:4];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    
    
    
 
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:GETYCIMAGE(@"albums_meihua") wordNum:2 actionBlock:^(UIButton *sender) {
        
        if (weakSelf.selectedIndexPath.row < weakSelf.model.dataSource.count) {
            AlbumsTravelDetailModel *selectDetailModel = weakSelf.model.dataSource[weakSelf.selectedIndexPath.row];
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
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
   
    
    
    
}

- (void)initUI
{
    detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 422*PSDSCALE_Y)];
    detailImage.contentMode = UIViewContentModeScaleAspectFill;
    detailImage.clipsToBounds = YES;
    [self.view addSubview:detailImage];
    
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

    
    UIButton *share_btn = [[UIButton alloc] initWithFrame:CGRectMake(27*PSDSCALE_X, VIEW_H_Y(opinionTextView)+18*PSDSCALE_Y, 65*PSDSCALE_X, 47*PSDSCALE_Y)];
    [share_btn setImage:GETYCIMAGE(@"albums_my_youji_share_nor") forState:UIControlStateNormal];
    [share_btn setImage:GETYCIMAGE(@"albums_my_youji_share_sel") forState:UIControlStateSelected];
    [share_btn addTarget:self action:@selector(share_btn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share_btn];
    _share_btn = share_btn;

    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_W_X(share_btn)+29*PSDSCALE_X, VIEW_H_Y(opinionTextView)+30*PSDSCALE_Y, 200*PSDSCALE_X, 32*PSDSCALE_Y)];
    lab.text = @"不分享此照片";
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = RGBSTRING(@"cccccc");
    lab.font = [UIFont systemFontOfSize:25*FONTCALE_Y];
    [self.view addSubview:lab];
    
    
    // 流水布局:调整cell尺寸
    UICollectionViewFlowLayout *layout = ({
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(155*PSDSCALE_X, 88*PSDSCALE_Y);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 设置最小行间距
        layout.minimumLineSpacing = 0;
        
        layout;
        
    });
    
    // 创建UICollectionView:黑色
    UICollectionView *collectionView = ({
        
        UICollectionView *collectionView =  [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor grayColor];
        collectionView.center = self.view.center;
        collectionView.frame = CGRectMake(0, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT-148*PSDSCALE_Y, SCREEN_WIDTH, 148*PSDSCALE_Y);
        collectionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:collectionView];
        
        // 设置数据源
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        collectionView;
        
    });
    self.collectionView = collectionView;
    
    // 注册cell
    [collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:PhotoCellID];
    

    
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
    [self.collectionView reloadData];
//    [_old_btn setImage:image forState:UIControlStateNormal];
    //保存到游记相册     Save to album
    
    AlbumsTravelDetailModel *selectDetailModel = [_model.dataSource objectAtIndex:self.selectedIndexPath.row];
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
    
    AlbumsTravelDetailModel *detailModel = [_model.dataSource objectAtIndex:self.selectedIndexPath.row];
    detailModel.shared = !btn.selected;
    
    // 保存到数据库
    [CacheTool updateTravelDetailWithDetailModel:detailModel];
    
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
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
    
    AlbumsTravelDetailModel *detailModel = [_model.dataSource objectAtIndex:self.selectedIndexPath.row];
    detailModel.mood = textView.text;
    
    // 保存到数据库
    [CacheTool updateTravelDetailWithDetailModel:detailModel];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellID forIndexPath:indexPath];
    
    [cell refreshWithAlbumsTravelDetailModel:self.model.dataSource[indexPath.row] cameraMac:self.cameraMac];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (self.selectedIndexPath == indexPath) {
        return CGSizeMake(186*PSDSCALE_X, 106*PSDSCALE_Y);
    }else{
        return CGSizeMake(155*PSDSCALE_X, 88*PSDSCALE_Y);
    }
    
    
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    
    AlbumsTravelDetailModel *model = self.model.dataSource[indexPath.row];
//    model.shared = !model.shared;
    _share_btn.selected = !model.shared;
    if (model.mood.length) {
        opinionTextView.text = model.mood;
        tishiLab.text = @"";
    } else {
        tishiLab.text = @"写上您的心情吧....";
        opinionTextView.text = nil;
    }
    
    NSString *path = [Travel_Path(self.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)model.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", model.fileName]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    detailImage.image = image;

    
    [collectionView reloadData];
}

@end
