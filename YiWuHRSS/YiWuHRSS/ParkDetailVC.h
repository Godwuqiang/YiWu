//
//  ParkDetailVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkDetailVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *Brieftableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tbbottom;

@property (weak, nonatomic) IBOutlet UIView *Tsview;
@property (weak, nonatomic) IBOutlet UIImageView *Tsimg;
@property (weak, nonatomic) IBOutlet UILabel *Tslb;
@property (weak, nonatomic) IBOutlet UIButton *Tsbtn;

@property (weak, nonatomic) IBOutlet UIButton *Dhbtn;
@property (weak, nonatomic) IBOutlet UIButton *Dwbtn;

@property (nonatomic, strong)   NSString  *PID;
//@property (nonatomic, strong)   NSString  *bt;

- (IBAction)Dh:(id)sender;
- (IBAction)Dw:(id)sender;

@end
