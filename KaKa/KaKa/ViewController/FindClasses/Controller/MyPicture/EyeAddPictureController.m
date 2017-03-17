//
//  EyeAddPictureController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/22.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeAddPictureController.h"

@interface EyeAddPictureController ()

@end

@implementation EyeAddPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initSetup];
    
    
}

//初始化设置
- (void)initSetup
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    
    for (EyePictureListModel *model in self.dataArr) {
        
        for (EyePictureListModel *datamodel in self.dataSource) {
            
            if ([model.imageName isEqualToString:datamodel.imageName]) {
                
                datamodel.isSelect = YES;
                
                [self.shareSource addObject:datamodel];
            }
            
        }
        
    }
    
//    self.shareSource = [self.dataArr mutableCopy];
    
    [self.collectionView reloadData];
}



/**
 *  点击确定
 */
- (void)rightItemClick
{
    
    if (self.shareSource.count == 0) {
        [self addActityText:@"请选择图片" deleyTime:0.5];
        
        return;
    }
    
    self.addPicCtlBlock(self.shareSource);
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



@end
