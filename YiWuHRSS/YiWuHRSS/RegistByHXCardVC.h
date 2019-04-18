//
//  RegistByHXCardVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistByHXCardVC : UITableViewController

- (IBAction)OnClickNextAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *InputName;
@property (strong, nonatomic) IBOutlet UITextField *InputSHnum;
@property (strong, nonatomic) IBOutlet UITextField *InputBankNum;
@property(nonatomic, strong)   MBProgressHUD    *HUD;
@end
