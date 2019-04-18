//
//  CityPeopleProvideTableviewCell.m
//  YiWuHRSS
//
//  Created by 大白 on 2019/3/6.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import "CityPeopleProvideTableviewCell.h"

@interface CityPeopleProvideTableviewCell()

@property (nonatomic,strong)UILabel *nameLabel;

@property (nonatomic,strong)UILabel *valueLabel;

@end

@implementation CityPeopleProvideTableviewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

-(void)initUI{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatio_Scale_375(10),kRatio_Scale_667(10), kRatio_Scale_375(70), kRatio_Scale_667(30))];
    self.nameLabel.font = Font_Scale_375(14);
    self.nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.nameLabel];
    
    self.valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatio_Scale_375(90),kRatio_Scale_667(10), kRatio_Scale_375(230), kRatio_Scale_667(30))];
    self.valueLabel.font = Font_Scale_375(14);
    self.valueLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.valueLabel];
    
    self.directionImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.valueLabel.right+kRatio_Scale_375(10),kRatio_Scale_667(15),kRatio_Scale_667(15), kRatio_Scale_667(15))];
    self.directionImage.image = [UIImage imageNamed:@"arrow_go3"];
    self.directionImage.hidden = YES;
    [self.contentView addSubview:self.directionImage];
    UIView *lineView= [[UIView alloc]initWithFrame:CGRectMake(kRatio_Scale_375(10), kRatio_Scale_667(49), kWidth_Scale_375, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:lineView];
}

-(void)setName:(NSString *)name{
    _name = name;
    self.nameLabel.text = name;
}

-(void)setValue:(NSString *)value{
    _value = value;
    self.valueLabel.text = value;
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
