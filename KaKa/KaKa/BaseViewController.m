//
//  BaseViewController.m
//  iMark
//
//  Created by wei_yijie on 15/10/16.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import "BaseViewController.h"
#import "UIButton+Clicked.h"
#import "MyTools.h"

@interface BaseViewController ()<UITextFieldDelegate>
{
    MBProgressHUD *hud;
    void(^cacheBlock)(UIButton *sender);
    void(^cacheBackBlock)(UIButton *sender);
}
@end

@implementation BaseViewController

- (void)dealloc
{
    // 移除通知
    [NotificationCenter removeObserver:self];
    MMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addStatusBlackBackground];
    
    if (IS_Phone4S) {
        self_view = [[UIScrollView alloc] initWithFrame:SCREEN_BOUNDS];
        ((UIScrollView *)self_view).contentSize = CGSizeMake(VIEW_W(self.view), 568);
        [self.view addSubview:self_view];
    }else{
        self_view = self.view;
    }
    
    // 注册网络通知
    [NotificationCenter addObserver:self selector:@selector(networkReachableAction:) name:NetWorkReachableNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 把当前显示的控制器记下来
    [SettingConfig shareInstance].currentViewController = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SettingConfig shareInstance].currentViewController = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 有网络发通知过来的时候 重新请求数据
- (void)networkReachableAction:(NSNotification *)notif
{
    BOOL isconnection = [notif.object boolValue];
    if (isconnection) {
        // 网络连接才更新数据
        [self updates];
    }
}
/**
 *  对网络进行监听，当监听到有网络时，可以重写该方法更新数据
 */
- (void)updates
{
    
}

/////////////////////////
//more write  more lazy
/////////////////////////

//增加状态栏颜色及默认背景
- (void)addStatusBlackBackground{
//    float statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusHeight, SCREEN_WIDTH, statusHeight+2)];
//    statusView.backgroundColor = RGBSTRING(@"29a6ff");
//    [self.navigationController.navigationBar addSubview:statusView];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    self.view.backgroundColor = RGBSTRING(@"f3f4f6");
}

//导航栏返回按钮
- (void)addBackButtonWith:(void(^)(UIButton *sender))block{
    cacheBackBlock = block;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [leftButton setImage:[UIImage imageNamed:@"me_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    [fixedSpace setWidth: -20];
    self.navigationItem.leftBarButtonItems = @[fixedSpace,leftButtonItem];
}

- (void)backButtonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if (cacheBackBlock) {
        cacheBackBlock(sender);
    }
}



//导航栏标题
- (void)addTitleWithName:(id )name wordNun:(int)num{
    if ([name isKindOfClass:[NSString class]]) {
        self.navigationItem.title = name;
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{
           NSFontAttributeName:[UIFont boldSystemFontOfSize:17],//字体20
           NSForegroundColorAttributeName:[UIColor whiteColor]  //颜色
           }
         ];
    }
    if ([name isKindOfClass:[UIImage class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 27/2*num, 23)];//初始化图片视图控件
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = name;
        self.navigationItem.titleView = imageView;//设置导航栏的titleView为imageView
    }
}
- (void)addTitle:(NSString *)name {
    if ([name isKindOfClass:[NSString class]]) {
        self.navigationItem.title = name;
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{
           NSFontAttributeName:[UIFont boldSystemFontOfSize:17],//字体
           NSForegroundColorAttributeName:[UIColor whiteColor]  //颜色
           }
         ];
    }
}

//文字提示框
- (void)addActityText:(NSString *)text deleyTime:(float)duration;
{
    [hud removeFromSuperview];
    hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = RGBACOLOR(102, 102, 102, 1);
    hud.label.text = text;
    hud.margin = 15;
    hud.bezelView.layer.cornerRadius = 3;
    [hud hideAnimated:YES afterDelay:duration];
}

//加载提示
- (void)addActityLoading:(NSString *)title subTitle:(NSString *)subTitle{
    [hud removeFromSuperview];
    hud = nil;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;//模式
    hud.bezelView.color = RGBACOLOR(102, 102, 102, 1);//颜色
    hud.label.text = title;
    hud.detailsLabel.text = subTitle;
    [self.view addSubview:hud];
}

