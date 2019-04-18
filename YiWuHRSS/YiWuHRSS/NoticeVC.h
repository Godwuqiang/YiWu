//
//  NoticeVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/26.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *Newsview;
@property (weak, nonatomic) IBOutlet UIImageView *Dot1img;
@property (weak, nonatomic) IBOutlet UILabel *Num1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Num1leftconstrains; // 10以内(34) 10以上(30)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Num1topconstrains;  // 显示数字(5) 显示...(2)


@property (weak, nonatomic) IBOutlet UIView *Sixinview;
@property (weak, nonatomic) IBOutlet UIImageView *Dot2img;
@property (weak, nonatomic) IBOutlet UILabel *Num2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Num2leftconstrains; // 10以内(34) 10以上(30)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Num2topconstrains;  // 显示数字(5) 显示...(2)

@end
