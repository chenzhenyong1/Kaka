//
//  MePersonalDetailViewController.m
//  KaKa
//
//  Created by Change_pan on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "MePersonalDetailViewController.h"
#import "MePersonalDetailVCTableViewCell.h"
#import "MeParentModel.h"
#import "MeArrowItemModel.h"
#import "MeGroupModel.h"

#import "PRGSexSelViewController.h"
#import "PRGSettingDataViewController.h"
#import "STPickerArea.h"

#import "RecordModel.h" //  创建媒体记录返回数据
#import "Credentials.h"
#import "ItemList.h"

#import <AliyunOSSiOS/OSSService.h>//阿里云

#define headerPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"touXiang.jpg"]//头像路径

@interface MePersonalDetailViewController ()<UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, STPickerAreaDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) STPickerArea *pickerArea;

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;


/** Credentials.h */
@property (nonatomic, strong) Credentials *credentials;
/** Credentials.h */
@property (nonatomic, strong) ItemList *itemList;

/** 头像 */
@property (nonatomic, strong) UIImage *headerImage;

@end

@implementation MePersonalDetailViewController

#pragma mark- 懒加载
-(NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
        
        NSDictionary *userInfo = UserInfo;
        
        NSString *headImageStr = FORMATSTRING(VALUEFORKEY(userInfo, @"portraitImgUrl"));
        if (headImageStr.length == 0) {
            headImageStr = @"aaa";
        }
        MeParentModel *headImage = [MeArrowItemModel itemWithTitle:@"头像" titleImage:headImageStr detail:nil];
        MeGroupModel *group0 = [[MeGroupModel alloc] init];
        group0.items = @[headImage];
        
        NSString *trajectoryDetail = [NSString stringWithFormat:@"总积分:%@  周积分:%@", VALUEFORKEY(userInfo, @"userPoints"), VALUEFORKEY(userInfo, @"userWeekPoints")];
        MeParentModel *trajectory = [MeArrowItemModel itemWithTitle:@"积分" titleImage:nil detail:trajectoryDetail];
        MeGroupModel *group1 = [[MeGroupModel alloc] init];
        group1.items = @[trajectory];
        
        MeParentModel *nickName = [MeArrowItemModel itemWithTitle:@"昵称" titleImage:nil detail:FORMATSTRING(VALUEFORKEY(userInfo, @"nickName"))];
        MeParentModel *account = [MeParentModel itemWithTitle:@"账号" titleImage:nil detail:FORMATSTRING(VALUEFORKEY(userInfo, @"userName"))];
        MeGroupModel *group2 = [[MeGroupModel alloc] init];
        group2.items = @[nickName,account];
        
        NSString *sexDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"gender"));
        if ([sexDetail isEqualToString:@"F"]) {
            sexDetail = @"女";
        } else if ([sexDetail isEqualToString:@"M"]) {
            sexDetail = @"男";
        } else {
            // 没有，保密
            sexDetail = @"保密";
        }
        MeParentModel *sex = [MeArrowItemModel itemWithTitle:@"性别" titleImage:nil detail:sexDetail];
        
        NSString *areaDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"region"));
        if (areaDetail.length == 0) {
            areaDetail = @"未知";
        }
        MeParentModel *area = [MeArrowItemModel itemWithTitle:@"地区" titleImage:nil detail:areaDetail];
        
        NSString *signDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"signature"));
        if (signDetail.length == 0) {
            signDetail = @"未填写";
        }
        MeParentModel *sign = [MeArrowItemModel itemWithTitle:@"签名" titleImage:nil detail:signDetail];
        MeGroupModel *group3 = [[MeGroupModel alloc] init];
        group3.items = @[sex,area,sign];
        
        MeParentModel *logout = [MeParentModel itemWithTitle:nil titleImage:nil detail:@"退出登录"];
        MeGroupModel *group4 = [[MeGroupModel alloc] init];
        group4.items = @[logout];
        
        [_dataSource addObject:group0];
        [_dataSource addObject:group1];
        [_dataSource addObject:group2];
        [_dataSource addObject:group3];
        [_dataSource addObject:group4];
    }
    return _dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


