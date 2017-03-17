//
//  CameraHomeTableViewCell.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/7/20.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CameraHomeTableViewCell.h"

@interface CameraHomeTableViewCell ()
// 摄像头名称
@property (nonatomic, strong) UILabel *cameraNameLabel;

//摄像头标识照片
@property (nonatomic, strong) UIImageView *cameraIcon;

@property (nonatomic, strong) UIImageView *is_on_line;

//是否在线lab
@property (nonatomic, strong) UILabel *on_line;

@property (nonatomic, strong) UILabel *right_kuoHao;

@property (nonatomic, strong) UILabel *left_kuoHao;
// 摄像头背景图片
@property (nonatomic, strong) UIImageView *cameraBgImageView;

@end

@implementation CameraHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 查看详情按钮
    UIButton *showDetailBtn = [[UIButton alloc] init];
    showDetailBtn.backgroundColor = [UIColor whiteColor];
//    [showDetailBtn addTarget:self action:@selector(showDetailBtn_clicked_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:showDetailBtn];
    [showDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(40);
    }];
    showDetailBtn.hidden = YES;
    
    // 横线
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = RGBSTRING(@"f3f4f6");
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(showDetailBtn.mas_bottom);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(1);
    }];
    
    // 摄像头图标
    UIImageView *cameraIcon = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_camera_icon.png")];
    [self.contentView addSubview:cameraIcon];
    [cameraIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_top).with.offset(20);
        make.left.mas_equalTo(self.mas_left).with.offset(30 * PSDSCALE_X);
    }];
    _cameraIcon = cameraIcon;
    
    // 初始化UI
    UILabel *cameraNameLabel = [[UILabel alloc] init];
    cameraNameLabel.font = [UIFont systemFontOfSize:27 * FONTCALE_Y];
//    cameraNameLabel.textColor = RGBSTRING(@"b11c22");
    cameraNameLabel.text = @"摄像头 V3.3.3.0";
    [self.contentView addSubview:cameraNameLabel];
    [cameraNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraIcon.mas_centerY);
        make.left.mas_equalTo(cameraIcon.mas_right).with.offset(10 * PSDSCALE_X);
//        make.height.mas_equalTo(42);
    }];
    _cameraNameLabel = cameraNameLabel;
    
    UILabel *left_kuoHao = [[UILabel alloc] init];
    left_kuoHao.font = [UIFont systemFontOfSize:27 * FONTCALE_Y];
    left_kuoHao.text = @"(";
    [self.contentView addSubview:left_kuoHao];
    [left_kuoHao mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraIcon.mas_centerY);
        make.left.mas_equalTo(cameraNameLabel.mas_right).with.offset(10 * PSDSCALE_X);
    }];
    
    _left_kuoHao = left_kuoHao;
    
    UIImage *on_line = GETYCIMAGE(@"Camera_on_line");
    UIImageView *is_on_line = [[UIImageView alloc] initWithImage:on_line];
    [self.contentView addSubview:is_on_line];
    [is_on_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraIcon.mas_centerY);
        make.left.mas_equalTo(left_kuoHao.mas_right).with.offset(5 * PSDSCALE_X);
        make.width.mas_equalTo(on_line.size.width);
        make.height.mas_equalTo(on_line.size.height);
    }];
    _is_on_line = is_on_line;
    
    
    UILabel *on_line_lab = [[UILabel alloc] init];
    on_line_lab.font = [UIFont systemFontOfSize:27 * FONTCALE_Y];
    on_line_lab.text = @"在线";
    [self.contentView addSubview:on_line_lab];
    [on_line_lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraIcon.mas_centerY);
        make.left.mas_equalTo(is_on_line.mas_right).with.offset(5 * PSDSCALE_X);
    }];
    
    _on_line = on_line_lab;
    
    UILabel *right_kuoHao = [[UILabel alloc] init];
    right_kuoHao.font = [UIFont systemFontOfSize:27 * FONTCALE_Y];
    right_kuoHao.text = @")";
    [self.contentView addSubview:right_kuoHao];
    [right_kuoHao mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cameraIcon.mas_centerY);
        make.left.mas_equalTo(on_line_lab.mas_right).with.offset(10 * PSDSCALE_X);
    }];
    
    _right_kuoHao = right_kuoHao;
    
    // 箭头
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:GETNCIMAGE(@"camera_right_arrow.png")];
    [self.contentView addSubview:rightArrowImageView];
    [rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-30 * PSDSCALE_X);
        make.centerY.mas_equalTo(_cameraNameLabel.mas_centerY);
    }];
    
    // 查看详情label
    UILabel *showDetailLabel = [[UILabel alloc] init];
    showDetailLabel.textColor = RGBSTRING(@"999999");
    showDetailLabel.text = @"查看详情";
    showDetailLabel.font = [UIFont systemFontOfSize:22 * FONTCALE_Y];
    [self.contentView addSubview:showDetailLabel];
    [showDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(rightArrowImageView.mas_left).with.offset(-18 * PSDSCALE_X);
        make.centerY.mas_equalTo(rightArrowImageView.mas_centerY);
    }];
    
    // 背景图
    UIImageView *cameraBgImageView = [[UIImageView alloc] init];
    cameraBgImageView.backgroundColor = [UIColor whiteColor];
    cameraBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    cameraBgImageView.clipsToBounds = YES;
