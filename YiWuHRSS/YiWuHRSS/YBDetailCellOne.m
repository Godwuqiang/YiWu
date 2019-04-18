//
//  YBDetailCellOne.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBDetailCellOne.h"

@implementation YBDetailCellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellOneWithMZBean:(MZBean*)bean{
    if (nil==bean) {
        self.name.text = @"暂无数据";
        self.rylb.text = @"暂无数据";
        self.dd.text = @"暂无数据";
        self.lx.text = @"暂无数据";
        self.date.text = @"暂无数据";
        self.jbms.text = @"暂无数据";
    }else{
        self.name.text = nil==bean.cbrxm?@"无":bean.cbrxm;
        self.rylb.text = nil==bean.rylb?@"无":bean.rylb;
        self.dd.text = nil==bean.yyyd?@"无":bean.yyyd;
        self.jbms.text = nil==bean.jbms?@"无":bean.jbms;
        self.lx.text = @"门诊";
        if (nil==bean.jzrq) {
            self.date.text = @"无";
        }else{
            @try {
                NSMutableString *date = [[NSMutableString alloc]init];
                date.string = bean.jzrq;
                [date insertString:@"-" atIndex:4];
                [date insertString:@"-" atIndex:7];
                self.date.text = date;
            } @catch (NSException *exception) {
                self.date.text = @"无";
            }
        }
    }
}

-(void)ConfigCellOneWithZYBean:(ZYBean*)bean{
    if (nil==bean) {
        self.name.text = @"暂无数据";
        self.rylb.text = @"暂无数据";
        self.dd.text = @"暂无数据";
        self.lx.text = @"暂无数据";
        self.date.text = @"暂无数据";
        self.jbms.text = @"暂无数据";
    }else{
        self.name.text = nil==bean.cbrxm?@"无":bean.cbrxm;
        self.rylb.text = nil==bean.rylb?@"无":bean.rylb;
        self.dd.text = nil==bean.yyyd?@"无":bean.yyyd;
        self.jbms.text = nil==bean.jbms?@"无":bean.jbms;
        self.lx.text = @"住院";
        if (nil==bean.ryrq) {
            self.date.text = @"无";
        }else{
            @try {
                NSMutableString *date = [[NSMutableString alloc]init];
                date.string = bean.ryrq;
                [date insertString:@"-" atIndex:4];
                [date insertString:@"-" atIndex:7];
                self.date.text = date;
            } @catch (NSException *exception) {
                self.date.text = @"无";
            }
        }
    }
}

@end