- (void)removeActityLoading{
    [hud removeFromSuperview];
    hud = nil;
}

//导航栏右侧按钮
- (void)addRightButtonWithName:(id)name wordNum:(int)num actionBlock:(void (^)(UIButton *sender))clickedAction{
    cacheBlock = clickedAction;
    // 计算出每个字占用的宽
    NSString *fontStr = @"你";
    CGRect frame = [fontStr boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:NULL];
    CGFloat perFontWidth = frame.size.width+10;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, num*perFontWidth, 30)];
    if ([name isKindOfClass:[NSString class]]) {
        [rightButton setTitle:name forState:UIControlStateNormal];
    }
    if ([name isKindOfClass:[UIImage class]]) {
        [rightButton setImage:name forState:UIControlStateNormal];
    }
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}

- (void)rightButtonAction:(UIButton *)sender{
    if (cacheBlock) {
        cacheBlock(sender);
    }
}


//解析返回数据
- (void)resolveReturnData:(id)data ok_block:(void (^)(NSDictionary *resultDic))ok_block err_block:(void (^)(NSDictionary *resultDic))err_block{
    
    if (!data) {
        return;
    }
    NSDictionary *dic;
    if ([data isKindOfClass:[NSData class]]){
        dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }else{
        dic = data;
    }
    
    //NSString *retCode = FORMATSTRING(VALUEFORKEY(data, @"status"));
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        
        if ([FORMATSTRING(VALUEFORKEY(dic, @"errCode")) integerValue] == 0) {
            //成功返回解析数据
            ok_block(dic);
        }else{
            err_block(dic);
            if (DEBUGTAG) {
                //失败提示错误
                [self addActityText:VALUEFORKEY(dic, @"errMsg") deleyTime:1];
            }
        }
    }else{
        [self addActityText:@"数据解析错误" deleyTime:1];
    }
}

#pragma mark 初始化UITextField
/**
 *  初始化文本输入框
 *
 *  @param frame         视图范围
 *  @param sizefont      字体大小
 *  @param backgroundObj 背景（UIImage或UIColor）
 *  @param keyBoardType  键盘类型
 *  @param placeholder   占位符
 *  @param secure        是否加密
 *  @param placeholdFont 占位符字体大小
 *  @param placehodlColor占位符字体颜色
 *  @param view          父视图
 *
 *  @return 初始化的输入框
 */
- (UITextField *)textFieldWithFrame:(CGRect)frame
                           sizeFont:(CGFloat)sizefont
                         background:(id)backgroundObj
                       keyBoardType:(NSInteger)keyBoardType
                        placeholder:(NSString *)placeholder
                      placeholdFont:(CGFloat)pSizeFont
                     placehodlColor:(UIColor*)pColor
                             secure:(BOOL)secure
                             inView:(UIView *)view{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    //如果背景是一张图片，在下边插入一张图片
    if (backgroundObj && [backgroundObj isKindOfClass:[UIImage class]]) {
        UIImageView *bgPic = [[UIImageView alloc] initWithFrame:frame];
        bgPic.image = backgroundObj;
        [view insertSubview:bgPic atIndex:0];
        textField.backgroundColor = RGBACOLOR(0, 0, 0, 0.1);
    }
    //如果背景是颜色，设置背景颜色
    else if (backgroundObj && [backgroundObj isKindOfClass:[UIColor class]]) {
        textField.backgroundColor = backgroundObj;
    }
    //如果背景是视图，设置背景视图
    else if (backgroundObj && [backgroundObj isKindOfClass:[UIView class]]) {
        UIView *tempView = backgroundObj;
        tempView.frame = textField.frame;
        if (view) {
            [view insertSubview:tempView belowSubview:textField];
        }
    }
    textField.keyboardType = keyBoardType;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.font = [UIFont systemFontOfSize:sizefont];
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = secure;
    
    if (placeholder && pColor) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:placeholder];
        [attr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:pSizeFont],NSForegroundColorAttributeName:pColor} range:NSMakeRange(0, placeholder.length)];
        textField.attributedPlaceholder = attr;
    }
    
    if (view) {
        [view addSubview:textField];
    }
    
    return textField;
    
}

#pragma mark 初始化Label
- (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor textFont:(CGFloat)textSize text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:textSize];
    label.text = text;
    return label;
}

