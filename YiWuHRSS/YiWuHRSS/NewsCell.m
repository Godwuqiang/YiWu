//
//  NewsCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "NewsCell.h"
#import "UIButton+JKImagePosition.h"

@interface NewsCell()

@property (nonatomic, strong) UIView *bgView;     //除了标签圆点外的区域

@property (nonatomic, strong) UIImageView *point; // 小红点
@property (nonatomic, strong) UILabel *titleLB;   // 新闻标题
@property (nonatomic, strong) UILabel *timeLB;    // 时间标题
@property (nonatomic, strong) UIImageView *arrow; // 箭头
//@property (nonatomic, assign) BOOL isDelete;  // 是否删除

@end


@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self UI];
}

- (void)UI {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    
    // bgView
    self.bgView = [UIView new];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
    [self.contentView addSubview:self.bgView];
    
    /* 编辑图标 */
    self.editIcon = [UIImageView new];
    self.editIcon.hidden = YES;
    self.editIcon.image = [UIImage imageNamed:@"message_select"];
    [self.contentView addSubview:self.editIcon];
    [self.editIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.contentView.mas_top).offset(18);
        make.left.equalTo(weakSelf.contentView.mas_left).offset(10);
        make.width.mas_equalTo(@25);
        make.height.mas_equalTo(@25);
    }];
    
    /* 删除按钮 */
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(SCREEN_WIDTH, 0, 80, 80);
    self.deleteBtn.hidden = YES;
    [self.deleteBtn setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setImage:[UIImage imageNamed:@"icon_message_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.deleteBtn];
    [self.deleteBtn jk_setImagePosition:LXMImagePositionTop spacing:2];
    
    
    /* 红点图片 */
    self.point = [UIImageView new];
    self.point.hidden = YES;
    self.point.image = [UIImage imageNamed:@"message_dot2"];
    [self.bgView addSubview:self.point];
    [self.point mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.bgView.mas_top).with.offset(16);
        make.left.equalTo(weakSelf.bgView.mas_left).with.offset(6);
        make.width.mas_equalTo(@12);
        make.height.mas_equalTo(@12);
    }];
    
    /* 箭头图标 */
    self.arrow = [UIImageView new];
    self.arrow.hidden = NO;
    self.arrow.image = [UIImage imageNamed:@"arrow_go3"];
    [self.bgView addSubview:self.arrow];
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(weakSelf.bgView.mas_centerY).with.offset(0);
        make.right.equalTo(weakSelf.bgView.mas_right).with.offset(-15);
        make.width.mas_equalTo(@15);
        make.height.mas_equalTo(@17);
    }];
    
    /* 新闻标题 */
    self.titleLB = [UILabel new];
    self.titleLB.textColor = [UIColor colorWithHex:0x333333];
    self.titleLB.font = [UIFont systemFontOfSize:16.f];
    self.titleLB.numberOfLines = 2;
    [self.bgView addSubview:self.titleLB];
    [self.titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.bgView.mas_top).with.offset(14);
        make.left.equalTo(weakSelf.point.mas_right).with.offset(0);
        make.right.equalTo(weakSelf.arrow.mas_left).with.offset(-15);
    }];
    
    /* 时间标题 */
    self.timeLB = [UILabel new];
    self.timeLB.textColor = [UIColor colorWithHex:0xaaaaaa];
    self.timeLB.font = [UIFont systemFontOfSize:14.f];
    [self.bgView addSubview:self.timeLB];
    [self.timeLB mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(weakSelf.bgView.mas_bottom).with.offset(-10);
        make.left.equalTo(weakSelf.point.mas_right).with.offset(2);
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    if (isEdit) {
        self.editIcon.hidden = NO;
        self.bgView.frame = CGRectMake(35, 0, SCREEN_WIDTH, 80);
    } else {
        self.editIcon.hidden = YES;
        self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
    }
}

-(void)setIsChoosed:(BOOL)isChoosed {
    if (isChoosed) {
        self.editIcon.image = [UIImage imageNamed:@"message_select_on"];
    }else{
        self.editIcon.image = [UIImage imageNamed:@"message_select"];
    }
}

- (void)setMsgbean:(MsgBean *)msgbean {
    _msgbean = msgbean;
    if (nil==msgbean) {
        self.titleLB.text = @"暂无数据";
        self.timeLB.text = @"暂无数据";
        self.point.hidden = YES;
    }else{
        self.titleLB.text = msgbean.title;
        self.timeLB.text = msgbean.update_time;
        NSString *readstatus = msgbean.readStatus;
        if ([readstatus isEqualToString:@"0"]) {
            self.point.hidden = NO;
        }else{
            self.point.hidden = YES;
        }
    }
}

-(void)setIsDelete:(BOOL)isDelete {
    
    _isDelete = isDelete;
    if (!_isEdit) {
        if (isDelete) {
            self.deleteBtn.hidden = NO;
            self.bgView.frame = CGRectMake(-80, 0, SCREEN_WIDTH, 80);
            self.deleteBtn.frame = CGRectMake(SCREEN_WIDTH-80, 0, 80, 80);
        }else{
            self.deleteBtn.hidden = YES;
            self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
            self.deleteBtn.frame = CGRectMake(SCREEN_WIDTH, 0, 80, 80);
        }
    }
}

@end
