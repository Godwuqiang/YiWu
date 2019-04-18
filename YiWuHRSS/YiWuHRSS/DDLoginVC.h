//
//  DDLoginVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/1/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDLoginVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *AccountTextField;
@property (weak, nonatomic) IBOutlet UITextField *PasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *IsSeeBtn;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

- (IBAction)BackBtn:(id)sender;
- (IBAction)RegisteBtn:(id)sender;
- (IBAction)IsSeeClicked:(id)sender;
- (IBAction)LoginBtn:(id)sender;
- (IBAction)ForgetBtn:(id)sender;


@end
