//
//  CanBaoInfoCellTwo.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/17.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "CanBaoInfoCellTwo.h"

@implementation CanBaoInfoCellTwo

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)ConfigCell{
    NSString *gender = [CoreArchive strForKey:LOGIN_GENDER];
    if ([Util IsStringNil:gender]) {
        self.xb.text = @"--";
    }else{
        int b = [gender intValue];
        if (b==1) {
            self.xb.text = @"男";
        }else if (b==2){
            self.xb.text = @"女";
        }else{
            self.xb.text = @"--";
        }
    }
    
    NSString *birth = [CoreArchive strForKey:LOGIN_BIRTHDATE];
    if ([Util IsStringNil:birth]) {
        self.birth.text = @"------";
    }else{
        NSMutableString *date = [[NSMutableString alloc]init];
        date.string = [CoreArchive strForKey:LOGIN_BIRTHDATE];
        [date replaceCharactersInRange:NSMakeRange(6, 2) withString:@"**"];
        [date insertString:@"-" atIndex:4];
        [date insertString:@"-" atIndex:7];
        self.birth.text = date;
    }
    NSString *shbzh = [CoreArchive strForKey:LOGIN_SHBZH];
    self.idnum.text = [Util HeadStr:shbzh WithNum:0];
}

@end
