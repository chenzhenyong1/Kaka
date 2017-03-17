
//
//  GetImage.m
//  PuBar
//
//  Created by showsoft on 15-7-2.
//  Copyright (c) 2015年 秀软. All rights reserved.
//

#import "Header.h"

//系统版本
#define DEVICE_VERSION  [[UIDevice currentDevice].systemVersion floatValue]

@implementation Header


+ (UIImage *)getTheImageNoCache:(NSString *)name{
    UIImage *image = [UIImage imageNamed:name];
    return image;
//    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name]];
//    if (image) {
//        return image;
//    }else{
//        name = [NSString stringWithFormat:@"%@@3x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
//        if (ISIOS7) {
//            name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
//        }
//        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name]];
//        if (image) {
//            return image;
//        }else{
//            name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
//            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name]];
//            if (image) {
//                return image;
//            }else{
//                return nil;
//            }
//        }
//    }
}

+ (UIImage *)getTheImageWithCache:(NSString *)name{
    UIImage *image = [UIImage imageNamed:name];
    return image;
//    if (image) {
//        return image;
//    }else{
//        NSArray *format = [name componentsSeparatedByString:@"."];
//        NSString *formatStr = @"png";
//        if (format && [format isKindOfClass:[NSArray class]] && format.count > 1) {
//            formatStr = [name componentsSeparatedByString:@"."][1];
//        }
//        name = [NSString stringWithFormat:@"%@@3x.%@",[name componentsSeparatedByString:@"."][0],formatStr];
//        if (ISIOS7) {
//            name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],formatStr];
//        }
//        image = [UIImage imageNamed:name];
//        if (image) {
//            return image;
//        }else{
//            name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],formatStr];
//            image = [UIImage imageNamed:name];
//            if (image) {
//                return image;
//            }else{
//                return nil;
//            }
//        }
//    }
}

