// 无限循环轮播ScrollView

#import <UIKit/UIKit.h>

@interface ZYInfiniteScrollView : UIView
@property (strong, nonatomic) NSArray *images;


@property (nonatomic, strong) NSArray *titles;

/** 数据源 */
@property (nonatomic, strong) NSArray *dataArr;

@property (weak, nonatomic, readonly) UIPageControl *pageControl;
@property (assign, nonatomic, getter=isScrollDirectionPortrait) BOOL scrollDirectionPortrait;
@end
