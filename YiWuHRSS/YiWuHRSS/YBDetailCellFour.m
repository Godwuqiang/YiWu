//
//  YBDetailCellFour.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBDetailCellFour.h"

@implementation YBDetailCellFour

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellFourWithMZBean:(MZBean*)bean{
    if (nil==bean) {
        self.total.text = @"暂无数据";
        self.baoxiao.text = @"暂无数据";
        self.zhifu.text = @"暂无数据";
    }else{
        self.total.text = nil==bean.zfy?@"无":bean.zfy;
        self.baoxiao.text = nil==bean.ybbx?@"无":bean.ybbx;
        self.zhifu.text = nil==bean.xjzf?@"无":bean.xjzf;
    }
}

-(void)ConfigCellFourWithZYBean:(ZYBean*)bean{
    if (nil==bean) {
        self.total.text = @"暂无数据";
        self.baoxiao.text = @"暂无数据";
        self.zhifu.text = @"暂无数据";
    }else{
        self.total.text = nil==bean.zfy?@"无":bean.zfy;
        self.baoxiao.text = nil==bean.ybbx?@"无":bean.ybbx;
        self.zhifu.text = nil==bean.xjzf?@"无":bean.xjzf;
    }
}

@end