- (UILabel *)labelWithFrame:(CGRect)frame inView:(UIView *)view textColor:(UIColor *)color fontSize:(CGFloat)fontSize text:(NSString *)text alignment:(NSTextAlignment)alignment bold:(BOOL)bold fit:(BOOL)fit{
    if (!text) {
        text = @"";
    }
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = RGBSTRING(@"4e4e4e");
    label.font = [UIFont systemFontOfSize:24*PSDSCALE_X];
    label.text = text;
    label.textAlignment = NSTextAlignmentLeft;
    if (alignment) {
        label.textAlignment = alignment;
    }
    if (color) {
        label.textColor = color;
    }
    if (bold) {
        label.font = [UIFont boldSystemFontOfSize:fontSize];
    }else{
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    if (fit) {
        label.frame = CGRectMake(frame.origin.x, frame.origin.y + 2, frame.size.width, frame.size.height);
        label.numberOfLines = 0;
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:label.textAlignment];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
        [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, [text length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:label.textColor range:NSMakeRange(0, [text length])];
        [label setAttributedText:attributedString];
        [label sizeToFit];
    }
    if (view) {
        [view addSubview:label];
    }
    
    return label;
}
#pragma mark 初始化UIImageView
- (UIImageView *)imageViewWithFrame:(CGRect)frame inView:(UIView *)view image:(id)image contentMode:(id)mode backgroundColor:(id)backgroundColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)width borderColor:(id)borderColor{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    if (image && [image isKindOfClass:[UIImage class]]) {
        imageView.image = image;
    }
    if (image && [image isKindOfClass:[NSString class]]) {
        //[imageView sd_setImageWithURL:[NSURL URLWithString:FORMATSTRING(image)]];
    }
    if (mode) {
        imageView.contentMode = (UIViewContentMode)mode;
    }
    if (backgroundColor && [backgroundColor isKindOfClass:[UIColor class]]) {
        imageView.backgroundColor = backgroundColor;
    }
    if (cornerRadius > 0) {
        imageView.layer.cornerRadius = cornerRadius;
        imageView.layer.masksToBounds = YES;
    }
    if (width > 0) {
        imageView.layer.borderWidth = width;
    }
    if (borderColor && [borderColor isKindOfClass:[UIColor class]]) {
        imageView.layer.borderColor = ((UIColor *)borderColor).CGColor;
    }
    [view addSubview:imageView];
    
    return imageView;
    
}

#pragma mark 初始化UIButton

/**
 *  初始化按钮
 *
 *  @param frame              视图区域
 *  @param view               父视图
 *  @param title              标题
 *  @param normalColor        正常标题颜色
 *  @param selectedColor      选中标题颜色
 *  @param fontSize           标题大小
 *  @param normalBackground   正常状态背景图片或颜色
 *  @param selectedBackground 选中状态背景图片或颜色
 *  @param cornerRadius       圆角大小
 *  @param borderWidth        边框宽度
 *  @param borderColor        边框颜色
 *  @param block              点击事件
 *
 *  @return 初始化后的按钮
 */
- (UIButton *)buttonWithFrame:(CGRect)frame
                       inView:(UIView *)view
                        title:(NSString *)title
             titleColorNormal:(UIColor *)normalColor
           titleColorSelected:(UIColor *)selectedColor
                titleFontSize:(CGFloat)fontSize
             backgroundNormal:(id)normalBackground
           backgroundSelected:(id)selectedBackground
                 cornerRadius:(CGFloat)cornerRadius
                  borderWidth:(CGFloat)borderWidth
                  borderColor:(id)borderColor
                        block:(void (^)(UIButton *sender))block{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    if ([normalBackground isKindOfClass:[UIImage class]]) {
        [button setBackgroundImage:normalBackground forState:UIControlStateNormal];
    }
    if ([selectedBackground isKindOfClass:[UIImage class]]) {
        [button setBackgroundImage:selectedBackground forState:UIControlStateSelected];
    }
    if ([normalBackground isKindOfClass:[UIColor class]]) {
        [button setBackgroundColor:normalBackground];
        [button setBackgroundColor:normalBackground forState:UIControlStateNormal];
    }
    if ([selectedBackground isKindOfClass:[UIColor class]]) {
        [button setBackgroundColor:normalBackground];
        [button setBackgroundColor:selectedBackground forState:UIControlStateSelected];
    }
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (normalColor) {
        [button setTitleColor:normalColor forState:UIControlStateNormal];
    }
    if (selectedColor) {
        [button setTitleColor:selectedColor forState:UIControlStateSelected];
    }
    if (fontSize) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    if (cornerRadius) {
        button.layer.cornerRadius = cornerRadius;
    }
    if (borderWidth) {
        button.layer.borderWidth = borderWidth;
        button.layer.borderColor = ((UIColor *)borderColor).CGColor;
    }
    __weak UIButton *weakbutton = button;
    [button addTargetWithBlock:^(UIButton *sender) {
        block(weakbutton);
    }];
    if (view) {
        [view addSubview:button];
    }
    return button;
}

