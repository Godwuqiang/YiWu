//
//  YWChangeMobileNumVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/21.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWChangeMobileNumVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nameLB; // 姓名


@property (weak, nonatomic) IBOutlet UILabel *IDNumberLB; // 身份证号

@property (weak, nonatomic) IBOutlet UILabel *oldPhoneLB; // 当前手机号

@property (weak, nonatomic) IBOutlet UITextField *phoneTF; // 新手机号


@property (weak, nonatomic) IBOutlet UITextField *validCodeTF; // 验证码

@property (weak, nonatomic) IBOutlet UIButton *validCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;


@end
