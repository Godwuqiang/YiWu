//
//  RegistAccountVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ValidateCardBean.h"

@interface RegistAccountVC : UITableViewController


@property(nonatomic,strong) NSString *Label_title;
@property(nonatomic,strong) NSString *psd;
@property(nonatomic,strong) NSString *mobile;
@property(nonatomic,strong) ValidateCardBean *bean;
@property (strong, nonatomic) IBOutlet UILabel *Label_card;
- (IBAction)OnClickNextAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *BtnSendCode;
- (IBAction)OnClickSendCodeBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *InputMobile;
@property (strong, nonatomic) IBOutlet UITextField *InputCode;
@property (strong, nonatomic) IBOutlet UITextField *InputPass;
@property (strong, nonatomic) IBOutlet UIButton *BtnShowPass;
- (IBAction)OnClickShowPass:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *InputConfirm;
@property (weak, nonatomic) IBOutlet UIButton *BtnShowConfirm;
- (IBAction)OnClickedShowConfirm:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *agreebtn;
- (IBAction)AgreeBtnClicked:(id)sender;
- (IBAction)XYBtnClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property(nonatomic, strong)   MBProgressHUD    *HUD;
@property(nonatomic,strong)       NSString      *type;
@property   BOOL   isagree;

@end
