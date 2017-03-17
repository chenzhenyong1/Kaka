//
//  CameraViewController.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/18.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraHomeTableViewCell.h"

#import "CameraDetailViewController.h"
#import "AsyncUdpSocketManager.h"
#import "MyTools.h"
#import "CameraListModel.h"
#import "CameraLoginViewController.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h> 
#import <arpa/inet.h>

@interface CameraViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    // 停止搜索定时器
    NSTimer * endSearchTimer;
}

// 没有添加摄像头提示
@property (nonatomic, strong) UIImageView *noCameraImageView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CameraListModel *selectCameraListModel;

// UDP socket
@property (nonatomic,strong) AsyncUdpSocketManager *udpManager;

//是否升级了
@property (nonatomic, assign) BOOL isUpload;

@end

@implementation CameraViewController
{
    NSMutableArray *search_camera;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTitle:@"我的咔咔"];
    
    __weak typeof(self) weakSelf = self;
    [self addRightButtonWithName:GETNCIMAGE(@"camera_refresh_icon.png") wordNum:2 actionBlock:^(UIButton *sender) {
        // 刷新发现设备
        [weakSelf searchHost];

    }];
    search_camera = [[NSMutableArray alloc] init];
    // 加载本地数据
    [self loadLocateData];
    
    [self tableView];
    
    [self searchHost];
    
    [NotificationCenter addObserver:self selector:@selector(reloadData:) name:@"CameraListNeedToReloadDataNoti" object:nil];
    // 进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveHandle) name:@"ON_BECOME_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveHandle) name:@"ON_RESIGN_ACTIVE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upload_click:) name:@"upload_action" object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginStatusNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusNotification:) name:@"loginStatusNotification" object:nil];
}

- (void)loginStatusNotification:(NSNotification *)notification{
    if (![notification.object boolValue]) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
    }else{
        [self loadLocateData];
        [self.tableView reloadData];
        [self searchHost];
    }
}


- (void)upload_click:(NSNotification *)not
{
    if ([not.object isEqualToString:@"YES"])
    {
        self.isUpload = YES;
    }
    else
    {
        self.isUpload = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self searchHost];
    });
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self releaseSearch];
}