-(UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBARHEIGHT-215*PSDSCALE_Y) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addTitleWithName:@"个人信息" wordNun:4];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = RGBSTRING(@"eeeeee");
    [self addBackButtonWith:^(UIButton *sender) {
        
    }];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
}


#pragma mark -UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MeGroupModel *group = self.dataSource[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MePersonalDetailVCTableViewCell *cell = [MePersonalDetailVCTableViewCell cellWithTableView:tableView];
    MeGroupModel *group = self.dataSource[indexPath.section];
    MeParentModel *model = group.items[indexPath.row];
    cell.item = model;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 4) {
        return 60*PSDSCALE_Y;
    }
    else
    {
        return 19*PSDSCALE_Y;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section !=0) {
        return 100*PSDSCALE_Y;
    }
    else
    {
        return 130*PSDSCALE_Y;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MeGroupModel *group = self.dataSource[indexPath.section];
    MeParentModel *model = group.items[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == self.dataSource.count - 1) {
        // 退出登录
        [NotificationCenter postNotificationName:@"loginStatusNotification" object:@"0"];
        [SettingConfig shareInstance].isLogin = NO;
        [SettingConfig shareInstance].ip_url = nil;
        [SettingConfig shareInstance].currentCameraModel = nil;
        [SettingConfig shareInstance].deviceLoginToken = nil;
        
        AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
        socketManager.asyncSocket.userData = SocketOfflineByUser;
        [socketManager disconnectSocket];
        
        [self.tabBarController setSelectedIndex:0];
        [self.navigationController popViewControllerAnimated:NO];
        
    } else if (indexPath.section == 0) {
        // 头像
        UIActionSheet *sheetView = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        [sheetView showInView:self.view];
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            // 昵称
            PRGSettingDataViewController *settingVC = [[PRGSettingDataViewController alloc] init];
            settingVC.titleStr = @"昵称";
            settingVC.detail = model.detail;
            settingVC.hidesBottomBarWhenPushed = YES;
            settingVC.block = ^(NSString *detailStr){
                NSDictionary *userInfo = UserInfo;
                
                MeParentModel *nickName = [MeArrowItemModel itemWithTitle:@"昵称" titleImage:nil detail:detailStr];
                MeParentModel *account = [MeParentModel itemWithTitle:@"账号" titleImage:nil detail:FORMATSTRING(VALUEFORKEY(userInfo, @"userName"))];
                MeGroupModel *group2 = [[MeGroupModel alloc] init];
                group2.items = @[nickName,account];
                [weakSelf.dataSource replaceObjectAtIndex:2 withObject:group2];
                [weakSelf.tableView reloadData];
            };

            [self.navigationController pushViewController:settingVC animated:YES];
        }
    } else if (indexPath.section == 3) {
        
        if (indexPath.row == 0) {
            // 性别
            PRGSexSelViewController *sexVC = [[PRGSexSelViewController alloc] init];
            sexVC.sex = model.detail;
            sexVC.hidesBottomBarWhenPushed = YES;
            
            sexVC.block = ^(NSString *detailStr) {
                NSDictionary *userInfo = UserInfo;
                if ([detailStr isEqualToString:@"F"]) {
                    detailStr = @"女";
                } else if ([detailStr isEqualToString:@"M"]) {
                    detailStr = @"男";
                } else {
                    // 没有，保密
                    detailStr = @"保密";
                }
                
                MeParentModel *sex = [MeArrowItemModel itemWithTitle:@"性别" titleImage:nil detail:detailStr];
                
                NSString *areaDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"region"));
                if (areaDetail.length == 0) {
                    areaDetail = @"未知";
                }
                MeParentModel *area = [MeArrowItemModel itemWithTitle:@"地区" titleImage:nil detail:areaDetail];
                
                NSString *signDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"signature"));
                if (signDetail.length == 0) {
                    signDetail = @"未填写";
                }
                MeParentModel *sign = [MeArrowItemModel itemWithTitle:@"签名" titleImage:nil detail:signDetail];
                MeGroupModel *group3 = [[MeGroupModel alloc] init];
                group3.items = @[sex,area,sign];
                [weakSelf.dataSource replaceObjectAtIndex:3 withObject:group3];
                [weakSelf.tableView reloadData];
                
            };

            
            [self.navigationController pushViewController:sexVC animated:YES];
        } else if (indexPath.row == 1) {
            // 地区
            if (!_pickerArea) {
                _pickerArea = [[STPickerArea alloc] init];
                _pickerArea.delegate = self;
                _pickerArea.contentView.backgroundColor = RGBSTRING(@"f9f9f9");
                _pickerArea.lineView.hidden = YES;
                _pickerArea.labelTitle.hidden = YES;
                _pickerArea.borderButtonColor = RGBSTRING(@"f9f9f9");
            }
            [_pickerArea show];
            
        } else if (indexPath.row == 2) {
            // 签名
            
            NSString *detail = model.detail;
            if (FORMATSTRING(VALUEFORKEY(UserInfo, @"signature")).length == 0) {
                detail = @"";
            }
            
            PRGSettingDataViewController *settingVC = [[PRGSettingDataViewController alloc] init];
            settingVC.titleStr = @"签名";
            settingVC.detail = detail;
            settingVC.hidesBottomBarWhenPushed = YES;
            
            settingVC.block = ^(NSString *detailStr) {
                NSDictionary *userInfo = UserInfo;
                NSString *sexDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"gender"));
                if ([sexDetail isEqualToString:@"F"]) {
                    sexDetail = @"女";
                } else if ([sexDetail isEqualToString:@"M"]) {
                    sexDetail = @"男";
                } else {
                    // 没有，保密
                    sexDetail = @"保密";
                }
                
                MeParentModel *sex = [MeArrowItemModel itemWithTitle:@"性别" titleImage:nil detail:sexDetail];
                
                NSString *areaDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"region"));
                if (areaDetail.length == 0) {
                    areaDetail = @"未知";
                }
                MeParentModel *area = [MeArrowItemModel itemWithTitle:@"地区" titleImage:nil detail:areaDetail];
                MeParentModel *sign = [MeArrowItemModel itemWithTitle:@"签名" titleImage:nil detail:detailStr];
                MeGroupModel *group3 = [[MeGroupModel alloc] init];
                group3.items = @[sex,area,sign];
                [weakSelf.dataSource replaceObjectAtIndex:3 withObject:group3];
                [weakSelf.tableView reloadData];

            };
            
            [self.navigationController pushViewController:settingVC animated:YES];
        }
    }
}

