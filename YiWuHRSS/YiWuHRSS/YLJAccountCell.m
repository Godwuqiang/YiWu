//
//  YLJAccountCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YLJAccountCell.h"

@implementation YLJAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithYLAccountBean:(YLAccountBean*)bean{
    if (nil==bean) {
        self.snzhye.text = @"暂无数据";
        self.bnsjjfys.text = @"暂无数据";
        self.dnhzze.text = @"暂无数据";
        self.dnzhlx.text = @"暂无数据";
        self.znosjjfys.text = @"暂无数据";
        self.znmzhljcce.text = @"暂无数据";
    }else{
        self.snzhye.text = nil==bean.snmzhze?@"暂无数据":bean.snmzhze;
        self.bnsjjfys.text = nil==bean.bnsjjfys?@"暂无数据":bean.bnsjjfys;
        self.dnhzze.text = nil==bean.dnhzje?@"暂无数据":bean.dnhzje;
        self.dnzhlx.text = nil==bean.dnzhlx?@"暂无数据":bean.dnzhlx;
        self.znosjjfys.text = nil==bean.sjjfys?@"暂无数据":bean.sjjfys;
        self.znmzhljcce.text = nil==bean.ljcce?@"暂无数据":bean.ljcce;
    }
}

@end
