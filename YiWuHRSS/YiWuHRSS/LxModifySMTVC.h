//
//  LxModifySMTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/24.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LxModifySMTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *Shbzhtf;
@property (weak, nonatomic) IBOutlet UITextField *Khtf;
@property (weak, nonatomic) IBOutlet UITextField *Yhkhtf;

- (IBAction)ModifySMBtnClicked:(id)sender;

@property (nonatomic, strong)  NSString  *access_token;

@end
