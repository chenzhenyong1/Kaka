//
//  EyeSquareCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/20.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  广场话题栏目的cell

#import <UIKit/UIKit.h>
@class ColumnOverview;

typedef enum {
    
    EyeSquareCellClickImageLeft = 0,
    EyeSquareCellClickImageRight,
    EyeSquareCellClickMoreButton

} EyeSquareCellClickEnum;


@class EyeSquareCell;

@protocol EyeSquareCellDelegate <NSObject>

@optional
- (void)squareCellDidClick:(EyeSquareCell *)squareCell clickEnum:(EyeSquareCellClickEnum) clickEnum;

@end

typedef void(^squareCellMoreBlock)(void);
@interface EyeSquareCell : UITableViewCell

/** ColumnOverview */
@property (nonatomic, strong) ColumnOverview *columnOverview;
//
/** 代理 */
@property (nonatomic, weak) id<EyeSquareCellDelegate> delegate;

/** 标志 */
@property (nonatomic, strong) NSIndexPath *indexPath;
//
///** block */
//@property (nonatomic, strong) squareCellMoreBlock moreBlock;

- (void)refreshUI:(ColumnOverview *)columnOverview;



@end
