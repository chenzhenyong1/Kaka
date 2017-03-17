//
//  EyeDetailInfoCellTableViewCell.m
//  KakaFind
//
//  Created by 陈振勇 on 16/8/23.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import "EyeDetailInfoCell.h"
#import "Subject.h"
#import "EyeAddressModel.h"
#import "TrafficViolation.h"

@interface EyeDetailInfoCell ()

/** 头像 */
@property (nonatomic, weak) UIImageView *iconImageView;
/** 姓名 */
@property (nonatomic, weak) UILabel *nameLabel;
/** 地址 */
@property (nonatomic, weak) UILabel *addressLabel;
/** 发表时间 */
@property (nonatomic, weak) UILabel *publishTimeLabel;
/** 标题 */
@property (nonatomic, weak) UILabel *titleLabel;


/** 违章举报时添加 */
@property (nonatomic, weak) UIView *breakRulesView;
/** 车牌号 */
@property (nonatomic, weak) UILabel *carNumberLabel;
/** 违章的行为 */
@property (nonatomic, weak) UILabel *violateTypeLabel;
/** 审核 */
@property (nonatomic, weak) UILabel *processStateLabel;
/** 违章地点 */
@property (nonatomic, weak) UILabel *violateLocationLabel;
/** 违章时间 */
@property (nonatomic, weak) UILabel *violateTimeLabel;
@end

@implementation EyeDetailInfoCell

#pragma mark -- life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self configureLayout];
    }
    
    return self;
}

- (void)configureLayout
{
    //头像
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.equalTo(self).with.offset(10);
        
        make.size.mas_equalTo(CGSizeMake(45, 45));
        
    }];
    //名字
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        
        make.top.equalTo(self.iconImageView.mas_top);
        
    }];
    //地址
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.nameLabel.mas_left);
        make.bottom.equalTo(self.iconImageView.mas_bottom);
        
    }];
    //话题发布时间
    [self.publishTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.nameLabel.mas_bottom);
        
    }];
    
    //标题
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_left);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
        make.right.equalTo(self.publishTimeLabel.mas_right);
    }];
    
    [self.breakRulesView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(20);
        make.height.equalTo(@100);
    }];
    
}

#pragma mark -- public

-(void)refreshUI:(Subject *)subject
{
    //头像
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:subject.authorPortraitUrl] placeholderImage:[UIImage imageNamed:@"default_header"]];
    
    self.nameLabel.text = subject.authorNickName;
    self.addressLabel.text = subject.location;
    self.publishTimeLabel.text = subject.publishTime;
    
    self.titleLabel.text = subject.shortText;
    
    if ([subject.subjectKind integerValue] == 5 ) {//是否是违章举报
        
        self.breakRulesView.hidden = NO;
        
        
    }else
    {
//        [self.breakRulesView removeFromSuperview];
        self.breakRulesView.hidden = YES;
    }
    

}
/**
 *  刷新违章信息
 *
 *  @param trafficViolation TrafficViolation违章信息
 */
- (void)refreshBreakRulesUI:(TrafficViolation *)trafficViolation
{
    self.carNumberLabel.text = trafficViolation.plate;
    self.violateTypeLabel.text = trafficViolation.violateTypeCode;
    self.violateLocationLabel.text = [NSString stringWithFormat:@"违章地点： %@",trafficViolation.violateLocation];
    self.violateTimeLabel.text = [NSString stringWithFormat:@"违章时间： %@",trafficViolation.violateTime];
    switch ([trafficViolation.processState integerValue]) {
        case 1:
            self.processStateLabel.text = @"暂未受理";
            break;
        case 2:
            self.processStateLabel.text = @"系统已经受理";
            break;
        case 3:
            self.processStateLabel.text = @"交通管理部门处理中";
            break;
        case 4:
            self.processStateLabel.text = @"交通管理部门通过";
            break;
        case 5:
            self.processStateLabel.text = @"交通管理部门驳回";
            break;
        default:
            break;
            
    }
    
    
    
}



//查看时的数据
-(void)refreshCheckUI:(EyeAddressModel *)model
{
    NSDictionary *userInfo = UserInfo;
    // 头像
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:FORMATSTRING(VALUEFORKEY(userInfo, @"portraitImgUrl"))] placeholderImage:GETYCIMAGE(@"default_header")];
    
    // 用户名
    NSString *nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"nickName"));
    if (nickName.length == 0) {
        // 昵称没有取用户名
        nickName = FORMATSTRING(VALUEFORKEY(userInfo, @"userName"));
    }
    
    self.nameLabel.text = nickName;
    
    self.publishTimeLabel.text = @"刚刚";
    
    self.addressLabel.text = model.address;
    
    self.breakRulesView.hidden = YES;
    //心情描述
    self.titleLabel.text = self.mood;
    
}


