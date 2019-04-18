//
//  DTFRegistRecordCell.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFRegistRecordCell.h"
#import "DTFRegistRecordModel.h"

@interface DTFRegistRecordCell ()

@property (weak, nonatomic) IBOutlet UILabel *applyTime;    //登记时间
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;  //审核状态
@property (weak, nonatomic) IBOutlet UILabel *addressLabel; //地点
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;//医院
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;    //时间


@end

@implementation DTFRegistRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)setRecordModel:(DTFRegistRecordModel *)recordModel{
    
    _recordModel = recordModel;
    self.applyTime.text = _recordModel.jbsj;
    self.remarkLabel.text = _recordModel.remark;
    
    if([_recordModel.shzt isEqualToString:@"0"]){
        
        self.statusLabel.text = @"审核中";
        self.statusLabel.textColor = [UIColor colorWithHex:0x249dee];
        
    }else if ([_recordModel.shzt isEqualToString:@"1"]){
        
        self.statusLabel.text = @"审核成功";
        self.statusLabel.textColor = [UIColor colorWithHex:0x23b287];
        
    }else if ([_recordModel.shzt isEqualToString:@"2"]){
        
        self.statusLabel.text = @"审核失败";
        self.statusLabel.textColor = [UIColor colorWithHex:0xf66868];
        
    }else{
        
        self.statusLabel.text = @"--";
        self.statusLabel.textColor = [UIColor colorWithHex:0x666666];
        
    }
    
    if([_recordModel.type integerValue] == 1){//异地安置
        
        self.addressLabel.text = [NSString stringWithFormat:@"安置地点：%@",_recordModel.azdd];
        self.hospitalLabel.text = [NSString stringWithFormat:@"安置医院：%@",_recordModel.azyy];
        self.timeLabel.text = [NSString stringWithFormat:@"安置时间：%@-%@",_recordModel.startTime,_recordModel.endTime];
        
    }else if ([_recordModel.type integerValue] == 2){//探亲
        
        self.addressLabel.text = [NSString stringWithFormat:@"探亲地点：%@",_recordModel.azdd];
        self.hospitalLabel.text = [NSString stringWithFormat:@"安置医院：%@",_recordModel.azyy];
        self.timeLabel.text = [NSString stringWithFormat:@"探亲时间：%@-%@",_recordModel.startTime,_recordModel.endTime];
        
    }else if ([_recordModel.type integerValue] == 3){//外派
        
        self.addressLabel.text = [NSString stringWithFormat:@"外派地点：%@",_recordModel.azdd];
        self.hospitalLabel.text = [NSString stringWithFormat:@"安置医院：%@",_recordModel.azyy];
        self.timeLabel.text = [NSString stringWithFormat:@"外派时间：%@-%@",_recordModel.startTime,_recordModel.endTime];
        
    }else{
        
        self.addressLabel.text = [NSString stringWithFormat:@"安置地点：%@",_recordModel.azdd];
        self.hospitalLabel.text = [NSString stringWithFormat:@"安置医院：%@",_recordModel.azyy];
        self.timeLabel.text = [NSString stringWithFormat:@"安置时间：%@-%@",_recordModel.startTime,_recordModel.endTime];
    }
    
    
    
    
}

@end
