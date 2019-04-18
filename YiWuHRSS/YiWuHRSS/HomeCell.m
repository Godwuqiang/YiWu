//
//  HomeCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "HomeCell.h"

#define TAG_BUTTON_MIDDLE1 0x001
#define TAG_BUTTON_MIDDLE2 0x002
#define TAG_BUTTON_MIDDLE3 0x003
#define TAG_BUTTON_MIDDLE4 0x004
#define TAG_BUTTON_MIDDLE5 0x005
#define TAG_BUTTON_MIDDLE6 0x006
#define TAG_BUTTON_MIDDLE7 0x007
#define TAG_BUTTON_MIDDLE8 0x008
#define TAG_BUTTON_MIDDLE9 0x009
#define TAG_BUTTON_MIDDLE10 0x010
#define TAG_BUTTON_MIDDLE11 0x011
#define TAG_BUTTON_MIDDLE12 0x012
#define TAG_BUTTON_MIDDLE13 0x013


@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self UI];
}

- (void)UI {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    int ziti;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
        ziti = 15;      //
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        ziti = 14;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        ziti = 13;
    }
    else //3.5寸屏幕
    {
        ziti = 12;
    }
    
    /* 参保信息按钮 */
    self.Btn1 = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    [self.Btn1 setTag:TAG_BUTTON_MIDDLE1];
    [self.Btn1 setImage:[UIImage imageNamed:@"icon_insured"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn1];
    
    self.Lb1 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.Btn1.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb1.text = @"参保信息";
    self.Lb1.textColor = [UIColor colorWithHex:0x333333];
    self.Lb1.textAlignment = NSTextAlignmentCenter;
    self.Lb1.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb1];
    
    //缴费记录
    self.Btn2 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn1.right+30, 15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    [self.Btn2 setTag:TAG_BUTTON_MIDDLE2];
    [self.Btn2 setImage:[UIImage imageNamed:@"icon_pay"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn2];
    
    self.Lb2 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb1.right, self.Btn2.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb2.text = @"缴费记录";
    self.Lb2.textColor = [UIColor colorWithHex:0x333333];
    self.Lb2.textAlignment = NSTextAlignmentCenter;
    self.Lb2.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb2];
    
    //医保账户
    self.Btn3 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn2.right+30, 15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn3.tag = TAG_BUTTON_MIDDLE3;
    [self.Btn3 setImage:[UIImage imageNamed:@"icon_auth"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn3];
    
    self.Lb3 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb2.right, self.Btn3.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb3.text = @"实人认证";
    self.Lb3.textColor = [UIColor colorWithHex:0x333333];
    self.Lb3.textAlignment = NSTextAlignmentCenter;
    self.Lb3.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb3];
    
    // 市民卡账户
    self.Btn4 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn3.right+30, +15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn4.tag = TAG_BUTTON_MIDDLE4;
    [self.Btn4 setImage:[UIImage imageNamed:@"icon_smaccount"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn4];
    
    self.Lb4 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb3.right, self.Btn4.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb4.text = @"市民卡账户";
    self.Lb4.textColor = [UIColor colorWithHex:0x333333];
    self.Lb4.textAlignment = NSTextAlignmentCenter;
    self.Lb4.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb4];
    
    //就诊挂号
    self.Btn5 = [[UIButton alloc] initWithFrame:CGRectMake(15, self.Lb1.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn5.tag = TAG_BUTTON_MIDDLE5;
    [self.Btn5 setImage:[UIImage imageNamed:@"icon_register"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn5];
    
    self.Lb5 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.Btn5.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb5.text = @"就诊挂号";
    self.Lb5.textColor = [UIColor colorWithHex:0x333333];
    self.Lb5.textAlignment = NSTextAlignmentCenter;
    self.Lb5.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb5];
    
    //检查检验单
    self.Btn6 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn5.right+30, self.Lb2.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn6.tag = TAG_BUTTON_MIDDLE6;
    [self.Btn6 setImage:[UIImage imageNamed:@"icon_checklist"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn6];
    
    self.Lb6 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb5.right, self.Btn6.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb6.text = @"检查检验单";
    self.Lb6.textColor = [UIColor colorWithHex:0x333333];
    self.Lb6.textAlignment = NSTextAlignmentCenter;
    self.Lb6.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb6];
    
    //公共自行车
    self.Btn7 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn6.right+30, self.Lb3.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn7.tag = TAG_BUTTON_MIDDLE7;
    [self.Btn7 setImage:[UIImage imageNamed:@"icon_bike"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn7];
    
    self.Lb7 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb6.right, self.Btn7.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb7.text = @"公共自行车";
    self.Lb7.textColor = [UIColor colorWithHex:0x333333];
    self.Lb7.textAlignment = NSTextAlignmentCenter;
    self.Lb7.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb7];
    
    // 医保移动支付
    self.Btn8 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn7.right+30, self.Lb4.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn8.tag = TAG_BUTTON_MIDDLE8;
    [self.Btn8 setImage:[UIImage imageNamed:@"icon_cxjmyiliao"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn8];
    
    self.Lb8 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb7.right, self.Btn8.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb8.text = @"城乡居民医疗";
    self.Lb8.textColor = [UIColor colorWithHex:0x333333];
    self.Lb8.textAlignment = NSTextAlignmentCenter;
    self.Lb8.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb8];
    
    //定点医院
    self.Btn9 = [[UIButton alloc] initWithFrame:CGRectMake(15, self.Lb5.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn9.tag = TAG_BUTTON_MIDDLE9;
    [self.Btn9 setImage:[UIImage imageNamed:@"icon_dabing"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn9];
    
    self.Lb9 = [[UILabel alloc]initWithFrame:CGRectMake(0, self.Btn9.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb9.text = @"大病保险";
    self.Lb9.textColor = [UIColor colorWithHex:0x333333];
    self.Lb9.textAlignment = NSTextAlignmentCenter;
    self.Lb9.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb9];
    
    //市民卡预挂失
    self.Btn10 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn9.right+30, self.Lb6.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn10.tag = TAG_BUTTON_MIDDLE10;
    [self.Btn10 setImage:[UIImage imageNamed:@"icon_preport"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn10];
    
    self.Lb10 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb9.right, self.Btn10.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb10.text = @"市民卡预挂失";
    self.Lb10.textColor = [UIColor colorWithHex:0x333333];
    self.Lb10.textAlignment = NSTextAlignmentCenter;
    self.Lb10.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb10];
    
    //家庭账户授权
    self.Btn11 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn10.right+30, self.Lb7.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn11.tag = TAG_BUTTON_MIDDLE11;
    [self.Btn11 setImage:[UIImage imageNamed:@"icon_author"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn11];
    
    self.Lb11 = [[UILabel alloc]initWithFrame:CGRectMake(self.Lb10.right, self.Btn11.bottom+5, SCREEN_WIDTH/4, 20)];
    self.Lb11.text = @"家庭账户授权";
    self.Lb11.textColor = [UIColor colorWithHex:0x333333];
    self.Lb11.textAlignment = NSTextAlignmentCenter;
    self.Lb11.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Lb11];
    
    // 更多
    self.Btn12 = [[UIButton alloc] initWithFrame:CGRectMake(self.Btn11.right+30, self.Lb8.bottom+15, (SCREEN_WIDTH-120)/4, (SCREEN_WIDTH-120)/4)];
    self.Btn12.tag = TAG_BUTTON_MIDDLE12;
    [self.Btn12 setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.Btn12];
    
    self.Btn13 = [[UIButton alloc] initWithFrame:CGRectMake(self.Lb11.right, self.Btn12.bottom+8, SCREEN_WIDTH/4, 15)];
    self.Btn13.tag = TAG_BUTTON_MIDDLE13;
    [self.Btn13 setTitle:@"更多" forState:UIControlStateNormal];
    [self.Btn13 setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    self.Btn13.titleLabel.font = [UIFont systemFontOfSize:ziti];
    [self.contentView addSubview:self.Btn13];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
