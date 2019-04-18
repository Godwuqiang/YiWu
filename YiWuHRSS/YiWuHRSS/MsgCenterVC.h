//
//  MsgCenterVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/4/26.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCenterVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *listtableview;
@property (weak, nonatomic) IBOutlet UIView *Selectview;
@property (weak, nonatomic) IBOutlet UIView *Allselectview;
@property (weak, nonatomic) IBOutlet UIImageView *Selectimg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomconstrains;


@property (weak, nonatomic) IBOutlet UIView *contentview;
@property (weak, nonatomic) IBOutlet UIImageView *Tsbg;
@property (weak, nonatomic) IBOutlet UILabel *Tslb;
@property (weak, nonatomic) IBOutlet UIButton *Tsbtn;


- (IBAction)Delete:(id)sender;

@end