#pragma mark - ================================UIActionSheetDelegate===========================

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = YES;
            }
            [self presentViewController:picker animated:YES completion:nil];
            
        }
            break;
        case 1:
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 2:
        {
            MMLog(@"取消");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - ====================================image picker delegte====================================
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self addActityLoading:nil subTitle:nil];
    
    self.headerImage = image;
    //创建头像媒体记录 (创建完成后上传文件)
    [self createMediaRecord:image];
    
//    [RequestManager uploadUserHeadWithData:@[image] Succeed:^(id responseObject) {
//        [self removeActityLoading];
//        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
//            [self addActityText:@"头像上传成功" deleyTime:1];
//            MMLog(@"%@",resultDic);
//            isRefresh = YES;
//            [self.dataSource removeObjectAtIndex:0];
//            
//            PRGMineModel *head = [PRGMineArrowItem itemWithTitle:@"头像" titleImage:VALUEFORKEY(resultDic, @"avatar") subTitle:nil];
//            PRGMineGroup *group0 = [[PRGMineGroup alloc] init];
//            group0.items = @[head];
//            
//            [self.dataSource insertObject:group0 atIndex:0];
//            [self.tableView reloadData];
//            
//        } err_block:^(NSDictionary *resultDic) {
//            [self addActityText:@"头像上传失败" deleyTime:1];
//        }];
//    } failed:^(NSError *error) {
//        MMLog(@"%@",error);
//        [self removeActityLoading];
//        REQUEST_FAILED_ALERT;
//    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    [picker dismissViewControllerAnimated:YES completion:^{}];
}


