//
//  CanBaoInfoCellFour.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/17.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "CanBaoInfoCellFour.h"

@implementation CanBaoInfoCellFour

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigWithCanBaoInfoBean:(CanBaoInfoBean*)bean{
    if (nil==bean) {
        self.company.text = @"暂无数据";
        self.type.text = @"暂无数据";
        self.IsJF.backgroundColor = [UIColor whiteColor];
    }else{
        self.company.text = nil==bean.cbdw?@"暂无数据":bean.cbdw;
        self.type.text = nil==bean.xzname?@"暂无数据":bean.xzname;
        if (nil==bean.jfzt) {
            self.IsJF.backgroundColor = [UIColor whiteColor];
        }else{
            if ([bean.jfzt isEqualToString:@"1"]) {
                self.IsJF.image = [UIImage imageNamed:@"icon_canbao"];
            }else if ([bean.jfzt isEqualToString:@"2"]) {
                self.IsJF.image = [UIImage imageNamed:@"icon_canbao2"];
            }else if ([bean.jfzt isEqualToString:@"3"]) {
                self.IsJF.image = [UIImage imageNamed:@"icon_jiaofei4"];
            }else{
                self.IsJF.image = [UIImage imageNamed:@"icon_weizhi"];
            }
        }
    }
}

@end
