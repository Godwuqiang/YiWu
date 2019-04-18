//
//  ModifySMCardVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifySMCardVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nametf;
@property (weak, nonatomic) IBOutlet UITextField *shbzhtf;
@property (weak, nonatomic) IBOutlet UITextField *cardnotf;
@property (weak, nonatomic) IBOutlet UITextField *banknumtf;

@property (nonatomic, strong)  NSString  *access_token;

- (IBAction)ModifySMBtnClicked:(id)sender;

@end