/**
 *  创建媒体记录
 */
- (void)createMediaRecord:(UIImage *)image
{
    //所要创建的媒体记录。
    NSMutableArray *mediaList = [NSMutableArray array];
    
    //创建媒体时间
    long long mediaCreateTime= [[NSDate date] timeIntervalSince1970]*1000;
    //头像媒体记录参数
    NSMutableDictionary *picParams = [NSMutableDictionary dictionary];
    picParams[@"id"] = @"#1";
    picParams[@"mediaType"] = @"p";
    picParams[@"format"] = @"jpg";
    picParams[@"shareState"] = @"1";
    picParams[@"uploadTrigger"] = @"4";
    picParams[@"mediaCreateTime"] = [NSString stringWithFormat:@"%lld",mediaCreateTime];
    picParams[@"fileSize"] = [NSNumber numberWithLong:UIImageJPEGRepresentation(image, 0.5).length];
    
    [mediaList addObject:picParams];
    
    
    //1.封装请求参数
    [self addActityLoading:@"创建头像媒体记录中..." subTitle:@"请等待"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mediaList"] = mediaList;
    params[@"loginToken"] = LoginToken;
    
    //请求
    [HttpTool post:createMedias_URL params:params success:^(id responseObj) {
       
        ZYLog(@"responseObj = %@",responseObj);
    
        RecordModel *model = [RecordModel mj_objectWithKeyValues:responseObj[@"result"]];

        self.credentials = model.credentials[0];
        
        self.itemList = model.itemList[0];

        //        //上传文件
        [self addActityLoading:@"正在上传头像中..." subTitle:@"请等待"];
       //将要上传的图片写入文件
        [self saveImage:image atPath:headerPath compressionQuality:0.5];
        //上传文件
        [self upLoadFile];

    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];
    
    
}

/**
 *  上传文件
 */

- (void)upLoadFile
{
    Credentials *credentials = self.credentials;
    ItemList *itemList = self.itemList;
    NSString *endpoint = credentials.endPoint;
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:credentials.keyId secretKeyId:credentials.keySecret securityToken:credentials.securityToken];
    
    ZYLog(@"securityToken ==== %@",credentials.securityToken);
    
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = credentials.bucket;
    put.objectKey = itemList.storePath;
    
    put.uploadingFileURL = [NSURL fileURLWithPath:headerPath];
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
        ZYLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            
//            [self addActityText:@"上传成功" deleyTime:1.0];
            ZYLog(@"upload object success!");
            // 更新媒体状态
            [self updateMediaState:itemList];
            
            
            
        } else {
            ZYLog(@"upload object failed, error: %@" , task.error);
            [self addActityText:@"上传失败" deleyTime:1.0];
        }
        return nil;
    }];
    
}

/**
 *  更新媒体状态
 *
 *  @param itemList itemList description
 */
