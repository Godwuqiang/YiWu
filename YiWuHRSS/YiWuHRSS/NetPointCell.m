//
//  NetPointCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/2/20.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "NetPointCell.h"

@implementation NetPointCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.Type.layer.cornerRadius = 10;
    self.Type.clipsToBounds = YES;
    
    self.Type2.layer.cornerRadius = 10;
    self.Type2.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