+ (UIImage *)getTheOriginalImage:(NSString *)name{
    UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (image) {
        return image;
    }else{
        if ([name componentsSeparatedByString:@"."].count == 2) {
            name = [NSString stringWithFormat:@"%@@3x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
            if (ISIOS7) {
                name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
            }
            image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            if (image) {
                return image;
            }else{
                name = [NSString stringWithFormat:@"%@@2x.%@",[name componentsSeparatedByString:@"."][0],[name componentsSeparatedByString:@"."][1]];
                image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                if (image) {
                    return image;
                }else{
                    return nil;
                }
            }
        }else{
            return nil;
        }
    }
}



+ (CGRect)getFrameWithX:(CGFloat)X Y:(CGFloat)Y Width:(CGFloat)width Height:(CGFloat)height
{
    CGRect frame;
    
    frame = CGRectMake(X*[Header getScaleX], Y*[Header getScaleY], width*[Header getScaleX], height*[Header getScaleY]);
    
    return frame;
}

+ (CGFloat)getScaleX
{
    CGFloat X;
    
    if (IS_Phone6_Plus)
    {
        X = 414/320.f;
    }
    else if (IS_Phone6)
    {
        X = 375/320.f;
    }
    else
    {
        X = 1.0;
        
    }
    return X;
    
    
}

+ (CGFloat)getScaleY
{
    CGFloat Y;
    
    if (IS_Phone6_Plus)
    {
        Y = 736/568.f;
    }
    else if (IS_Phone6)
    {
        Y = 667/568.f;
    }else
    {
        Y = 1.0;
    }
    return Y;
}
+ (CGFloat)fontScaleY
{
    CGFloat Y;
    
    if (IS_Phone6_Plus)
    {
        Y = 736/568.f;
    }
    else if (IS_Phone6)
    {
        Y = 1;//667/568.f;
    }else
    {
        Y = 1;//667/568.f;
    }
    return Y;
}

+ (CGFloat)irScaleX{
    CGFloat X;
    if (IS_Phone6_Plus)
    {
        X = 1.0;
    }
    else if (IS_Phone6)
    {
        X = 320/375.f;
    }
    else
    {
        X = 320/414.f;
    }
    return X;
}

+ (CGFloat)irScaleY{
    CGFloat X;
    if (IS_Phone6_Plus)
    {
        X = 1.0;
    }
    else if (IS_Phone6)
    {
        X = 320/375.f;
    }
    else
    {
        X = 320/414.f;
    }
    return X;
}

+ (NSString *)getUserPathWithMac_addr:(NSString *)mac_adr
{
    NSString *path;
    if (mac_adr.length)
    {
        path = [CACHE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",UserName,mac_adr]];
    }
    else
    {
        path = [CACHE_PATH stringByAppendingPathComponent:UserName];
    }
    return path;
}

//获取内容label
+ (CGSize)getContentHightWithContent:(NSString *)content font:(UIFont *)font constraint:(CGSize)constraint
{
    
    CGSize size ;
    
    size = [content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
    return  size;
}
+ (NSString *)formateString:(id)object{
    if (object == nil || object == NULL || [object isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return  [NSString stringWithFormat:@"%@",object];
}

+ (void)generyallyAnimationWithView:(UIView *)animationView animationType:(GenerallyAnimationEnum)animationType duration:(float)animationTime delayTime:(float)delayTime finishedBlock: (void (^)(void))completion{
    CGRect oriFrame = animationView.frame;
    CGRect lastFrame = oriFrame;
    UIView *fatherView = animationView.superview;
    CGRect fatherFrame = fatherView.frame;
    float fallValue = 1.0 ;
    float viewAlphaValue = 1.0;
    UIImageView *converView = [[UIImageView alloc]initWithFrame:animationView.bounds];
    converView.backgroundColor = [UIColor redColor];
    CGRect converFrame = converView.bounds ;
    CGRect converBounds = converFrame;
    
    switch (animationType) {
        case GenerallyAnimationSliderFormTop:
            animationView.alpha = 0 ;
            lastFrame.origin.y = -1 * (oriFrame.size.height);
            break;
        case GenerallyAnimationSliderToTop:
            oriFrame.origin.y = -1 *(oriFrame.size.height);
            break;
        case GenerallyAnimationSliderFormBottom:
            animationView.alpha = 0 ;
            lastFrame.origin.y = fatherFrame.size.height ;
            break;
        case GenerallyAnimationSliderToBottom:
            oriFrame.origin.y = fatherFrame.size.height ;
            break;
        case GenerallyAnimationSliderFormLeft:
            animationView.alpha = 0 ;
            lastFrame.origin.x = -1 * (oriFrame.size.width) ;
            break;
        case GenerallyAnimationSliderToLeft:
            oriFrame.origin.x = -1 *(oriFrame.size.width);
            break;
        case GenerallyAnimationSliderFormRight:
            animationView.alpha = 0 ;
            lastFrame.origin.x = fatherFrame.size.width;
            break;
        case GenerallyAnimationSliderToRight:
            oriFrame.origin.x = oriFrame.size.width ;
            break;
        case GenerallyAnimationFallIn:
            animationView.alpha = 0 ;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 1.5, 1.5);
            break;
        case GenerallyAnimationFallOut:
            animationView.alpha = 1 ;
            fallValue = 2.0 ;
            viewAlphaValue = 0.0 ;
            break;
        case GenerallyAnimationPopIn:
            viewAlphaValue = 0.0 ;
            fallValue = 0.1 ;
            oriFrame.origin.x = 512 - 50 ;
            oriFrame.origin.y = 768/2 - 50 ;
            oriFrame.size = CGSizeMake(100, 100);
            break;
        case GenerallyAnimationPopOut:
            animationView.alpha = 0 ;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 0.1, 0.1);
            //            lastFrame = CGRectMake(oriFrame.origin.x + oriFrame.size.width/2 - 10, oriFrame.origin.y + oriFrame.size.height/2 - 10, 20, 20);
            viewAlphaValue = 1.0 ;
            fallValue = 1.0 ;
            break;
        case GenerallyAnimationFallSliderFormLeft:
            animationView.alpha = 0 ;
            lastFrame.size.width = 1 ;
            lastFrame.origin.y -= 10;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 1.5, 1.5);
            break;
        case GenerallyAnimationFallSliderFormRight:
            animationView.alpha = 0 ;
            lastFrame.size.width = 1 ;
            lastFrame.origin.x += oriFrame.size.width - 1 ;
            lastFrame.origin.y -= 15;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 1.5, 1.5);
            break;
        case GenerallyAnimationFallSliderFormTop:
            animationView.alpha = 0 ;
            lastFrame.size.height = 1 ;
            lastFrame.size.width = 1 ;
            lastFrame.origin.x -= 10 ;
            lastFrame.origin.y -= 10 ;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 1.5, 1.5);
            break;
        case GenerallyAnimationFallSliderFormBottom:
            animationView.alpha = 0 ;
            lastFrame.size.width = 1 ;
            lastFrame.size.height = 1 ;
            lastFrame.origin.x -= 10 ;
            lastFrame.origin.y += oriFrame.size.height - 1 ;
            lastFrame.origin.y -= 10 ;
            animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), 1.5, 1.5);
            break;
        case GenerallyAnimationConverLayerFormLeft:
            converFrame.origin.x -= converFrame.size.width ;
            animationView.alpha = 1 ;
            converView.frame = converFrame ;
            [animationView.layer setMask:converView.layer];
            break;
        case GenerallyAnimationConverLayerFormRight:
            converFrame.origin.x = converFrame.size.width ;
            animationView.alpha = 1 ;
            converView.frame = converFrame ;
            [animationView.layer setMask:converView.layer];
            break;
        case GenerallyAnimationConverLayerFormTop:
            converFrame.origin.y -= converFrame.size.height ;
            animationView.alpha = 1 ;
            converView.frame = converFrame ;
            [animationView.layer setMask:converView.layer];
            break;
        case GenerallyAnimationConverLayerFormBottom:
            converFrame.origin.y = converFrame.size.height ;
            animationView.alpha = 1 ;
            converView.frame = converFrame ;
            [animationView.layer setMask:converView.layer];
            break;
        case GenerallyAnimationConverLayerFormCenter:
            
            converView.image = GETNCIMAGE(@"CircleLayerImage.png");
            converView.backgroundColor = [UIColor clearColor];
            converFrame.origin.x = converFrame.size.width / 2 - 1 ;
            converFrame.origin.y = converFrame.size.height / 2 - 1 ;
            converFrame.size = CGSizeMake(2, 2);
            converView.frame = converFrame ;
            [animationView.layer setMask:converView.layer];
            animationView.alpha = 0 ;
            
            converFrame = converBounds;
            converBounds = CGRectMake(-50, -50, converFrame.size.width+100, converFrame.size.height+100);
            
            viewAlphaValue = 1 ;
            break;
        case GenerallyAnimationFadeIn:
            animationView.alpha = 0 ;
            viewAlphaValue = 1 ;
            break;
        case GenerallyAnimationFadeOut:
            animationView.alpha = 1 ;
            viewAlphaValue = 0 ;
            break;
        default:
            break;
    }
    switch (animationType) {
        case GenerallyAnimationFallIn:
        case GenerallyAnimationPopOut:
            
            break;
            
        default:
            animationView.frame = lastFrame ;
            break;
    }
    
    [UIView animateWithDuration:animationTime delay:delayTime options:UIViewAnimationOptionCurveLinear animations:^{
        animationView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.0), fallValue, fallValue);
        animationView.frame = oriFrame ;
        animationView.alpha = viewAlphaValue ;
        
        converView.frame = converBounds ;
    }completion:^(BOOL finshed){
        if( finshed ){
            [converView removeFromSuperview];
            
            if( completion ){
                completion();
            }
        }
    }];
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


