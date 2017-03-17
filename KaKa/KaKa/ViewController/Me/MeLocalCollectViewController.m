//
//  MeLocalCollectViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/9/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MeLocalCollectViewController.h"
#import "MeLocalCollectTableViewCell.h"
#import "FMDBTools.h"

#import "AlbumsTravelReviewViewController.h"
#import "AlbumsPathDetailViewController.h"
#import "MoviePlayerViewController.h"
#import "AlbumsModel.h"
#import "MyTools.h"
#import "LHPhotoBrowser.h"

@interface MeLocalCollectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MeLocalCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    [self loadCollectsFromDB];
    
    [NotificationCenter addObserver:self selector:@selector(loadCollectsFromDB) name:@"TravelDeleteSuccess" object:nil];
}

- (void)loadCollectsFromDB {
    self.dataSource = [FMDBTools getImageUrlsFromDataBaseWithName:UserName];
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT_4s - NAVIGATIONBARHEIGHT)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _tableView.backgroundColor = RGBSTRING(@"eeeeee");
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    MeLocalCollectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MeLocalCollectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    __weak typeof(self) weakSelf = self;
    cell.model = [self.dataSource objectAtIndex:indexPath.row];
    cell.cancelCollectBlock = ^(BOOL isCancelSuccess) {
        if (isCancelSuccess) {
            [weakSelf loadCollectsFromDB];
            
        } else {
            [weakSelf addActityText:@"删除失败" deleyTime:1];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 325;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if ([model.collectType isEqualToString:kCollectTypePath]) {
        // 轨迹
        AlbumsPathDetailViewController *albumsPathDetailVC = [[AlbumsPathDetailViewController alloc] init];
        albumsPathDetailVC.model = [FMDBTools getPathsFromDataBaseWithFile_name:model.collectSoruce];;
        [self.navigationController pushViewController:albumsPathDetailVC animated:YES];
    } else if ([model.collectType isEqualToString:kCollectTypePhoto]) {
        // 图片
        AlbumsModel *albumsModel = [[AlbumsModel alloc] init];
        albumsModel.imageName = model.collectSoruce;
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:albumsModel.imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 700*PSDSCALE_Y, SCREEN_WIDTH, 300*PSDSCALE_Y)];
        imageView.image = image;
    
        LHPhotoBrowser *bc = [[LHPhotoBrowser alloc] init];
        bc.imgsArray = [@[imageView] mutableCopy];
        bc.tapImgIndex = 0;
        bc.hideStatusBar = NO;
        [bc showWithPush:self]; //push方式
        
    } else if ([model.collectType isEqualToString:kCollectTypeVideo]) {
        NSString *fileName = model.collectSoruce;
        
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
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:fileName];
        MoviePlayerViewController *playVC = [[MoviePlayerViewController alloc] init];
        playVC.videoURL = sourceMovieURL;
        playVC.imageURL = model.collectSoruce;
        playVC.autoPlayTheVideo = YES;
        [self.navigationController pushViewController:playVC animated:YES];

    } else if ([model.collectType isEqualToString:kCollectTypeTravel]) {
        // 游记
        AlbumsTravelReviewViewController *reviewVC = [[AlbumsTravelReviewViewController alloc] init];
        reviewVC.model = [CacheTool queryTravelsWithTravelId:model.collectSoruce];;
        [self.navigationController pushViewController:reviewVC animated:YES];
    }
}
@end
