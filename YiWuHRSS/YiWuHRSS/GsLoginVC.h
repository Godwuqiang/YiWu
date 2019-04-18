//
//  GsLoginVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/17.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GsLoginVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *Mobile;
@property (weak, nonatomic) IBOutlet UITextField *Psd;
@property (weak, nonatomic) IBOutlet UIButton *SeeBtn;

- (IBAction)LoginBtnClicked:(id)sender;
- (IBAction)ForgetBtnClicked:(id)sender;
- (IBAction)SeeBtnClicked:(id)sender;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end
