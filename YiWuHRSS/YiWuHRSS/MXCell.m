//
//  MXCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "MXCell.h"

@implementation MXCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithTXdymxBean:(TXdymxBean*)bean{
    if (nil==bean) {
        self.xz.text = @"暂无数据";
        self.ffyh.text = @"暂无数据";
        self.yhzh.text = @"暂无数据";
        self.je.text = @"暂无数据";
    }else{
        self.xz.text = nil==bean.xzmc?@"无":bean.xzmc;
        self.ffyh.text = nil==bean.ffbank?@"无":bean.ffbank;
        NSString *zh = bean.bankno;
        if ([Util IsStringNil:zh]) {
            self.yhzh.text = @"无";
        }else{
//            self.yhzh.text = [Util StrngForStar:zh NumForHead:6 NumForEnd:4];
            //字符串的截取
            NSString *string = [zh substringWithRange:NSMakeRange(6,9)];
            self.yhzh.text = [zh stringByReplacingOccurrencesOfString:string withString:@"********"];
            
            
            
            
        }
        self.je.text = nil==bean.ffje?@"无":bean.ffje;
    }
}

@end