#pragma mark -- property

-(UIView *)breakRulesView
{
    if (!_breakRulesView) {
        
        UIView *breakRulesView = [[UIView alloc] init];
        
//        redView.backgroundColor = [UIColor redColor];
      
        [self addSubview:breakRulesView];
        //车牌号
        UILabel *carNumberLabel = [[UILabel alloc]init];
        carNumberLabel.font = [UIFont systemFontOfSize:13];
        carNumberLabel.textColor = [UIColor whiteColor];
        carNumberLabel.textAlignment = NSTextAlignmentCenter;
        carNumberLabel.backgroundColor = ZYRGBColor(52, 109, 215);
        [breakRulesView addSubview:carNumberLabel];
        [carNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(breakRulesView);
            make.height.equalTo(@35);
            make.width.equalTo(@80);
        }];
        self.carNumberLabel = carNumberLabel;
        //违章的行为
        UILabel *violateTypeLabel = [[UILabel alloc]init];
        violateTypeLabel.font = [UIFont systemFontOfSize:13];
        violateTypeLabel.textColor = ZYRGBColor(171, 0, 6);
        [violateTypeLabel sizeToFit];
        [breakRulesView addSubview:violateTypeLabel];
        [violateTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.carNumberLabel.mas_right).offset(20);
            make.centerY.equalTo(self.carNumberLabel.mas_centerY);
            
        }];
        self.violateTypeLabel = violateTypeLabel;
        
        //审核
        UILabel *processStateLabel = [[UILabel alloc]init];
        processStateLabel.font = [UIFont systemFontOfSize:13];
        processStateLabel.textColor = [UIColor whiteColor];
        [processStateLabel sizeToFit];
//        processStateLabel.width += 20;
        processStateLabel.textAlignment = NSTextAlignmentCenter;
        processStateLabel.backgroundColor = ZYRGBColor(170, 24, 36);
        [breakRulesView addSubview:processStateLabel];
        [processStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self.carNumberLabel.mas_centerY);
//            make.height.equalTo(@25);
//            make.width.equalTo(@70);
        }];
        self.processStateLabel = processStateLabel;
        
        //违章地点
        UILabel *violateLocationLabel = [[UILabel alloc]init];
        violateLocationLabel.font = [UIFont systemFontOfSize:13];
        violateLocationLabel.textColor = [UIColor darkGrayColor];
        [violateLocationLabel sizeToFit];
        [breakRulesView addSubview:violateLocationLabel];
        [violateLocationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.carNumberLabel.mas_left);
            make.top.equalTo(self.carNumberLabel.mas_bottom).offset(15);
            
        }];
        self.violateLocationLabel = violateLocationLabel;
        
        
        //违章时间
        UILabel *violateTimeLabel = [[UILabel alloc]init];
        violateTimeLabel.font = [UIFont systemFontOfSize:13];
        violateTimeLabel.textColor = [UIColor darkGrayColor];
        [violateTimeLabel sizeToFit];
        [breakRulesView addSubview:violateTimeLabel];
        [violateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.carNumberLabel.mas_left);
            make.top.equalTo(self.violateLocationLabel.mas_bottom).offset(8);
            
        }];
        self.violateTimeLabel = violateTimeLabel;
        
        _breakRulesView = breakRulesView;
    }
    return _breakRulesView;
}


-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 45 * 0.5;
        
        [self addSubview:imageView];
        
        _iconImageView = imageView;
    }
    
    return _iconImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
        
        _nameLabel = label;
    }
    return _nameLabel;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        [self addSubview:label];
        
        _titleLabel = label;
    }
    return _titleLabel;
}

-(UILabel *)addressLabel
{
    if (!_addressLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        
        [self addSubview:label];
        
        _addressLabel = label;
    }
    return _addressLabel;
}

-(UILabel *)publishTimeLabel
{
    if (!_publishTimeLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        
        
        [self addSubview:label];
        
        _publishTimeLabel = label;
    }
    return _publishTimeLabel;
}

-(void)setFrame:(CGRect)frame
{
//    self.backgroundColor = [UIColor redColor];
//    frame.size.height -= 10;
    frame.origin.y += 10;
    
    [super setFrame:frame];
}

@end
