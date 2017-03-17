//
//  BaseViewController.h
//  iMark
//
//  Created by wei_yijie on 15/10/16.
//  Copyright © 2015年 showsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    UIView *self_view;
}


/**
 *  状态栏和默认背景
 */
- (void)addStatusBlackBackground;

/**
 *  导航栏返回
 *
 *  @param block 按钮回调
 */
- (void)addBackButtonWith:(void(^)(UIButton *sender))block;

/**
 *  设置图片或文字导航栏标题
 *
 *  @param name 图片文字对象
 *  @param num  长度
 */
- (void)addTitleWithName:(id)name wordNun:(int)num;
- (void)addTitle:(NSString *)name;

/**
 *  添加文字提示框
 *
 *  @param text     提示语
 *  @param duration 消失时间
 */
- (void)addActityText:(NSString *)text deleyTime:(float)duration;

/**
 *  加载提示
 *
 *  @param title    标题
 *  @param subTitle 子标题
 */
- (void)addActityLoading:(NSString *)title subTitle:(NSString *)subTitle;

/**
 *  移除加载提示
 */
- (void)removeActityLoading;

/**
 *  导航栏右键
 *
 *  @param name          文字或图片
 *  @param num           长度
 *  @param clickedAction 点击block方法
 */
- (void)addRightButtonWithName:(id)name wordNum:(int)num actionBlock:(void (^)(UIButton *sender))clickedAction;

/**
 *  解析返回数据(每个项目自行修改里边的状态码判断)
 *
 *  @param data      返回Data
 *  @param ok_block  成功block
 *  @param err_block 失败block
 */
- (void)resolveReturnData:(id)data
                 ok_block:(void (^)(NSDictionary *resultDic))ok_block
                err_block:(void (^)(NSDictionary *resultDic))err_block;

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
                             inView:(UIView *)view;
/**
 *  初始化文本框
 *
 *  @param frame     视图范围
 *  @param textColor 字体颜色
 *  @param textSize  字体大小
 *  @param text      文本内容
 *
 *  @return 文本框对象
 */
- (UILabel *)labelWithFrame:(CGRect)frame
                  textColor:(UIColor *)textColor
                   textFont:(CGFloat)textSize
                       text:(NSString *)text;

/**
 *  初始化文本框
 *
 *  @param frame     视图范围
 *  @param view      父视图
 *  @param color     字体颜色
 *  @param fontSize  字体大小
 *  @param text      文本内容
 *  @param alignment 对齐方式
 *  @param bold      是否加粗
 *  @param fit       是否自适应
 *
 *  @return 文本框对象
 */
- (UILabel *)labelWithFrame:(CGRect)frame
                     inView:(UIView *)view
                  textColor:(UIColor *)color
                   fontSize:(CGFloat)fontSize
                       text:(NSString *)text
                  alignment:(NSTextAlignment)alignment
                       bold:(BOOL)bold
                        fit:(BOOL)fit;

/**
 *  初始化图片视图
 *
 *  @param frame           视图范围
 *  @param view            父视图
 *  @param image           图片对象
 *  @param mode            显示模式
 *  @param backgroundColor 背景颜色
 *  @param cornerRadius    圆角半径
 *  @param width           边框宽度
 *  @param borderColor     边框颜色
 *
 *  @return 图片视图对象
 */
- (UIImageView *)imageViewWithFrame:(CGRect)frame
                             inView:(UIView *)view
                              image:(id)image
                        contentMode:(id)mode
                    backgroundColor:(id)backgroundColor
                       cornerRadius:(CGFloat)cornerRadius
                        borderWidth:(CGFloat)width
                        borderColor:(id)borderColor;

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
 *  @param state              初始化状态
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
                        block:(void (^)(UIButton *sender))block;

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
- (UIView *)viewWithFrame:(CGRect)frame
                   inView:(UIView *)view
          backgroundColor:(UIColor *)color
             cornerRadius:(CGFloat)cornerRadius;

/**
 *  校验身份证号
 *
 *  @param identityCard 省份证号
 *
 *  @return 格式是否正确
 */
-(BOOL)checkIdentityCardNo:(NSString*)cardNo;

/**
 *  校验邮箱格式
 *
 *  @param email 邮箱
 *
 *  @return 格式是否正确
 */
//- (BOOL)validateEmail:(NSString *)email;

/**
 *  校验手机号码
 *
 *  @param phone 手机号
 *
 *  @return 结果
 */
- (BOOL)checkPhoneNumber:(NSString *)phone;

/**
 *  验证邮编
 *
 */
- (BOOL) isValidZipcode:(NSString*)value;

/**
 *  调试方法，在当前视图添加一个屏幕大小的按钮点击跳转到指定类
 *
 *  @param className  类名
 *  @param clickBlock 回调
 */
- (void)addTapGesture:(NSString *)className clickBlock:(void(^)(UIButton *sender))clickBlock;

/** 隐藏tableview多余的线 */
- (void)setExtraCellLineHidden: (UITableView *)tableView;

/**
 *  将图片压缩到某个大小以下
 *
 *  @param image       待压缩的图片
 *  @param maxFileSize 压缩到多少多少以下
 *
 *  @return 压缩的图片
 */
- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize;

/**
 *  对网络进行监听，当监听到有网络时，可以重写该方法更新数据
 */
- (void)updates;

- (NSString *)cyclePhoto_PathChangeCycleVideo_Path:(NSString *)cyclePhoto_Path;

@end
