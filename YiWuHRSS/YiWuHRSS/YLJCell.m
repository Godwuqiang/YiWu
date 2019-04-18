//
//  YLJCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YLJCell.h"

@implementation YLJCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)ConfigCellWithTXdyBean:(TXdyBean*)bean{
    if (nil==bean) {
        self.ffsj.text = @"暂无数据";
        self.ffje.text = @"暂无数据";
    }else{
        if (nil==bean.ffsj) {
            self.ffsj.text = @"无";
        }else{
            @try {
                NSMutableString *date = [[NSMutableString alloc]init];
                date.string = bean.ffsj;
                [date insertString:@"年" atIndex:4];
                [date insertString:@"月" atIndex:7];
                self.ffsj.text = date;
            } @catch (NSException *exception) {
                self.ffsj.text = @"无";
            }
        }
        self.ffje.text = nil==bean.ffje?@"无":bean.ffje;
    }
}

@end
