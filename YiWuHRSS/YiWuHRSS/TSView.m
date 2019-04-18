//
//  TSView.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "TSView.h"

@implementation TSView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    __weak __typeof(self) weakSelf = self;
    //    self.backgroundColor = [UIColor greenColor];
    
    //    int heigt,ziti,juli,gao;
    //    //区别屏幕尺寸
    //    if ( SCREEN_HEIGHT > 667) //6p
    //    {
    //        heigt = 15;
    //        ziti = 14;
    //        juli = 100;
    //    }
    //    else if (SCREEN_HEIGHT > 568)//6
    //    {
    //        heigt = 13;
    //        ziti = 12;
    //        juli = 90;
    //    }
    //    else if (SCREEN_HEIGHT > 480)//5s
    //    {
    //        heigt = 13;
    //        ziti = 10;
    //        juli = 80;
    //    }
    //    else //3.5寸屏幕
    //    {
    //        heigt = 8;
    //        ziti = 8;
    //        juli = 70;
    //    }
    
    self.tsbg = [[UIImageView alloc] init];
    [self addSubview:self.tsbg];
    [self.tsbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.mas_centerY).offset(-30);
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.right.equalTo(weakSelf.mas_right).offset(-10);
        make.height.equalTo(@280);
    }];
    
    self.tslb = [[UILabel alloc]init];
    [self addSubview:self.tslb];
    [self.tslb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.tsbg.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.width.equalTo(@200);
        make.height.equalTo(@15);
    }];
    self.tslb.textAlignment = NSTextAlignmentCenter;
    self.tslb.textColor = [UIColor colorWithHex:0x999999];
    self.tslb.font = [UIFont systemFontOfSize:14];
    
    self.tsbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.tsbtn];
    [self.tsbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.tslb.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.width.equalTo(@200);
        make.height.equalTo(@45);
    }];
    [self.tsbtn setBackgroundImage:[UIImage imageNamed:@"btn_submit"] forState:UIControlStateNormal];
    [self.tsbtn setTitle:@"重新刷新" forState:UIControlStateNormal];
}


@end
