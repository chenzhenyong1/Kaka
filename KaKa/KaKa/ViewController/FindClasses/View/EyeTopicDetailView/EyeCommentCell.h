//
//  EyeCommentCell.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/22.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InteractList;
@interface EyeCommentCell : UITableViewCell


/** 楼层 */
@property (nonatomic, weak) UILabel *floorNumLabel;
/** interactList */
//@property (nonatomic, strong) InteractList *interactList;

- (void)refreshUI:(InteractList *)interactList;



//+(instancetype)cellWithTableView:(UITableView *)tableView;

@end