/**
 *  初始化视图
 *
 *  @param frame        视图区域
 *  @param view         父视图
 *  @param color        背景色
 *  @param cornerRadius 圆角大小
 *
 *  @return 初始化的视图
 */
- (UIView *)viewWithFrame:(CGRect)frame inView:(UIView *)view backgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius{
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    if (color) {
        tempView.backgroundColor = color;
    }
    tempView.layer.cornerRadius = cornerRadius;
    if (view) {
        [view addSubview:tempView];
    }
    return tempView;
}

//验证身份证号码
-(BOOL)checkIdentityCardNo:(NSString*)cardNo
{
    if (cardNo.length != 18) {
        return  NO;
    }
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[cardNo substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[cardNo substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[cardNo substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
}

- (void)addTapGesture:(NSString *)className clickBlock:(void(^)(UIButton *sender))clickBlock{
    __block void(^cacheTempBlock)(UIButton *) = clickBlock;
    __weak typeof(self) weakself = self;
    UIViewController *next = [[NSClassFromString(className) alloc] init];
    [self buttonWithFrame:self.view.frame inView:self.view title:0 titleColorNormal:0 titleColorSelected:0 titleFontSize:0 backgroundNormal:0 backgroundSelected:0 cornerRadius:0 borderWidth:0 borderColor:0 block:^(UIButton *sender) {
        if (next) {
            if (sender && cacheTempBlock) {
                cacheTempBlock(sender);
            }else{
                [weakself.navigationController pushViewController:next animated:YES];
            }
        }
    }];
}


/**
 *  校验手机号码
 *
 *  @param phone 手机号
 *
 *  @return 结果
 */
- (BOOL)checkPhoneNumber:(NSString *)phone{
    NSString *phoneRegex = @"^1[3578]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    BOOL isPhone = [phoneTest evaluateWithObject:phone];
    
    return isPhone;
}

/**
 *  验证邮编
 *
 */
- (BOOL) isValidZipcode:(NSString*)value
{
    const char *cvalue = [value UTF8String];
    unsigned long len = strlen(cvalue);
    if (len != 6) {
        return NO;
    }
    for (int i = 0; i < len; i++)
    {
        if (!(cvalue[i] >= '0' && cvalue[i] <= '9'))
        {
            return NO;
        }
    }
    return YES;
}

/** 隐藏tableview多余的线 */
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    
    [tableView setTableFooterView:view];
}

/**
 *  将图片压缩到某个大小以下
 *
 *  @param image       待压缩的图片
 *  @param maxFileSize 压缩到多少多少以下
 *
 *  @return 压缩的图片
 */
- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

- (NSString *)cyclePhoto_PathChangeCycleVideo_Path:(NSString *)cyclePhoto_Path
{
    cyclePhoto_Path = [cyclePhoto_Path componentsSeparatedByString:@"/"].lastObject;
    cyclePhoto_Path = [cyclePhoto_Path componentsSeparatedByString:@"."][0];
    cyclePhoto_Path = [cyclePhoto_Path stringByAppendingString:@".MP4"];
    NSArray *pathArr =[MyTools getAllDataWithPath:CycleVideo_Path(nil) mac_adr:nil];
    
    for (NSString *str in pathArr)
    {
        
        if ([str containsString:cyclePhoto_Path])
        {
            cyclePhoto_Path = str;
            break;
        }
    }
    return cyclePhoto_Path;
}

@end
