//
//  ModifyHXCardVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyHXCardVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *nametf;
@property (weak, nonatomic) IBOutlet UITextField *idnumtf;
@property (weak, nonatomic) IBOutlet UITextField *banknotf;

@property (nonatomic, strong)  NSString  *access_token;

- (IBAction)ModifyHXBtnClicked:(id)sender;

@end
