//
//  ParkVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *Searchtf;
@property (weak, nonatomic) IBOutlet UIView *Typeview;
@property (weak, nonatomic) IBOutlet UILabel *type;

@property (weak, nonatomic) IBOutlet UITableView *listtableview;

@property (weak, nonatomic) IBOutlet UIView *Tsview;         // 提示层
@property (weak, nonatomic) IBOutlet UIImageView *Tsimg;
@property (weak, nonatomic) IBOutlet UILabel *Tslb;
@property (weak, nonatomic) IBOutlet UIButton *Refreshbtn;

@property (weak, nonatomic) IBOutlet UIView *Coverview;    // 遮盖层


- (IBAction)Search:(id)sender;

@end
