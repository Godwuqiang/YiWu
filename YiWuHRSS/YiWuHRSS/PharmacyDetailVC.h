//
//  PharmacyDetailVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDJGBean.h"


@interface PharmacyDetailVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *brieftableview;
@property (weak, nonatomic) IBOutlet UIButton *Dhbtn;
@property (weak, nonatomic) IBOutlet UIButton *Dwbtn;

- (IBAction)DhbtnClicked:(id)sender;
- (IBAction)DwbtnClicked:(id)sender;


@property (nonatomic, strong) DDJGBean *bean;

@end
