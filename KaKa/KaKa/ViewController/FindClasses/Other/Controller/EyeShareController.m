//
//  EyeShareController.m
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeShareController.h"


@interface EyeShareController ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>



/** 定位服务  */
@property (nonatomic,strong) BMKLocationService *locService;
/** geo搜索服务  */
@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;



///** 更换封面按钮 */
//@property (nonatomic, weak) UIButton *changeCovImageBtn;

@end

@implementation EyeShareController

-(instancetype)init
{
    if (self == [super init]) {
        // 初始化控件
        [self setupContentView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏

    [self setupNav];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    //启动LocationService
    [_locService startUserLocationService];
    _locService.distanceFilter = 10.0;
    _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.locService.delegate = self;
    _geoCodeSearch.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil; // 不用时，置nil
}


/**
 *  设置导航栏
 */
- (void)setupNav
{
    self.view.backgroundColor = ZYGlobalBgColor;
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setImage:[UIImage imageNamed:@"find_back"] forState:UIControlStateNormal];
//    
//    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [btn sizeToFit];
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    //    self.hidesBottomBarWhenPushed = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(checkBtnClick)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                     } forState:UIControlStateNormal];

}


#pragma mark -- BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    ZYLog(@"didUpdateBMKUserLocation");
    
    
    self.addressModel.coordinate = userLocation.location.coordinate;
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        ZYLog(@"反geo检索发送成功");
    }
    else
    {
        ZYLog(@"反geo检索发送失败");
    }

    
    
    
    //关闭定位服务
    [self.locService stopUserLocationService];
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    [self.addressBtn setTitle:result.address forState:UIControlStateNormal];
    
    [self.addressBtn sizeToFit];

    self.addressModel.address = result.address;
}

#pragma mark -- 按钮点击事件

- (void)addressBtnClick:(UIButton *)btn
{
    
    ZYLog(@"addressBtnClick");
}


- (void)changCovImageBtnClick:(UIButton *)button
{
    ZYLog(@"点击更换封面");
    
}

- (void)shareButtonClick:(UIButton *)button
{

    ZYLog(@"点击分享");
}


- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkBtnClick
{
    ZYLog(@"点击查看");
}
/**
 *  初始化控件
 */
- (void)setupContentView
{
    
    // 写心情
    [self textView];
    
    
    // 更换地址按钮
    [self addressBtn];
    
    //封面
    [self coverImageView];
   
    
   
//    CGFloat margin = 10;
//    // 分享到微信，盆友圈平台
//    UIView *friendView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.coverImageView.frame) + 10, self.view.width, 50)];
//    friendView.backgroundColor = [UIColor whiteColor];
//    
//    UILabel *shareLabel = [[UILabel alloc] init];
//    shareLabel.text = @"是否分享到：";
//    shareLabel.font = [UIFont systemFontOfSize:15];
//    shareLabel.textColor = [UIColor grayColor];
//    [shareLabel sizeToFit];
//    shareLabel.x = margin;
//    shareLabel.y = (friendView.height - shareLabel.height) * 0.5;
//    [friendView addSubview:shareLabel];
//    //新浪按钮
//    UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sinaBtn setImage:[UIImage imageNamed:@"find_share_sina"] forState:UIControlStateNormal];
//    [sinaBtn setImage:[UIImage imageNamed:@"find_share_sina_Highlight"] forState:UIControlStateHighlighted];
//    [sinaBtn sizeToFit];
//    sinaBtn.x = friendView.width - sinaBtn.width - 2 * margin;
//    sinaBtn.y = shareLabel.y;
//    [friendView addSubview:sinaBtn];
//    //朋友圈按钮
//    UIButton *tencentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [tencentBtn setImage:[UIImage imageNamed:@"find_share_frends"] forState:UIControlStateNormal];
//    [tencentBtn setImage:[UIImage imageNamed:@"find_share_frend_Highlight"] forState:UIControlStateHighlighted];
//    [tencentBtn sizeToFit];
//    tencentBtn.x = sinaBtn.x - 2 * margin - tencentBtn.width;
//    tencentBtn.y = sinaBtn.y;
//    [friendView addSubview:tencentBtn];
//    [self.view addSubview:friendView];
    
    // 分享按钮
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
    
    [shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@49);
        
    }];

    // 更换封面按钮
    UIButton *changCovImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changCovImageBtn setBackgroundImage:[UIImage imageNamed:@"find_share_changeCover"] forState:UIControlStateNormal];
    [changCovImageBtn addTarget:self action:@selector(changCovImageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [changCovImageBtn sizeToFit];
    [self.view addSubview:changCovImageBtn];
    
    [changCovImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self.coverImageView);
        make.bottom.equalTo(self.coverImageView.mas_bottom).offset(-10);
        
    }];
    
    _changeCovImageBtn = changCovImageBtn;
}





#pragma mark -- property

-(EyeTextView *)textView
{
    if (!_textView) {
        
        CGFloat margin = 10;
        EyeTextView *textView = [[EyeTextView alloc] initWithFrame:CGRectMake(margin, margin, self.view.width - 2 * margin, 200 * PSDSCALE_Y)];
        textView.placeholder = @"写上您的心情吧.....";
        [self.view addSubview:textView];
        _textView = textView;
        
    }
    
    return _textView;
}


-(UIButton *)addressBtn
{
    if (!_addressBtn) {
        UIButton *addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addressBtn setBackgroundImage:[UIImage resizeImage:@"bg_location(1)"] forState:UIControlStateNormal];
        [addressBtn setImage:[UIImage imageNamed:@"ic_location(1)"] forState:UIControlStateNormal];
        [addressBtn setTitle:@"点击刷新" forState:UIControlStateNormal];
        [addressBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        addressBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        addressBtn.x = self.textView.x;
        addressBtn.y = CGRectGetMaxY(self.textView.frame) + 10;
        [addressBtn sizeToFit];
//        addressBtn.height = 35;
        
        [addressBtn addTarget:self action:@selector(addressBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:addressBtn];
        
        _addressBtn = addressBtn ;

    }
    
    return _addressBtn;
}

-(UIImageView *)coverImageView
{
    if (!_coverImageView) {
        CGFloat coverImageViewX = 0;
        CGFloat coverImageViewY = CGRectGetMaxY(self.addressBtn.frame) + 10;
        CGFloat coverImageViewW = self.view.width;
        CGFloat coverImageViewH = self.view.width * 9/16;
        
        UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(coverImageViewX, coverImageViewY, coverImageViewW, coverImageViewH)];
        
        //    coverImageView.image = [UIImage imageNamed:@"img_02"];
        [self.view addSubview:coverImageView];
        _coverImageView = coverImageView;
        _coverImageView.userInteractionEnabled = YES;
    }
    
    return _coverImageView;
}


-(EyeAddressModel *)addressModel
{
    if (!_addressModel) {
       
        _addressModel = [[EyeAddressModel alloc] init];
    }
    
    return _addressModel;
}

#pragma mark -----Other
- (NSString *)cutStringTill25:(NSString *)text
{
    NSInteger count = [self GetStringCharSize:text];
    
    if (count > 25) {
        NSString *subStr = [text substringToIndex:25];
        ZYLog(@"subStr = %lu",[self GetStringCharSize:subStr]);
        return subStr;
    }
    return text;
}

- (NSInteger)GetStringCharSize:(NSString*)argString
{
    NSInteger strlength = 0;
    char* p = (char*)[argString cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[argString lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p)
        {
            p++;
            strlength++;
        }
        else
        {
            p++;
        }
    }
    return (strlength+1)/2;
}
@end

