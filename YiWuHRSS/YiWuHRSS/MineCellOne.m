//
//  MineCellOne.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/29.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "MineCellOne.h"

@implementation MineCellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)ConfigLoadView{
    self.name.text = [CoreArchive strForKey:LOGIN_NAME];
    self.shbzh.text = [CoreArchive strForKey:LOGIN_SHBZH];
    self.kahao.text = [CoreArchive strForKey:LOGIN_CARD_NUM];
    self.bank.text = [CoreArchive strForKey:LOGIN_BANK];
    self.bankcardnum.text = [CoreArchive strForKey:LOGIN_BANK_CARD];
    self.isydzf.text = [CoreArchive strForKey:LOGIN_YDZF_STATUS];
    self.isbankzf.text = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];    
}

@end
