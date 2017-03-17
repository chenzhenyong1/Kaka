//
//  EyeCheckTrackController.m
//  KaKa
//
//  Created by 陈振勇 on 16/10/10.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "EyeCheckTrackController.h"
#import "EyeDetailInfoCell.h"
#import "EyeDetailMediaCell.h"
#import "AlbumsPathModel.h"

@interface EyeCheckTrackController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView */
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation EyeCheckTrackController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = ZYGlobalBgColor;
    
    [self tableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"浏览";
    [self setupNavBar];
}


#pragma mark -- property

-(UITableView *)tableView
{
    if (!_tableView) {
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:tableView];
        //注册cell
        [tableView registerClass:[EyeDetailInfoCell class] forCellReuseIdentifier:@"EyeDetailInfoCell"];
        [tableView registerClass:[EyeDetailMediaCell class] forCellReuseIdentifier:@"EyeDetailMediaCell"];
        //约束
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-8);
        }];
        
        _tableView = tableView;
        
    }
    
    return _tableView;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  2;
    
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
        [cell refreshCheckTrack:self.model];
        
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

@end
