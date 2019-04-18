//
//  YWPswLoginView.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWPswLoginView.h"
#import "FindPsdVC.h"

@implementation YWPswLoginView

/**
 创建密码登录的View
 
 @return 密码登录的View
 */
+(instancetype)pswLoginView{
    return [[NSBundle mainBundle] loadNibNamed:@"YWPswLoginView" owner:self options:nil].firstObject;
}


/**
 忘记密码按钮点击事件

 @param sender 忘记密码按钮
 */
- (IBAction)forgetPswButtonClick:(UIButton *)sender {
    
    UIStoryboard *LS = [UIStoryboard storyboardWithName: @"LoginAndRegist" bundle: nil];
    FindPsdVC *VC = [LS instantiateViewControllerWithIdentifier:@"FindPsdVC"];
    [self.navVC pushViewController:VC animated:YES];
    
}


- (IBAction)seePswButtonClick:(UIButton *)sender {
    
    self.seePswButton.selected = !self.seePswButton.selected;
    if(self.seePswButton.selected){
        self.pswTextField.secureTextEntry = NO;
    }else{
        self.pswTextField.secureTextEntry = YES;
    }
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self =[super initWithCoder:aDecoder]) {
        
        self.identifyView.layer.borderWidth = 1.0;
        self.identifyView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.identifyView.layer.cornerRadius = 5.0;
        self.identifyView.layer.masksToBounds = YES;
        
        self.pswView.layer.borderWidth = 1.0;
        self.pswView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.pswView.layer.cornerRadius = 5.0;
        self.pswView.layer.masksToBounds = YES;
    }
    
    return self;
    
}



@end
