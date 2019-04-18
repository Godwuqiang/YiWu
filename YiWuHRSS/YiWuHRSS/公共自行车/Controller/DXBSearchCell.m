//
//  DXBSearchCell.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBSearchCell.h"

@implementation DXBSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.bike_imgView.layer.cornerRadius = 19;
    self.bike_imgView.layer.masksToBounds = YES;
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
