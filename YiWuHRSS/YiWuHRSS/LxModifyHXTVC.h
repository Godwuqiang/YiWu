//
//  LxModifyHXTVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/24.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LxModifyHXTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *Sfzhtf;
@property (weak, nonatomic) IBOutlet UITextField *Yhkhtf;

- (IBAction)ModifyBtnClicked:(id)sender;

@property (nonatomic, strong)  NSString  *access_token;

@end
