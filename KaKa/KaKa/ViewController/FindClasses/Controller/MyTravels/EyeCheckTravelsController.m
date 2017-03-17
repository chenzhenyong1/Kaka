//
//  EyeCheckTravelsController.m
//  KaKa
//
//  Created by 陈振勇 on 16/9/27.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeCheckTravelsController.h"
#import "EyeDetailInfoCell.h"
#import "EyeDetailMediaCell.h"
@interface EyeCheckTravelsController ()

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation EyeCheckTravelsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNav];
}

- (void)setupNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - property

-(void)setModel:(AlbumsTravelModel *)model
{
    _model = model;
    
    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:model.travelId];
    
//    NSMutableArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:model.travelId];
    NSMutableArray *arr = [travelDetailArray mutableCopy];
    for (AlbumsTravelDetailModel *detailModel in arr) {
        if (!detailModel.shared) {
            [travelDetailArray removeObject:detailModel];
        }
    }
    
    
    for (int i = 0; i < travelDetailArray.count; i ++) {
        
        if ([self.coverImageName isEqualToString:[travelDetailArray[i] fileName]]) {
            
            [travelDetailArray exchangeObjectAtIndex:0 withObjectAtIndex:i];
            
        }
        
    }
    
    
    for (AlbumsTravelDetailModel *detailModel in travelDetailArray) {
        
        [self.dataSource addObject:detailModel];
        
    }
    
   
}

-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        
        _dataSource = [NSMutableArray array];
        
    }
    
    return _dataSource;
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  1 + self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        
        EyeDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EyeDetailInfoCell"];
        
        cell.mood = self.mood;
        
        [cell refreshCheckUI:self.addressModel];
        
        return cell;
    }else
    {
        EyeDetailMediaCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EyeDetailMediaCell"];
        }
        AlbumsTravelDetailModel *model = self.dataSource[indexPath.row - 1];
        
        NSString *imagePath = [self getTraverlImagePath:model];
        
        [cell refreshCheckTravels:imagePath];
        
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(kScreenWidth - 20 , MAXFLOAT);
        CGFloat textH = [self.mood boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
        
        return 10 + 45 + 10 + textH + 10;
        
    }else{
        
        return kScreenWidth * 9/16 + 10;
    }
    
}

#pragma mark -- 获取游记图片

- (NSString *)getTraverlImagePath:(AlbumsTravelDetailModel *)detailModel
{
    
    NSString *path = [Travel_Path(self.model.cameraMac) stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld", (long)detailModel.travelId]];
    NSString *imagePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", detailModel.fileName]];
    
    return imagePath;
}

@end
