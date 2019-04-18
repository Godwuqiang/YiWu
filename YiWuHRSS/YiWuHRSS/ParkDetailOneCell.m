//
//  ParkDetailOneCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ParkDetailOneCell.h"

@implementation ParkDetailOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setParkbean:(ParkBean *)parkbean {
    
    if ([parkbean.type isEqualToString:@"A"]) {
        self.Img.image = [UIImage imageNamed:@"img_parking1"];  // 停车场
    }else if ([parkbean.type isEqualToString:@"B"]) {
        self.Img.image = [UIImage imageNamed:@"img_parking2"];  // 道路停车
    }else{
        self.Img.image = nil;
    }
    
    self.Name.text = nil==parkbean.parkname?@"--":parkbean.parkname;
    self.Address.text = nil==parkbean.address?@"--":parkbean.address;
    
    if (nil==parkbean.surplusnum) {
        self.Kynum.text = @"--";
    }else{
        self.Kynum.text = [NSString stringWithFormat:@"%@个",parkbean.surplusnum];
    }
    
    if (nil==parkbean.count) {
        self.Zsnum.text = @"--";
    }else{
        self.Zsnum.text = [NSString stringWithFormat:@"总计车位：%@个",parkbean.count];
    }
    
}

@end
