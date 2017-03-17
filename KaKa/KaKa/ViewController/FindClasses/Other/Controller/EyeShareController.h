//
//  EyeShareController.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/25.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeBaseViewController.h"
#import "EyeAddressModel.h"
#import "EyeTextView.h"     //自定义带有placeHolder的UITextView
#import "RecordModel.h"
#import "Credentials.h"
#import "ItemList.h"
#import <AliyunOSSiOS/OSSService.h>
#import "EyeSelectedAdressController.h"//地址选择页面
@interface EyeShareController : EyeBaseViewController
/** 写心情 */
@property (nonatomic, strong) EyeTextView *textView;
/** 封面 */
@property (nonatomic, strong) UIImageView *coverImageView;
/** 封面图片名字 */
@property (nonatomic, copy) NSString *coverImageName;
/** 地理位置信息 */
@property (nonatomic, strong) EyeAddressModel *addressModel;
/** 更换封面按钮 */
@property (nonatomic, weak) UIButton *changeCovImageBtn;
/** 更换地址按钮 */
@property (nonatomic, weak) UIButton *addressBtn;


//点击分享按钮
- (void)shareButtonClick:(UIButton *)button;
//点击更换封面按钮
- (void)changCovImageBtnClick:(UIButton *)button;
/**
 *  判断字符串的字节数
 *
 *  @param argString 传入的字符串
 *
 *  @return 字节数
 */
- (NSInteger)GetStringCharSize:(NSString*)argString;
/**
 *  截取前面50个字符
 *
 *  @param text 传入的字符串
 *
 *  @return 截取后的字符串
 */
- (NSString *)cutStringTill25:(NSString *)text;

- (void)addressBtnClick:(UIButton *)btn;
@end
