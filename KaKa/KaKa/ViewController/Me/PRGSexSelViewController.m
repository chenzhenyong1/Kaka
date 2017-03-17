//
//  PRGSexSelViewController.m
//  AiFuKa
//
//  Created by Change_pan on 16/6/23.
//  Copyright © 2016年 showsoft. All rights reserved.
//

#import "PRGSexSelViewController.h"

@interface PRGSexSelViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation PRGSexSelViewController
{
    UITableViewCell *_oldCell;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        [_dataSource addObject:@"男"];
        [_dataSource addObject:@"女"];
    }
    return _dataSource;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.contentInset = UIEdgeInsetsMake(16, 0, 0, 0);
    }
    return _tableView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"性别选择" wordNun:4];
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:@"保存" wordNum:2 actionBlock:^(UIButton *sender) {
        
        [weakSelf saveData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sexCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sexCell"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:GETYCIMAGE(@"camera_radioBtn_nor.png")];
        imageView.highlightedImage = GETNCIMAGE(@"camera_radioBtn_sel.png");
        imageView.userInteractionEnabled = YES;
        cell.accessoryView = imageView;
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)cell.accessoryView;
    
    if ([cell.textLabel.text isEqualToString:self.sex])
    {
        imageView.highlighted = YES;
        _oldCell = cell;
    }
    else
    {
        imageView.highlighted = NO;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120*PSDSCALE_Y;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *oldImgView = (UIImageView *)_oldCell.accessoryView;
    oldImgView.highlighted = NO;
    
    UIImageView *imgView = (UIImageView *)cell.accessoryView;
    imgView.highlighted = YES;
    _oldCell = cell;
    NSString *sexStr;
    if ([cell.textLabel.text isEqualToString:@"男"]) {
        sexStr = @"M";
    }
    else
    {
        sexStr = @"F";
    }
//    [self addActityLoading:nil subTitle:nil];
//    [RequestManager editUserDetailWithCardid:nil realname:nil sex:sexStr user_addr:nil user_company:nil user_nicename:nil Succeed:^(id responseObject) {
//        [self removeActityLoading];
//        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
//            [self addActityText:VALUEFORKEY(resultDic, @"info") deleyTime:1];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.block();
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//            MMLog(@"%@",resultDic);
//        } err_block:^(NSDictionary *resultDic) {
//            [self addActityText:VALUEFORKEY(resultDic, @"info") deleyTime:1];
//            MMLog(@"%@",resultDic);
//        }];
//        
//    } failed:^(NSError *error) {
//        [self removeActityLoading];
//        REQUEST_FAILED_ALERT;
//        MMLog(@"%@",error);
//    }];
}

- (void)saveData {
    
    NSString *sexStr;
    if ([_oldCell.textLabel.text isEqualToString:@"男"]) {
        sexStr = @"M";
    }
    else if ([_oldCell.textLabel.text isEqualToString:@"女"])
    {
        sexStr = @"F";
    }
    
    if (sexStr.length == 0) {
        [self addActityText:@"请选择性别" deleyTime:2];
        return;
    }
    
    NSDictionary *userInfoDic = @{@"gender":sexStr};
    
    [self addActityLoading:nil subTitle:nil];
    [RequestManager postUpdateUserInfoWithUserInfo:userInfoDic succeed:^(id responseObject) {
        [self removeActityLoading];
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            [self addActityText:@"修改成功" deleyTime:1];
            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
            self.block(sexStr);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
            
        } err_block:^(NSDictionary *resultDic) {
            [self addActityText:@"修改失败" deleyTime:1];
        }];
    } failed:^(NSError *error) {
        [self removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];

}


@end
