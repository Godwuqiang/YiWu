//
//  LoginVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController
- (IBAction)OnClickLoginBtn:(id)sender;
- (IBAction)OnClickForGetBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *InputMobile;
@property (strong, nonatomic) IBOutlet UITextField *InputPass;
- (IBAction)OnClickShowPass:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *BtnShowPass;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@property(nonatomic, strong)  NSString *tp;
@property(nonatomic, strong)  AFNetworkReachabilityManager *manager;

@end