+ (NSString *)DicValueForKey:(NSDictionary *)dic key:(NSString *)key{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        if ([[dic allKeys] containsObject:key]) {
            return [dic objectForKey:key];
        }else{
            NSLog(@"dictionary：%@ without key:%@ !",dic,key);
                    if (DEBUGTAG) {
                        return key;
                    }else{
                        return @"";
                    }
        }
    }else{
        NSLog(@"dic is no NSDictionary class");
        return @"";
    }
}

//+ (NSString *)updateLanguage{
//    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",language] ofType:@"lproj"];
//    
//    
//    [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]
//}

#pragma mark- 加载动画
+ (UIImageView *)gifAnimationWithView:(UIView *)view{
    view.backgroundColor = [UIColor whiteColor];
    //加载
    float loc_number = 0.5;
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=10; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"people_%zd", i]];
        [idleImages addObject:image];
    }
    
    UIImageView *loadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 58)];
    loadView.center = CGPointMake(VIEW_W(view)/2, VIEW_H(view)/2);
    loadView.animationImages = idleImages;
    loadView.animationDuration = loc_number;
    [loadView startAnimating];
    loadView.backgroundColor = [UIColor redColor];
    [view addSubview:loadView];
    
    UILabel *loc_lable = [[UILabel alloc] initWithFrame:CGRectMake(-VIEW_X(loadView), VIEW_H(loadView), SCREEN_WIDTH, 30*GETSCALE_X)];
    loc_lable.text = MMLocalizedString(@"NEWS_MJ_HEARD_Refreshing", @"狂奔加载中...");
    loc_lable.textColor = RGBACOLOR(40, 139, 221, 1);
    loc_lable.font = [UIFont systemFontOfSize:14.f*GETSCALE_X];
    [loadView addSubview:loc_lable];
    loc_lable.textAlignment = NSTextAlignmentCenter;
    
    return loadView;
}

