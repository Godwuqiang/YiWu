//
//  ChangAddressVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangAddressVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UIButton *btn;

- (IBAction)BtnClicked:(id)sender;
@end