- (void)updateMediaState:(ItemList *)itemList
{
    // 1.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"mediaId"] = itemList.ID;
    params[@"mediaState"] = @"2";
    
    [HttpTool post:updateMediaState_URL params:params success:^(id responseObj) {
        ZYLog(@"媒体状态更新成功responseObj = %@ itemListID = %@",responseObj,itemList.ID);
        //更新用户一般信息
        [self updateUserInfo:itemList];
        
        
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];
    
}

/**
 *  更新用户一般信息
 */
- (void)updateUserInfo:(ItemList *)itemList
{
    
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionary];
    userInfo[@"portraitImgId"] = itemList.ID;
    userInfo[@"portraitImgUrl"] = itemList.mediaUrl;
    
    
    // 1.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"loginToken"] = LoginToken;
    params[@"userInfo"] = userInfo;
    
    
    [HttpTool post:updateUserInfo_URL params:params success:^(id responseObj) {
        ZYLog(@"更新用户一般信息responseObj = %@ itemListID = %@",responseObj,itemList.ID);
    
        
        [self addActityText:@"上传成功" deleyTime:1.0];
        
        // 更新头像信息
        MeParentModel *headImage = [MeArrowItemModel itemWithTitle:@"头像" titleImage:itemList.mediaUrl detail:nil];
        MeGroupModel *group0 = [[MeGroupModel alloc] init];
        group0.items = @[headImage];
        [self.dataSource replaceObjectAtIndex:0 withObject:group0];
        [self.tableView reloadData];
        [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
        
    } failure:^(NSError *error) {
        ZYLog(@"error = %@",error);
    }];
}


//保存图片
- (void)saveImage:(UIImage *)tempImage atPath:(NSString *)path compressionQuality:(CGFloat)compressionQuality
{
    NSData* imageData = UIImageJPEGRepresentation(tempImage, compressionQuality);
    
    //图片数据保存到 document
    [imageData writeToFile:path atomically:NO];
}


#pragma mark - STPickerAreaDelegate
- (void)pickerArea:(STPickerArea *)pickerArea province:(NSString *)province city:(NSString *)city area:(NSString *)area {
    
    MMLog(@"province = %@, city = %@, area = %@", province, city, area);
    
    NSDictionary *userInfoDic = @{@"region":[NSString stringWithFormat:@"%@%@", province, city]};
    
    [self addActityLoading:nil subTitle:nil];
    [RequestManager postUpdateUserInfoWithUserInfo:userInfoDic succeed:^(id responseObject) {
        [self removeActityLoading];
        [self resolveReturnData:responseObject ok_block:^(NSDictionary *resultDic) {
            [NotificationCenter postNotificationName:@"GetUserInfoNoti" object:nil];
            
            self.province = province;
            self.city = city;
            NSDictionary *userInfo = UserInfo;
            NSString *sexDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"gender"));
            if ([sexDetail isEqualToString:@"F"]) {
                sexDetail = @"女";
            } else if ([sexDetail isEqualToString:@"M"]) {
                sexDetail = @"男";
            } else {
                // 没有，保密
                sexDetail = @"保密";
            }

            MeParentModel *sex = [MeArrowItemModel itemWithTitle:@"性别" titleImage:nil detail:sexDetail];
            
            NSString *areaDetail = [NSString stringWithFormat:@"%@%@", province, city];

            MeParentModel *area = [MeArrowItemModel itemWithTitle:@"地区" titleImage:nil detail:areaDetail];
            
            NSString *signDetail = FORMATSTRING(VALUEFORKEY(userInfo, @"signature"));
            if (signDetail.length == 0) {
                signDetail = @"未填写";
            }
            MeParentModel *sign = [MeArrowItemModel itemWithTitle:@"签名" titleImage:nil detail:signDetail];
            MeGroupModel *group3 = [[MeGroupModel alloc] init];
            group3.items = @[sex,area,sign];
            [self.dataSource replaceObjectAtIndex:3 withObject:group3];
            [self.tableView reloadData];
            
        } err_block:^(NSDictionary *resultDic) {
            [self addActityText:@"修改失败" deleyTime:1];
        }];
    } failed:^(NSError *error) {
        [self removeActityLoading];
        REQUEST_FAILED_ALERT;
    }];
}

@end
