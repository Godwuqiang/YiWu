//
//  YBDetailCellThree.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBDetailCellThree.h"

@implementation YBDetailCellThree

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellThreeWithMZBean:(MZBean*)bean{
    if (nil==bean) {
        self.ypmc.text = @"暂无数据";
        self.cost.text = @"暂无数据";
    }else{
        self.ypmc.text = nil==bean.xmgg?@"暂无":bean.xmgg;
        self.cost.text = nil==bean.je?@"暂无":bean.je;
    }
}

@end
