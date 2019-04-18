//
//  PayCellTwo.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/19.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "PayCellTwo.h"

@implementation PayCellTwo

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithJiaoFeiInfoBean:(JiaoFeiInfoBean*)bean{
    if (nil==bean) {
        self.bxmc.text = @"暂无数据";
        self.jfjs.text = @"暂无数据";
        self.dwjf.text = @"暂无数据";
        self.grjf.text = @"暂无数据";
        self.company.text = @"暂无数据";
        self.IsDZ.backgroundColor = [UIColor whiteColor];
    }else{
        NSString *bx = nil==bean.xzmc?@"无":bean.xzmc;
        NSString *jf = nil==bean.jfze?@"无":bean.jfze;
        self.bxmc.text = [NSString stringWithFormat:@"%@   %@",bx,jf];
        NSString *js = nil==bean.jfjs?@"无":bean.jfjs;
        self.jfjs.text = [NSString stringWithFormat:@"缴费基数%@",js];
        NSString *dw  = nil==bean.dwjf?@"无":bean.dwjf;
        self.dwjf.text = [NSString stringWithFormat:@"其中单位缴费%@",dw];
        NSString *gr  = nil==bean.grjf?@"无":bean.grjf;
        self.grjf.text = [NSString stringWithFormat:@"个人缴费%@",gr];
        self.company.text = nil==bean.jfdw?@"无":bean.jfdw;
        if (nil==bean.jfStatus) {
            self.IsDZ.backgroundColor = [UIColor whiteColor];
        }else{
            if ([bean.jfStatus isEqualToString:@"0"]) {
                self.IsDZ.image = [UIImage imageNamed:@"icon_daozhang2"];
            }else if ([bean.jfStatus isEqualToString:@"1"]||[bean.jfStatus isEqualToString:@"9"]){
                self.IsDZ.image = [UIImage imageNamed:@"icon_daozhang"];
            }else{
                self.IsDZ.image = [UIImage imageNamed:@"icon_daozhang3"];
            }
        }
    }
}

@end
