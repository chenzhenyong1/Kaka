//
//  EyeBreakRulesTypeController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/16.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBreakRulesTypeController.h"
#import "EyeBreakRuleType.h"

@interface EyeBreakRulesTypeController ()

/** 数据源 */
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation EyeBreakRulesTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"违章类型";
    self.view.backgroundColor = ZYGlobalBgColor;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self setupTableView];
    
    
    [self loadData];
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupTableView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    // 分割线从左侧开始
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    
    
}

- (void)loadData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"enumTypes"] = @"kaka.trafficViolationType";
    
    [HttpTool get:Enums_URL params:params success:^(id responseObj) {
        ZYLog(@"responseObj = %@",responseObj);
        
        NSArray *dataArr = [EyeBreakRuleType mj_objectArrayWithKeyValuesArray:responseObj[@"result"][@"enumTypes"][0][@"enumValues"]];
        
        self.dataArr = dataArr;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];

}


#pragma mark -- tableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    EyeBreakRuleType *type = self.dataArr[indexPath.row];
    
    cell.textLabel.text = type.v;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EyeBreakRuleType *type = self.dataArr[indexPath.row];
    
    self.breakRulesTypeBlock(type.v);
    
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
}
@end
