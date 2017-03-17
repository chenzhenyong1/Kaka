//
//  EyeBreakRulesVideoListController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/27.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBreakRulesVideoListController.h"
#import "EyeBreakRulesEditController.h"
#import "VideoListModel.h"
#import "MyTools.h"

@interface EyeBreakRulesVideoListController ()

@end

@implementation EyeBreakRulesVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.view.backgroundColor = ZYGlobalBgColor;
}

- (void)rightItemClick
{
    

}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    VideoListModel *model = self.dataSource[indexPath.row];
    NSString *fileName = model.imageName;
    if ([fileName containsString:@"CyclePhoto"]) {
        
        fileName = [self cyclePhoto_PathChangeCycleVideo_Path:fileName];
        
    }else{
        fileName = [fileName componentsSeparatedByString:@"_"][0];
        fileName = [fileName componentsSeparatedByString:@"/"].lastObject;
        NSArray *pathArr =[MyTools getAllDataWithPath:Video_Path(nil) mac_adr:nil];
        
        for (NSString *str in pathArr)
        {
            
            if ([str containsString:fileName])
            {
                fileName = str;
                break;
            }
        }
        
    }
    
    
    
    //跳转到视频编辑页面
    EyeBreakRulesEditController *breakRulesEditCtl = [[EyeBreakRulesEditController alloc] init];
    
    breakRulesEditCtl.originalVideoPath = fileName;
    
    [self.navigationController pushViewController:breakRulesEditCtl animated:YES];
}

@end
