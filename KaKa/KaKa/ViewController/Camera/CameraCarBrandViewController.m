//
//  CameraCarBrandViewController.m
//  KaKa
//
//  Created by Change_pan on 16/8/9.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraCarBrandViewController.h"
#import "CarBrandModel.h"
#import "BMChineseSort.h"
#import "CameraCarBrandTableViewCell.h"
@interface CameraCarBrandViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray<CarBrandModel *> *dataArray;
}
@property (nonatomic, strong) UILabel *sectionTitleView;

@property (nonatomic, strong) NSTimer *timer;
//排序后的出现过的拼音首字母数组（形式：@[@"a",@"f",@"g",@"z"]）
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组（形式：@[@[对象1(a开头)，对象2(a开头)], @[对象3(c开头)，对象4(c开头)]]）
@property(nonatomic,strong)NSMutableArray *letterResultArr;
@end

@implementation CameraCarBrandViewController
{
    UITableView *_tableView;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"选择爱车品牌" wordNun:6];
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    
    self.sectionTitleView = ({
        UILabel *sectionTitleView = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, (SCREEN_HEIGHT-100)/2,100,100)];
        sectionTitleView.textAlignment = NSTextAlignmentCenter;
        sectionTitleView.font = [UIFont boldSystemFontOfSize:60];
        sectionTitleView.textColor = [UIColor whiteColor];
        sectionTitleView.backgroundColor = [UIColor blackColor];
        sectionTitleView.layer.cornerRadius = 6;
        sectionTitleView.layer.borderWidth = 1.f/[UIScreen mainScreen].scale;
        _sectionTitleView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        sectionTitleView;
    });
    [self.navigationController.view addSubview:self.sectionTitleView];
    self.sectionTitleView.hidden = YES;
    [self loadData];
    //根据Person对象的 name 属性 按中文 对 Person数组 排序
    self.indexArray = [BMChineseSort IndexWithArray:dataArray Key:@"car_name"];
    self.letterResultArr = [BMChineseSort sortObjectArray:dataArray Key:@"car_name"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

//加载模拟数据
-(void)loadData{

    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"car_brand" ofType:@"plist"];
    NSArray *stringsToSort = [[NSArray alloc]initWithContentsOfFile:path];
    
    
    
    //模拟网络请求接收到的数组对象
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i<[stringsToSort count]; i++) {
        CarBrandModel *car_brand = [[CarBrandModel alloc] init];
        NSDictionary *dic = [stringsToSort objectAtIndex:i];
        car_brand.car_name = VALUEFORKEY(dic, @"name");
        car_brand.car_image_name = VALUEFORKEY(dic, @"image");
        car_brand.number = i;
        [dataArray addObject:car_brand];
    }
}

#pragma mark - UITableViewDataSource
//section的titleHeader
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.indexArray objectAtIndex:section];
}
//section行数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.indexArray count];
}
//每组section个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.letterResultArr objectAtIndex:section] count];
}
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArray;
}
//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    [self showSectionTitle:title];
    return index;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100*PSDSCALE_Y;
}
//返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CameraCarBrandTableViewCell *cell = [CameraCarBrandTableViewCell cellWithTableView:tableView];
    
    //获得对应的Person对象
    CarBrandModel *carBrand = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell refreshData:carBrand];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CarBrandModel *carBrand = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    self.block(carBrand);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
    
}

#pragma mark - private
- (void)timerHandler:(NSTimer *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            self.sectionTitleView.alpha = 0;
        } completion:^(BOOL finished) {
            self.sectionTitleView.hidden = YES;
        }];
    });
}

-(void)showSectionTitle:(NSString*)title{
    [self.sectionTitleView setText:title];
    self.sectionTitleView.hidden = NO;
    self.sectionTitleView.alpha = 1;
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

@end
