//
//  YBCostCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBCostCell.h"

@implementation YBCostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithYiBaoCostBean:(YiBaoCostBean*)bean{
    if (nil==bean) {
        self.Time.text = @"暂无数据";
        self.Cost.text = @"暂无数据";
        self.Hospital.text = @"暂无数据";
        self.type.backgroundColor = [UIColor whiteColor];
    }else{
        if (nil==bean.ybxfsj) {
            self.Time.text = @"无";
        }else{
            @try {
                NSMutableString *date = [[NSMutableString alloc]init];
                date.string = bean.ybxfsj;
                [date insertString:@"-" atIndex:4];
                [date insertString:@"-" atIndex:7];
                self.Time.text = date;
            } @catch (NSException *exception) {
                self.Time.text = @"无";
            }
        }
        self.Cost.text = nil==bean.ybxfje?@"无":bean.ybxfje;
        self.Hospital.text = nil==bean.ybxfdd?@"无":bean.ybxfdd;
        if (nil==bean.ybxflx) {
            self.type.backgroundColor = [UIColor whiteColor];
        }else{
            NSString *type = bean.ybxflx;
            if ([type isEqualToString:@"1"]) {
                self.type.image = [UIImage imageNamed:@"icon_clinic"];
            }else{
                self.type.image = [UIImage imageNamed:@"ico_hospital"];
            }
        }
    }
}

@end
