//
//  FindPsdVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/25.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPsdVC : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextField *idnumber;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UIButton *codebtn;
@property (weak, nonatomic) IBOutlet UITextField *psw;


- (IBAction)codeBtnClicked:(id)sender;
- (IBAction)nextBtnClicked:(id)sender;

@end