//    cameraBgImageView.image = GETNCIMAGE(@"camera_home_defaultBg.png");
    [self.contentView addSubview:cameraBgImageView];
    [cameraBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(showDetailBtn.mas_left);
        make.top.mas_equalTo(line.mas_bottom);
        make.right.mas_equalTo(showDetailBtn.mas_right);
        make.height.mas_equalTo(420 * PSDSCALE_Y);
    }];
    _cameraBgImageView = cameraBgImageView;
    
}

- (void)setModel:(CameraListModel *)model {
    
    _model = model;
    
    if (model.is_on_line)
    {
        // 在线
        _on_line.text = @"在线";
        _on_line.textColor =RGBSTRING(@"b11c22");
        _right_kuoHao.textColor = RGBSTRING(@"b11c22");
        _left_kuoHao.textColor = RGBSTRING(@"b11c22");
        _is_on_line.image = GETYCIMAGE(@"Camera_on_line");
        _cameraIcon.image = GETYCIMAGE(@"camera_camera_icon.png");
        _cameraNameLabel.textColor = RGBSTRING(@"b11c22");
        _cameraNameLabel.text = [NSString stringWithFormat:@"%@",_model.name];
    }
    else
    {
        // 离线
        _on_line.text = @"离线";
        _on_line.textColor =RGBSTRING(@"838383");
        _right_kuoHao.textColor = RGBSTRING(@"838383");
        _left_kuoHao.textColor = RGBSTRING(@"838383");
        _is_on_line.image = GETYCIMAGE(@"Camera_off_line");
        _cameraIcon.image = GETYCIMAGE(@"camera_camera_icon_off_line");
        _cameraNameLabel.textColor = RGBSTRING(@"838383");
        _cameraNameLabel.text = _model.name;
    }
    
    if (_model.bgImage) {
        // 如果有背景图片，去请求加载
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/PHOTO/%@", _model.ipAddress, _model.bgImage]];
        [_cameraBgImageView sd_setImageWithURL:imageUrl placeholderImage:GETNCIMAGE(@"camera_home_defaultBg.png")];
    } else {
        // 没有背景图片，加载默认图片
        _cameraBgImageView.image = GETNCIMAGE(@"camera_home_defaultBg.png");
    }
    
}

// 详情按钮点击
- (void)showDetailBtn_clicked_action:(UIButton *)sender {
    
    MMLog(@"show detail button clicked");
}

- (void)setFrame:(CGRect)frame {
    
    frame.size.height -= 10;
    
    [super setFrame:frame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
