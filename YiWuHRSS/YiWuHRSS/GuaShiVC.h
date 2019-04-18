//
//  GuaShiVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/15.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuaShiVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *gstableview;

@property (weak, nonatomic) IBOutlet UIView *contentview;
@property (weak, nonatomic) IBOutlet UIImageView *TsImg;
@property (weak, nonatomic) IBOutlet UILabel *TsLb;
@property (weak, nonatomic) IBOutlet UIButton *TsBtn;
@property (weak, nonatomic) IBOutlet UIButton *ReturnBtn;

@end
