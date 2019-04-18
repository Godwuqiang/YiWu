//
//  BankKTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankKTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nametf;
@property (weak, nonatomic) IBOutlet UITextField *IDNumtf;
@property (weak, nonatomic) IBOutlet UITextField *cardnotf;
@property (weak, nonatomic) IBOutlet UITextField *bankcardtf;
@property (weak, nonatomic) IBOutlet UITextField *banktf;
@property (weak, nonatomic) IBOutlet UITextField *smscodetf;
@property (weak, nonatomic) IBOutlet UILabel *bankmobile;
@property (weak, nonatomic) IBOutlet UIButton *codebtn;
@property (weak, nonatomic) IBOutlet UIButton *openbtn;
@property (weak, nonatomic) IBOutlet UITableViewCell *cardnocell;
@property (weak, nonatomic) IBOutlet UITableViewCell *SMSCodeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *BlankCell;


- (IBAction)CodeBtnClicked:(id)sender;
- (IBAction)OpenBtnClicked:(id)sender;

@property (nonatomic, strong)  NSString *lx;

@end