- (void)reloadData:(NSNotification *)noti {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


/**
 搜索完成，释放socket
 */
- (void)releaseSearch {
    if (_udpManager) {
        [_udpManager closeUDPSocket];
        _udpManager = nil;
    }
    
    if (endSearchTimer) {
        [endSearchTimer invalidate];
        endSearchTimer = nil;
    }
    
    if (_udpManager) {
        [_udpManager closeUDPSocket];
        _udpManager = nil;
    }
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


/**
 进入前台
 */
- (void)onApplicationDidBecomeActiveHandle {
    
    // 获取wifi mac地址
    NSString *BSSID;
    if ([[self getSSIDInfo] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic =  [self getSSIDInfo];
        BSSID = VALUEFORKEY(dic, @"BSSID");
        BSSID = [BSSID uppercaseString]; // 全部转为大写字母
        
        // 将：去除
        NSArray *BSSIDS = [BSSID componentsSeparatedByString:@":"];
        NSMutableArray *temp_arr = [NSMutableArray array];
        for (NSString *str in BSSIDS)
        {
            if (str.length < 2)
            {
                // 不够两位，前面补0
                NSString *temp_str = [NSString stringWithFormat:@"0%@",str];
                [temp_arr addObject:temp_str];
            }
            else
            {
                [temp_arr addObject:str];
            }
            
        }
        BSSID = [temp_arr componentsJoinedByString:@""];
    }
    
    // 如果获取的wifi地址跟摄像头wifi地址不一致，说明不在线
    if (![BSSID isEqualToString:[SettingConfig shareInstance].currentCameraModel.macAddress]) {
        [SettingConfig shareInstance].currentCameraModel = nil;
        [SettingConfig shareInstance].ip_url = nil;
        [self searchHost];
    }
    
}

#pragma mark ------------------ 获取wifi地址信息 ----------------------
/**
 获取wifi mac地址

 @return wifi地址信息
 */
- (id)getSSIDInfo  //引用
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info;
    
    /**
     {
     BSSID = "e0:b9:4d:6c:9d:d";
     SSID = "KAKA_C9D0D";
     SSIDDATA = <4b414b41 5f433944 3044>;
     }
     */
}

- (void)onApplicationWillResignActiveHandle
{
    [self releaseSearch];
}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UIImageView *)noCameraImageView {
    
    if (!_noCameraImageView) {
        _noCameraImageView = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_no_camera.png")];
        _noCameraImageView.center = CGPointMake(SCREEN_WIDTH / 2, (SCREEN_HEIGHT_4s - TABBARHEIGHT - NAVIGATIONBARHEIGHT) / 2);
    }
    
    return _noCameraImageView;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left);
            make.top.mas_equalTo(self.view.mas_top);
            make.right.mas_equalTo(self.view.mas_right);
            make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-30);
        }];
        _tableView.backgroundColor = RGBSTRING(@"f3f4f6");
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"Cell";
    
    CameraHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (!cell) {
        cell = [[CameraHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    
    cell.model = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 51 + 420 * PSDSCALE_Y;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CameraListModel *model = [self.dataSource objectAtIndex:indexPath.row];
    self.selectCameraListModel = model;
    [SettingConfig shareInstance].ip_url = nil;
    [SettingConfig shareInstance].currentCameraModel = nil;
    [SettingConfig shareInstance].deviceLoginToken = nil;
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    socketManager.asyncSocket.userData = SocketOfflineByUser;
    [socketManager disconnectSocket];
    
    if (!model.is_on_line) {
        // 离线直接进入
        CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
        cameraDetailVC.hidesBottomBarWhenPushed = YES;
        model.is_on_line = NO;
        cameraDetailVC.model = model;
        [self.navigationController pushViewController:cameraDetailVC animated:YES];
        return;
    }
    
    [self addActityLoading:@"正在登录" subTitle:nil];
    __weak typeof(socketManager) weakSocketManager = socketManager;
    __weak typeof(self) weakSelf = self;
    
    // 连接socket
    [self addActityLoading:nil subTitle:nil];
    [socketManager connectToHost:model.ipAddress onPort:12330 connectResult:^(NSString *connectResult) {
        
        weakSocketManager.asyncSocket.userData = SocketOfflineByServer;
        
        [self removeActityLoading];
        if ([connectResult isEqualToString:@"OK"]) {
            //连接成功 发送登录请求
            NSString *userName = [UserDefaults objectForKey:[NSString stringWithFormat:@"CameraUserName_%@",model.macAddress]];
            NSString *passwd = [UserDefaults objectForKey:[NSString stringWithFormat:@"CameraPassword_%@",model.macAddress]];
            if (userName == nil) {
                userName = DefaultUserName;
            }
            if (passwd == nil) {
                passwd = DefaultPWD;
            }
            // 登录摄像头
            [weakSelf loginCameraWithUserName:userName password:passwd model:model];
            
        } else {
            
            // 连接超时
            [self removeActityLoading];
            CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
            cameraDetailVC.hidesBottomBarWhenPushed = YES;
            model.is_on_line = NO;
            cameraDetailVC.model = model;
            [self.navigationController pushViewController:cameraDetailVC animated:YES];
        }
    }];
    
}

/**
 *  登录摄像头
 *
 *  @param userName 登录名
 *  @param password 登录密码
 */
- (void)loginCameraWithUserName:(NSString *)userName password:(NSString *)password model:(CameraListModel *)model{
    
    MsgModel * msg = [[MsgModel alloc]init];
    msg.cmdId = @"01";
    msg.msgSN = @"0001";
    msg.token = @"0000000000000000000000000000000000000000000000000000000000000000";
    
    NSString *msgBody = [NSString stringWithFormat:@"username:%@&passwd:%@", userName, password];
    msg.msgBody = msgBody;
    
    __weak typeof(self) weakSelf = self;
    
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    [socketManager sendData:msg receiveData:^(MsgModel *msg) {
        
        if ([msg.msgBody isEqualToString:@"LOGINERROR"]) {
            
            if (self.isUpload)
            {
                self.isUpload = NO;
                 [weakSelf loginCameraWithUserName:DefaultUserName password:DefaultPWD model:model];
            }
            else
            {
                // 用户名或密码错误 弹出输入框
                CameraLoginViewController *loginViewController = [[CameraLoginViewController alloc] init];
                loginViewController.hidesBottomBarWhenPushed = YES;
                loginViewController.model = weakSelf.selectCameraListModel;
                [weakSelf.navigationController pushViewController:loginViewController animated:YES];
            }
            
        } else {
            // 登录摄像头成功
            [SettingConfig shareInstance].currentCameraModel = model;
            [SettingConfig shareInstance].ip_url = model.ipAddress;
            [UserDefaults setObject:userName forKey:[NSString stringWithFormat:@"CameraUserName_%@",model.macAddress]];
            [UserDefaults setObject:password forKey:[NSString stringWithFormat:@"CameraPassword_%@",model.macAddress]];
            CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
            cameraDetailVC.hidesBottomBarWhenPushed = YES;
            cameraDetailVC.model = model;
            [self.navigationController pushViewController:cameraDetailVC animated:YES];
        }
    }];

}





/**
 *  登录出错时弹出登录名、密码输入框
 */
- (void)showUserNameAndPasswordInputAlertView {
    
    UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"登录摄像机" message:@"登录名或密码错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [inputAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];

    UITextField *nameField = [inputAlertView textFieldAtIndex:0];
    nameField.placeholder = @"请输入登录名";

    UITextField *pwdField = [inputAlertView textFieldAtIndex:1];
    [pwdField setSecureTextEntry:YES];
    pwdField.placeholder = @"请输入登录密码";

    [inputAlertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        // 点击了确定
        UITextField *nameField = [alertView textFieldAtIndex:0];
        if (nameField.text.length == 0) {
            [self addActityText:@"请输入登录名" deleyTime:1];
            return;
        }
        
        UITextField *pwdField = [alertView textFieldAtIndex:1];
        if (pwdField.text.length == 0) {
            [self addActityText:@"请输入登录密码" deleyTime:1];
            return;
        }
        
        // 登录
        [self loginCameraWithUserName:nameField.text password:pwdField.text model:self.selectCameraListModel];
    }
}

// 加载本地数据
- (void)loadLocateData {
    
    NSMutableArray *tempArr = [CacheTool queryCameraList];
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:tempArr];
}



#pragma mark -------------------- 发送广播 查找摄像头 --------------------------
/**
 查找摄像头
 */
-(void)searchHost {
    
    NSString *wifiName = [self getWifiName];
    NSString *wifiIP = [self getIPAddress];
    if (wifiIP.length > 12) {
        
        wifiIP = [[wifiIP substringWithRange:NSMakeRange(0, 12)] stringByAppendingString:@"255"];
    }
    
    ZYLog(@"wifiName = %@ , wifiIP = %@",wifiName,wifiIP);
    AsyncSocketManager *socketManager = [AsyncSocketManager sharedAsyncSocketManager];
    socketManager.asyncSocket.userData = SocketOfflineByUser;
    [socketManager disconnectSocket];
    
    MMLog(@"开始搜索");
    [search_camera removeAllObjects];
    
    [self.noCameraImageView removeFromSuperview];
    
    [self addActityLoading:nil subTitle:nil];
    
//    if (self.dataSource && self.dataSource.count > 0) {
//        [self.dataSource removeAllObjects];
//        [self.tableView reloadData];
//    }
    
    if ([endSearchTimer isValid]) {
        [endSearchTimer invalidate];
        endSearchTimer = nil;
    }
    
    // 设置定时器，2秒后结束搜索
    endSearchTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(endSearch:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:endSearchTimer forMode:NSRunLoopCommonModes];

    
    // 发送广播
    
    if ([wifiName containsString:@"KAKA"]) {
        
        [self sendBroadcastWithHost:wifiIP];//如果连接的是kaka的wifi,可以4G上网
        
    }else
    {
        [self sendBroadcastWithHost:@"255.255.255.255"];//
    
    }

}

- (void)sendBroadcastWithHost:(NSString *)host
{
    
    if (_udpManager) {
        [_udpManager closeUDPSocket];
        _udpManager = nil;
    }
    _udpManager = [[AsyncUdpSocketManager alloc] init];
    
    MsgModel * msg = [[MsgModel alloc] init];
    msg.token = @"0000000000000000000000000000000000000000000000000000000000000000";
    msg.cmdId = @"FF";
    
    __weak typeof(self) weakSelf = self;
    [_udpManager sendBroadcast:msg toHost:host port:12330 receiveData:^(MsgModel * msgModel, NSString *host, UInt16 port) {
        
        [weakSelf.noCameraImageView removeFromSuperview];
        if (msgModel) {
            // 搜索到摄像头 根据mac地址去数据库查找对应摄像头
            NSString *macAddress = [[msgModel.msgBody componentsSeparatedByString:@","] lastObject];
            CameraListModel *listModel = [CacheTool queryCameraWithMacAddress:macAddress];
            if (listModel == nil) {
                // 数据库中没有该摄像头
                listModel = [[CameraListModel alloc] init];
                listModel.macAddress = macAddress;
                listModel.ipAddress = [[msgModel.msgBody componentsSeparatedByString:@","] firstObject];
                listModel.name = @"未命名";
            } else {
                listModel.ipAddress = [[msgModel.msgBody componentsSeparatedByString:@","] firstObject];
            }
            
            // 摄像头添加时间，方便排序
            NSString *addTime = [MyTools getDateStringWithDateFormatter:@"yyyyMMddHHmmss" date:[NSDate date]];
            listModel.addTime = addTime;
            
            // 更新摄像头到数据库
            [CacheTool updateCameraListWithCameraListModel:listModel];
            // 搜索到的当前摄像头标记为在线
            listModel.is_on_line = YES;
            [search_camera addObject:listModel];
            [weakSelf addCameraListModel:listModel];
            
            [weakSelf.tableView reloadData];
        }
        
    }];
}


/**
 将搜索到的摄像头添加到摄像头列表，先根据mac地址查找当前列表有没有当前摄像头，如果有移除，并添加到最前面

 @param model 搜索到的摄像头
 */
- (void)addCameraListModel:(CameraListModel *)model {
    
    // 是否有相同
    BOOL hasSameFlag = NO;
    NSInteger sameIndex = 0;
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        CameraListModel *listModel = [self.dataSource objectAtIndex:i];
        
        if ([listModel.macAddress isEqualToString:model.macAddress]) {
            hasSameFlag = YES;
            sameIndex = i;
            //break;
        }
        listModel.is_on_line = NO;
    }
    
    if (hasSameFlag) {
        // 如果有，删除，再插入到最前面
        [self.dataSource removeObjectAtIndex:sameIndex];
    }
    // 将在线的摄像头插入到列表的前面
    [self.dataSource insertObject:model atIndex:0];
}


/**
 结束搜索定时器

 @param timer 定时器
 */
-(void)endSearch:(NSTimer *)timer {
    
    [timer invalidate];
    timer = nil;
    
    if (_udpManager) {
        [_udpManager closeUDPSocket];
        _udpManager = nil;
    }
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (search_camera.count == 0) {
        // 如果没搜索到摄像头，把当前列表中的所有摄像头标记为离线
        NSMutableArray *temp_arr = [self.dataSource mutableCopy];
        [self.dataSource removeAllObjects];
        for (CameraListModel *model in temp_arr)
        {
            model.is_on_line = NO;
            [self.dataSource addObject:model];
        }
        
        if (self.dataSource.count) {
            [self.tableView reloadData];
        } else {
            //[self addActityText:@"未搜索到摄像机" deleyTime:2];
            // 没有摄像头页面
            [self.view addSubview:self.noCameraImageView];
        }
    }
    
}


//获取WIFI名字的方法
- (NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

//获取WIFIIP的方法
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
@end
