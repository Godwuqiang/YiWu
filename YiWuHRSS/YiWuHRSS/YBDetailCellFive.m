//
//  YBDetailCellFive.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBDetailCellFive.h"

@implementation YBDetailCellFive

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithZYBean:(ZYBean*)bean{
    if (nil==bean) {
        self.zydate.text = @"暂无数据";
        self.xyf.text = @"暂无数据";
        self.cwf.text = @"暂无数据";
        self.zcf.text = @"暂无数据";
        self.jyf.text = @"暂无数据";
        self.zlf.text = @"暂无数据";
        self.hlf.text = @"暂无数据";
        self.blzlfy.text = @"暂无数据";
    }else{
        if (nil==bean.ryrq) {
            self.zydate.text = @"";
        }else{
            NSMutableString *date = [[NSMutableString alloc]init];
            date.string = bean.ryrq;
            [date insertString:@"-" atIndex:4];
            [date insertString:@"-" atIndex:7];
            self.zydate.text = date;
        }
        self.xyf.text = nil==bean.cwf?@"":bean.cwf;
        self.cwf.text = nil==bean.jlypfy?@"":bean.jlypfy;
        self.zcf.text = nil==bean.ylypfy?@"":bean.ylypfy;
        self.jyf.text = nil==bean.blypfy?@"":bean.blypfy;
        self.zlf.text = nil==bean.jlzlfy?@"":bean.jlzlfy;
        self.hlf.text = nil==bean.ylzlfy?@"":bean.ylzlfy;
        self.blzlfy.text = nil==bean.blzlfy?@"":bean.blzlfy;
    }
}

@end
