//
//  SetPassVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPassVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *psd;
@property (weak, nonatomic) IBOutlet UIButton *isSee;

@property (nonatomic, strong)  NSString *appmobile;
@property (nonatomic, strong)  NSString *validCode;

- (IBAction)SeeBtnClicked:(id)sender;
- (IBAction)DonBtnClicked:(id)sender;

@end