+ (void)gifRemoveAnimationWithView:(UIImageView *)loadView{
    if (loadView) {
        [loadView stopAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            loadView.alpha = 0;
        } completion:^(BOOL finished) {
            [loadView removeFromSuperview];
        }];
        loadView = nil;
    }
}

+ (NSString *)thousandsSeparatorString:(NSString *)string{
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString;
    if ([string containsString:@"."]) {
        numberString = [numberFormatter stringFromNumber: [NSNumber numberWithFloat:[string floatValue]]];
    }else{
        numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger:[string integerValue]]];
    }
    return numberString;
}

+ (NSString *)getNowTime:(NSString *)date_format{
    //当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:date_format];
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSString *)getDateWithTimestamp:(NSTimeInterval)time format:(NSString *)date_format{
    //后台偶尔会搞13位的时间戳
    if ([NSString stringWithFormat:@"%ld",(long)time].length == 13) {
        time = time/1000.0;
    }
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:date_format];
    return [formatter stringFromDate:date];
}

+ (NSString *)formateDataWith:(NSDate *)date formate:(NSString *)fromate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fromate];
    return [formatter stringFromDate:date];
}

+ (void)rockView:(UIView *)view{
    CGFloat rate = 0.1;
    [UIView animateWithDuration:rate animations:^{
        view.transform = CGAffineTransformMakeTranslation(3, 0);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:rate animations:^{
            view.transform = CGAffineTransformMakeTranslation(-3, 0);
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*rate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:rate animations:^{
            view.transform = CGAffineTransformMakeTranslation(3, 0);
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*rate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:rate animations:^{
            view.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    });
}

+ (BOOL)isEnglish{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [[[NSLocale preferredLanguages] firstObject] containsString:@"en"];
    }else{
        NSString *lan_str = [[NSLocale preferredLanguages] firstObject];
        if([lan_str rangeOfString:@"en"].location !=NSNotFound)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

+ (CGFloat)screenHeight{
    if(!IS_Phone4S){
        return [[UIScreen mainScreen] bounds].size.height;
    }else{
        return 568;
    }
}

#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (NSMutableAttributedString *)setTheLineSpacing:(NSString *)title lineSpacing:(CGFloat)space color:(UIColor *)color font:(CGFloat )fontSize{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    [attributedString addAttributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, [title length])];
    return attributedString;
}

+ (NSMutableAttributedString *)getAttributedString:(NSString *)title lineSpacing:(CGFloat)space color:(UIColor *)color font:(CGFloat )fontSize range:(NSRange)range{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    [attributedString addAttributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle} range:range];
    return attributedString;
}

+ (NSMutableAttributedString *)getAttributedString:(NSString *)title lineSpacing:(CGFloat)space attrs:(NSArray *)attrs{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    for (int i = 0; i < attrs.count; i++) {
        NSArray *attr = attrs[i];
        if (i == attrs.count - 1) {
            [attributedString addAttributes:@{NSForegroundColorAttributeName:attr[0], NSFontAttributeName:[UIFont systemFontOfSize:[attr[1] floatValue]],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange([attr[2] rangeValue].location, title.length - [attr[2] rangeValue].location)];
        }else{
            [attributedString addAttributes:@{NSForegroundColorAttributeName:attr[0], NSFontAttributeName:[UIFont systemFontOfSize:[attr[1] floatValue]],NSParagraphStyleAttributeName:paragraphStyle} range:[attr[2] rangeValue]];
        }
    }
    return attributedString;
}

+ (NSString *)getVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getBuild{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (id)getObjcAtIndex:(NSUInteger)index array:(NSArray *)array{
    if (array && [array isKindOfClass:[NSArray class]] && array.count > index) {
        return [array objectAtIndex:index];
    }else{
        return nil;
    }
}

//截取当前View成为图片
+ (UIImage *)getViewToImage:(UIView *)view
{
    CGRect rect = view.frame;  //截取图片大小
    
    //开始取图，参数：截图图片大小
    UIGraphicsBeginImageContext(rect.size);
    //截图层放入上下文中
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //从上下文中获得图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束截图
    UIGraphicsEndImageContext();
    return image;
}

// 根据颜色，size生成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 *  判断某年某月有几天
 *
 *  @param year  年
 *  @param month 月
 *
 *  @return 天数
 */
+ (NSInteger)getDaysOfYear:(NSInteger)year month:(NSInteger)month{
    if(year<=0)
        return 0;
    switch(month)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
        case 2:
            if((year%4!=0)||((year%100==0)&&(year%400!=0)))
                return 28;
            else
                return 29;
        default:
            return 0;
    };
}

+ (NSInteger)getThisWeekDay{
    //获取日期
    NSArray * weekArray=[NSArray arrayWithObjects:@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];
    weekArray=[NSArray arrayWithObjects:@(7),@(1),@(2),@(3),@(4),@(5),@(6), nil];
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    //NSInteger year=[comps year];
    //NSInteger month = [comps month];
    //NSInteger day = [comps day];
    return [[weekArray objectAtIndex:week-1] integerValue];
}

+ (BOOL)isNonEmptyArray:(id)obj{
    if (obj == nil) {
        return NO;
    }
    if (![obj isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (((NSArray *)obj).count < 1) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isNonEmptyDictionary:(id)obj{
    if (obj == nil) {
        return NO;
    }
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if (([(NSDictionary *)obj allKeys]).count < 1) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isNonEmptySring:(id)obj{
    if (obj == nil) {
        return NO;
    }
    if (![obj isKindOfClass:[NSString class]]) {
        return NO;
    }
    if (((NSString *)obj).length < 1) {
        return NO;
    }
    
    return YES;
}

@end
