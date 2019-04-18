//
//  MineCenterOne.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/10.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "MineCenterOne.h"

@implementation MineCenterOne

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if([HOST_TEST isEqualToString:@"http://122.226.66.214:7780/ywcitzencard"]){
    
    
//        self.environmentLabel.text = @"测试环境";
        self.environmentLabel.text = [CoreArchive strForKey:ENVIROMENT_DATA];
        
    }else if ([HOST_TEST isEqualToString:@"https://app.ywrl.gov.cn:8553/ywcitzencard"]){
        
        self.environmentLabel.hidden = YES;
    
    }else if([HOST_TEST isEqualToString:@"https://app.ywrl.gov.cn:8553/ywcitzencard-nc"]){
//        self.environmentLabel.text =  @"内测环境";
        self.environmentLabel.text = [CoreArchive strForKey:ENVIROMENT_DATA];
    }else{
    
        self.environmentLabel.hidden = YES;
    
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
