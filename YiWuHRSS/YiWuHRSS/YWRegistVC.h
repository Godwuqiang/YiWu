//
//  YWRegistVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/17.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWRegistVC : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *pswTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmPswTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *seePswButton;
@property (weak, nonatomic) IBOutlet UIButton *seeComfirmPswButton;
@property (weak, nonatomic) IBOutlet UIButton *smsCodeButton;



@end
