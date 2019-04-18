//
//  RegistBySMCardVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/13.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RegistBySMCardVC : UITableViewController

- (IBAction)OnClickNextAction:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *InputName;
@property (strong, nonatomic) IBOutlet UITextField *InPutSecoidNum;
@property (strong, nonatomic) IBOutlet UITextField *InputSMCardNum;
@property (strong, nonatomic) IBOutlet UITextField *InputBankCardNum;
@property (nonatomic, strong)   MBProgressHUD    *HUD;

@end
