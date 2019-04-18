//
//  TalentArchivesCell.m
//  YiWuHRSS
//
//  Created by 大白 on 2019/4/10.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import "TalentArchivesCell.h"

@interface TalentArchivesCell()

@property (nonatomic,strong)UILabel *stateValue;

@property (nonatomic,strong)UILabel *arriveTimeValue;

@property (nonatomic,strong)UILabel *leaveTimeValue;

@end

@implementation TalentArchivesCell

+ (instancetype)createCellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"TalentArchivesCellId";
    
    TalentArchivesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[self class] alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        UIView *bgView= [[UIView alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, kRatio_Scale_375(100))];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.masksToBounds =YES;
        bgView.layer.cornerRadius = 3;
        [self.contentView addSubview:bgView];
        
        UILabel *state = [[UILabel alloc]init];
        state.text = @"档案状态:";
        state.textColor = [UIColor grayColor];
        state.font = Font_Scale_375(14);
        [bgView addSubview:state];
        self.stateValue = [[UILabel alloc]init];
        self.stateValue.textColor = [UIColor blackColor];
        self.stateValue.font = Font_Scale_375(14);
        [bgView addSubview:self.stateValue];
        
        UILabel *arriveTime =[[UILabel alloc]init];
        arriveTime.text = @"到档时间:";
        arriveTime.textColor = [UIColor grayColor];
        arriveTime.font = Font_Scale_375(14);
        [bgView addSubview:arriveTime];
        
        self.arriveTimeValue = [[UILabel alloc]init];
        self.arriveTimeValue.textColor = [UIColor blackColor];
        self.arriveTimeValue.font = Font_Scale_375(14);
        [bgView addSubview:self.arriveTimeValue];
        
        UILabel *leaveTime =[[UILabel alloc]init];
        leaveTime.text = @"转出时间:";
        leaveTime.textColor = [UIColor grayColor];
        leaveTime.font = Font_Scale_375(14);
        [bgView addSubview:leaveTime];
        
        self.leaveTimeValue = [[UILabel alloc]init];
        self.leaveTimeValue.textColor = [UIColor blackColor];
        self.leaveTimeValue.font = Font_Scale_375(14);
        [bgView addSubview:self.leaveTimeValue];
        
        [state mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(bgView).offset(kRatio_Scale_375(10));
            make.height.offset(kRatio_Scale_375(20));
        }];
        
        [self.stateValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgView).offset(kRatio_Scale_375(10));
            make.left.equalTo(state.mas_right).offset(kRatio_Scale_375(20));
            make.height.offset(kRatio_Scale_375(20));
        }];
        
        [arriveTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(state.mas_bottom).offset(kRatio_Scale_375(10));
            make.left.equalTo(bgView).offset(kRatio_Scale_375(10));
            make.height.offset(kRatio_Scale_375(20));
        }];
        
        [self.arriveTimeValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(state.mas_bottom).offset(kRatio_Scale_375(10));
            make.left.equalTo(arriveTime.mas_right).offset(kRatio_Scale_375(20));
            make.height.offset(kRatio_Scale_375(20));
        }];
        
        [leaveTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(arriveTime.mas_bottom).offset(kRatio_Scale_375(10));
            make.left.equalTo(bgView).offset(kRatio_Scale_375(10));
            make.height.offset(kRatio_Scale_375(20));
        }];
        
        [self.leaveTimeValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(arriveTime.mas_bottom).offset(kRatio_Scale_375(10));
            make.left.equalTo(leaveTime.mas_right).offset(kRatio_Scale_375(20));
            make.height.offset(kRatio_Scale_375(20));
        }];
    }
    
    return self;
}

-(void)setState:(NSString *)state{
    _state = state;
    self.stateValue.text = state;
}

-(void)setArriveTime:(NSString *)arriveTime{
    _arriveTime = arriveTime;
    self.arriveTimeValue.text = arriveTime;
}

-(void)setLeaveTime:(NSString *)leaveTime{
    _leaveTime = leaveTime;
    self.leaveTimeValue.text = leaveTime;
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
